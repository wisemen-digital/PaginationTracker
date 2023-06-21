//
// PaginationTracker
// Copyright © 2023 Wisemen
//

import UIKit

public protocol ViewWithItemsInSections: AnyObject {
	var numberOfSections: Int { get }
	func numberOfItems(inSection section: Int) -> Int
}

extension ViewWithItemsInSections {
	func calculateTotalItems() -> Int {
		return (0..<numberOfSections)
			.map { numberOfItems(inSection: $0) }
			.reduce(0, +)
	}

	func calculateTotalItemsUpTo(indexPath: IndexPath) -> Int {
		guard numberOfSections > 0 else { return 0 }

		return (0..<indexPath.section)
			.map { numberOfItems(inSection: $0) }
			.reduce(0, +) + indexPath.row
	}
}

extension UITableView: ViewWithItemsInSections {
	public func numberOfItems(inSection section: Int) -> Int {
		return numberOfRows(inSection: section)
	}
}

extension UICollectionView: ViewWithItemsInSections {
}
