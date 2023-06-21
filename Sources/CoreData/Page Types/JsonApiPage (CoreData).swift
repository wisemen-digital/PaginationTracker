//
// PaginationTracker
// Copyright © 2023 Wisemen
//

import AppwiseCore
import CoreData

extension JsonApiPage: Wrapper, Insertable, ManyInsertable where Item: NSManagedObject {
	public init() {
	}

	public mutating func map(_ map: Map) throws {
		try items <- map[CodingKeys.items.rawValue]

		var next: String?
		next <- map["\(CodingKeys.links.rawValue).\(CodingKeys.Links.next.rawValue)"]
		nextPage = next.flatMap { URL(string: $0) }
	}

	public func inContext(_ context: NSManagedObjectContext) throws -> JsonApiPage<T> {
		var result = self
		result.items = try items.map { try $0.inContext(context) }
		return result
	}
}

extension JsonApiPage: Importable where T: ManyImportable {
	public func didImport(from json: Any, in context: ImportContext) throws {
		guard let json = json as? [String: Any],
			let data = json[CodingKeys.items.rawValue] as? [Any] else { return }
		try items.didImport(from: data, in: context)
	}
}
