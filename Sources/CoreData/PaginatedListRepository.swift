//
// PaginationTracker
// Copyright © 2023 Wisemen
//

import Alamofire
import AppwiseCore
import CoreData

public protocol PaginatedListRepository {
	associatedtype PageType: PaginationPage where PageType.Item: NSManagedObject & ManyImportable
	associatedtype PaginationContextObject

	var context: NSManagedObjectContext { get }
	var fetchRequest: NSFetchRequest<PageType.Item> { get }

	var frc: NSFetchedResultsController<PageType.Item> { get }
	var paginationContextObject: PaginationContextObject { get }
	func loadNextPage(_ context: PaginationContextWithObject<PageType, PaginationContextObject>, _ handler: @escaping (Result<PageType, Error>) -> Void)
	func findOldItems() -> [PageType.Item]
}

public extension PaginatedListRepository {
	var frc: NSFetchedResultsController<PageType.Item> {
		return NSFetchedResultsController(
			fetchRequest: fetchRequest,
			managedObjectContext: context,
			sectionNameKeyPath: nil,
			cacheName: nil
		)
	}

	func findOldItems() -> [PageType.Item] {
		return context.findOldItems(filter: fetchRequest.predicate)
	}
}

public extension PaginatedListRepository where PaginationContextObject == Void {
	var paginationContextObject: Void {
		return ()
	}
}
