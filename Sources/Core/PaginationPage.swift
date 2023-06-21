//
// PaginationTracker
// Copyright © 2023 Wisemen
//

import Foundation

public protocol PaginationPage {
	associatedtype Item

	var items: [Item] { get }
	var nextPage: URL? { get }
}
