//
//  PaginationPage.swift
//  Tennis Vlaanderen
//
//  Created by David Jennes on 23/01/2019.
//  Copyright © 2019 Appwise. All rights reserved.
//

import Foundation

public protocol PaginationPage {
	associatedtype Item

	var items: [Item] { get }
	var nextPage: URL? { get }
}
