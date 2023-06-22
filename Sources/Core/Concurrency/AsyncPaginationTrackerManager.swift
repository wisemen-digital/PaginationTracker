//
// PaginationTracker
// Copyright © 2023 Wisemen
//

import Foundation

protocol AsyncPaginationTrackerManagerDelegate: AnyObject {
	func startLoading()
	func endLoading(error: Error?)
}

@available(iOS 13, *)
final actor AsyncPaginationTrackerManager<Page: PaginationPage, ContextObject> {
	public typealias PaginationContext = PaginationContextWithObject<Page, ContextObject>
	public typealias NextPageCall = (_ context: PaginationContext) async throws -> Page

	private let nextPageCall: NextPageCall
	private let contextObject: ContextObject
	private let pageSize: Int

	private var limitIndexPath: IndexPath?
	private var pageTotalItemCount = 0
	private var isTrackingEnabled: Bool = false
	private var activeTask: Task<Page, Error>?

	private weak var delegate: AsyncPaginationTrackerManagerDelegate?

	private(set) var pages: [Page] = [] {
		didSet { updatePageTotalItemCount() }
	}

	var isLoadingNextPage: Bool {
		activeTask != nil
	}

	init(nextPageCall: @escaping NextPageCall, contextObject: ContextObject, pageSize: Int, delegate: AsyncPaginationTrackerManagerDelegate? = nil) {
		self.nextPageCall = nextPageCall
		self.contextObject = contextObject
		self.pageSize = pageSize
		self.delegate = delegate
	}
}

// MARK: - Helpers

@available(iOS 13, *)
extension AsyncPaginationTrackerManager {
	func setup(delegate: AsyncPaginationTrackerManagerDelegate) {
		self.delegate = delegate
	}

	func updatePageTotalItemCount() {
		pageTotalItemCount = pages.map { $0.items.count }.reduce(0, +)
	}

	func reset(forceRefresh: Bool) async throws -> Page {
		activeTask?.cancel()
		activeTask = nil

		pages = []
		limitIndexPath = nil

		defer { isTrackingEnabled = true }
		isTrackingEnabled = false

		return try await loadNextPage(forceRefresh: forceRefresh)
	}
}

// MARK: - Tracking

@available(iOS 13, *)
extension AsyncPaginationTrackerManager {
	func passedPreviousLimit(indexPath: IndexPath) -> Bool {
		if limitIndexPath == nil {
			limitIndexPath = IndexPath(item: 0, section: 0)
		}

		// avoid heavy calculations if we haven't passed the max of before
		if let limitIndexPath = limitIndexPath,
		   indexPath > limitIndexPath,
		   !isLoadingNextPage,
		   isTrackingEnabled {
			return true
		} else {
			return false
		}
	}

	func track(indexPath: IndexPath, view: ViewWithItemsInSections) async {
		if passedPreviousLimit(indexPath: indexPath) {
			limitIndexPath = indexPath

			let index = await MainActor.run { view.calculateTotalItemsUpTo(indexPath: indexPath) }
			if index < pageTotalItemCount - pageSize { // we're still before the last page
				return
			} else if !isLoadingNextPage, pages.isEmpty || pages.last?.nextPage != nil { // do we have a next page? (or none yet)
				try? await loadNextPage(forceRefresh: false)
			}
		}
	}
}

// MARK: - Loading page

@available(iOS 13, *)
extension AsyncPaginationTrackerManager {
	func loadNextPage(forceRefresh: Bool) async throws -> Page {
		let task: Task<Page, Error> = loadNextPage(forceRefresh: forceRefresh)
		activeTask = task

		defer { activeTask = nil }

		do {
			delegate?.startLoading()
			let page = try await task.value
			delegate?.endLoading(error: nil)
			return page
		} catch {
			delegate?.endLoading(error: error)
			throw error
		}
	}

	func loadNextPage(forceRefresh: Bool) -> Task<Page, Error> {
		let context = PaginationContextWithObject(pages: pages, forceRefresh: forceRefresh, object: contextObject)

		return Task {
			let page = try await nextPageCall(context)
			pages.append(page)
			return page
		}
	}
}
