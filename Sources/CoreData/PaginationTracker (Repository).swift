//
// PaginationTracker
// Copyright © 2023 Wisemen
//

import Foundation
import StatefulUI

public extension PaginationTrackerWithContext {
	convenience init<Repository: PaginatedListRepository>(repository: Repository, statefulController: StatefulViewController? = nil, pageSize: Int = 10) where Page == Repository.PageType, ContextObject == Repository.PaginationContextObject {
		self.init(
			nextPageCall: repository.loadNextPage,
			contextObject: repository.paginationContextObject,
			statefulController: statefulController,
			pageSize: pageSize
		)
	}
}

public extension PaginationTrackerWithContext where ContextObject == Void {
	convenience init<Repository: PaginatedListRepository>(repository: Repository, statefulController: StatefulViewController? = nil, pageSize: Int = 10) where Page == Repository.PageType, Repository.PaginationContextObject == Void {
		self.init(
			nextPageCall: repository.loadNextPage,
			statefulController: statefulController,
			pageSize: pageSize
		)
	}
}
