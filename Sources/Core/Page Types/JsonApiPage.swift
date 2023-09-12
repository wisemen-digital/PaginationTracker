//
// PaginationTracker
// Copyright © 2023 Wisemen
//

import Foundation

public struct JsonApiPage<T>: PaginationPage {
	public var items: [T] = []
	public var nextPage: URL? = nil

	public init(items: [T] = [], nextPage: URL? = nil) {
		self.items = items
		self.nextPage = nextPage
	}
}

extension JsonApiPage {
	enum CodingKeys: String, CodingKey {
		case items = "data"
		case links

		enum Links: String, CodingKey {
			case next
		}
	}
}

extension JsonApiPage: Decodable where Item: Decodable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		items = try container.decode([T].self, forKey: .items)
		let linksContainer = try container.nestedContainer(keyedBy: CodingKeys.Links.self, forKey: .links)
		nextPage = try? linksContainer.decode(URL.self, forKey: .next)
	}
}
