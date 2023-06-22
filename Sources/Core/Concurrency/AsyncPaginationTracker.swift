//
// PaginationTracker
// Copyright © 2023 Wisemen
//

import StatefulUI

@available(iOS 13, *)
public final class AsyncPaginationTrackerWithContext<Page: PaginationPage, ContextObject> {
	public typealias PaginationContext = PaginationContextWithObject<Page, ContextObject>
	public typealias NextPageCall = (_ context: PaginationContext) async throws -> Page

	private let manager: AsyncPaginationTrackerManager<Page, ContextObject>
	private weak var statefulController: StatefulViewController?

	/// Create a pagination tracker with the given callback for loading data.
	///
	/// - Parameter nextPageCall: Callback for loading the next page.
	/// - Parameter contextObject: A context object that'll be available in the PaginationContext
	/// - Parameter statefulController: The controller that'll display the loading/empty state
	/// - Parameter pageSize: The size of a page, will be used to calculate when the next page should be loaded.
	/// - seealso: `NextPageCall`
	public init(nextPageCall: @escaping NextPageCall, contextObject: ContextObject, statefulController: StatefulViewController? = nil, pageSize: Int = 10) {
		defer { Task { await manager.setup(delegate: self) } }
		manager = .init(nextPageCall: nextPageCall, contextObject: contextObject, pageSize: pageSize)
		self.statefulController = statefulController
	}
}

@available(iOS 13, *)
public extension AsyncPaginationTrackerWithContext {
	/// Equivalent to calling `reset(forceRefresh: false, ...)`
	@discardableResult
	func startPaging() async throws -> Page {
		try await reset(forceRefresh: false)
	}

	/// Reset the pagination tracker, for example when the user "pulls to refresh"
	///
	/// - parameter forceRefresh: Passed along to the `nextPageCall`.
	@discardableResult
	func reset(forceRefresh: Bool) async throws -> Page {
		try await manager.reset(forceRefresh: forceRefresh)
	}

	/// Track an index path that will be displayed and, if needed, trigger loading the next page.
	/// A load will be triggered if the offset is within the range of items already loaded (from previous pages).
	///
	/// - parameter indexPath: The index path to check.
	/// - parameter view: The table/collection view to check in.
	func track(indexPath: IndexPath, for view: ViewWithItemsInSections) {
		Task { await manager.track(indexPath: indexPath, view: view) }
	}

	/// Use this if you want to manually trigger loading the next page, for example after a page load failed.
	@discardableResult
	func loadNextPage() async throws -> Page {
		try await manager.loadNextPage(forceRefresh: false)
	}
}

// MARK: - Manager delegate

@available(iOS 13, *)
extension AsyncPaginationTrackerWithContext: AsyncPaginationTrackerManagerDelegate {
	func startLoading() {
		Task { @MainActor [weak self] in
			self?.statefulController?.startLoading()
		}
	}

	func endLoading(error: Error?) {
		Task { @MainActor [weak self] in
			self?.statefulController?.endLoading(error: error)
		}
	}
}

// MARK: - Simple tracker

@available(iOS 13, *)
public typealias AsyncPaginationTracker<Page: PaginationPage> = AsyncPaginationTrackerWithContext<Page, Void>

@available(iOS 13, *)
public extension AsyncPaginationTrackerWithContext where ContextObject == Void {
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
