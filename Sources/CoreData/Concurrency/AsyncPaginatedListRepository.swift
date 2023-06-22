//
// PaginationTracker
// Copyright © 2023 Wisemen
//

import Alamofire
import AppwiseCore
import CoreData

@available(iOS 13, *)
public protocol AsyncPaginatedListRepository: PaginatedListRepository {
	func loadNextPage(_ context: PaginationContextWithObject<PageType, PaginationContextObject>) async throws -> PageType
}

@available(iOS 13, *)
extension AsyncPaginatedListRepository {
	public func loadNextPage(_ context: PaginationContextWithObject<PageType, PaginationContextObject>, _ handler: @escaping (Result<PageType, Error>) -> Void) {
		Task { @MainActor in
			do {
				let page = try await self.loadNextPage(context)
				handler(.success(page))
			} catch {
				handler(.failure(error))
			}
		}
	}
}
