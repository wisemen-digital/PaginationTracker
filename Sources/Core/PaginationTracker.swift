//
//  PaginationTracker.swift
//  Tennis Vlaanderen
//
//  Created by David Jennes on 23/01/2019.
//  Copyright © 2019 Appwise. All rights reserved.
//

import Alamofire
import StatefulUI

public final class PaginationTrackerWithContext<Page: PaginationPage, ContextObject> {
	public typealias NextPageCall = (_ context: PaginationContextWithObject<Page, ContextObject>, _ handler: @escaping (Result<Page>) -> Void) -> Void

	private var pages: [Page] = [] {
		didSet {
			updatePageTotalItemCount()
		}
	}

	private var limitIndexPath: IndexPath?
	private let pageSize: Int
	private var pageTotalItemCount = 0
	private let nextPageCall: NextPageCall
	private let contextObject: ContextObject
	private var isLoadingNextPage = false
	private weak var statefulController: StatefulViewController?

	/// Whether or not tracking is currently enabled.
	private var isTrackingEnabled: Bool = false

	/// Create a pagination tracker with the given callback for loading data.
	///
	/// - Parameter nextPageCall: Callback for loading the next page.
	/// - Parameter contextObject: A context object that'll be available in the PaginationContext
	/// - Parameter statefulController: The controller that'll display the loading/empty state
	/// - Parameter pageSize: The size of a page, will be used to calculate when the next page should be loaded.
	/// - seealso: `NextPageCall`
	public init(nextPageCall: @escaping NextPageCall, contextObject: ContextObject, statefulController: StatefulViewController? = nil, pageSize: Int = 10) {
		self.nextPageCall = nextPageCall
		self.contextObject = contextObject
		self.statefulController = statefulController
		self.pageSize = pageSize
	}

	/// Equivalent to calling `reset(forceRefresh: false, ...)`
	///
	/// - parameter handler: Callback after the page loaded.
	public func startPaging(then handler: @escaping (Result<Page>) -> Void) {
		reset(forceRefresh: false, then: handler)
	}

	/// Reset the pagination tracker, for example when the user "pulls to refresh"
	///
	/// - parameter forceRefresh: Passed along to the `nextPageCall`.
	/// - parameter handler: Callback after the page loaded.
	public func reset(forceRefresh: Bool, then handler: @escaping (Result<Page>) -> Void) {
		pages = []
		limitIndexPath = nil
		isTrackingEnabled = false
		loadNextPage(forceRefresh: forceRefresh) { [weak self] result in
			self?.isTrackingEnabled = true
			handler(result)
		}
	}

	/// Track an index path that will be displayed and, if needed, trigger loading the next page.
	/// A load will be triggered if the offset is within the range of items already loaded (from previous pages).
	///
	/// - parameter indexPath: The index path to check.
	/// - parameter view: The table/collection view to check in.
	public func track(indexPath: IndexPath, for view: ViewWithItemsInSections, then handler: @escaping (Result<Page>) -> Void = { _ in }) {
		if limitIndexPath == nil {
			resetLimitIndexPath(in: view)
		}

		// avoid heavy calculations if we haven't passed the max of before
		guard let limitIndexPath = limitIndexPath,
			indexPath > limitIndexPath,
			!isLoadingNextPage,
			isTrackingEnabled else { return }
		self.limitIndexPath = indexPath

		// only trigger if we're reached the last page
		let index = view.calculateTotalItemsUpTo(indexPath: indexPath)
		if index < pageTotalItemCount - pageSize {
			// we're still before the last page
			return

				// do we have a next page? (or none yet)
		} else if pages.isEmpty || pages.last?.nextPage != nil {
			// load next page
			loadNextPage(forceRefresh: false, then: handler)
		}
	}

	/// Use this if you want to manually trigger loading the next page, for example after a page load failed.
	///
	/// - parameter handler: Callback after the page loaded.
	public func loadNextPage(then handler: @escaping (Result<Page>) -> Void) {
		loadNextPage(forceRefresh: false, then: handler)
	}
}

private extension PaginationTrackerWithContext {
	func loadNextPage(forceRefresh: Bool, then handler: @escaping (Result<Page>) -> Void) {
		guard !isLoadingNextPage else { return }

		let context = PaginationContextWithObject(pages: pages, forceRefresh: forceRefresh, object: contextObject)

		isLoadingNextPage = true
		statefulController?.startLoading()

		nextPageCall(context) { [weak self] result in
			if let page = result.value {
				self?.pages.append(page)
			}
			self?.statefulController?.endLoading(error: result.error)
			self?.isLoadingNextPage = false

			handler(result)
		}
	}

	func resetLimitIndexPath(in view: ViewWithItemsInSections) {
		limitIndexPath = IndexPath(item: 0, section: 0)
	}

	func updatePageTotalItemCount() {
		pageTotalItemCount = pages.map { $0.items.count }.reduce(0, +)
	}
}

// MARK: - Simple tracker

public typealias PaginationTracker<Page: PaginationPage> = PaginationTrackerWithContext<Page, Void>

public extension PaginationTrackerWithContext where ContextObject == Void {
	/// Create a pagination tracker with the given callback for loading data.
	///
	/// - Parameter nextPageCall: Callback for loading the next page.
	/// - Parameter statefulController: The controller that'll display the loading/empty state
	/// - Parameter pageSize: The size of a page, will be used to calculate when the next page should be loaded.
	/// - seealso: `NextPageCall`
	convenience init(nextPageCall: @escaping NextPageCall, statefulController: StatefulViewController? = nil, pageSize: Int = 10) {
		self.init(nextPageCall: nextPageCall, contextObject: (), statefulController: statefulController, pageSize: pageSize)
	}
}
