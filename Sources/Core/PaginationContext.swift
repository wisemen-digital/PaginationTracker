//
//  PaginationContext.swift
//  Tennis Vlaanderen
//
//  Created by David Jennes on 25/01/2019.
//  Copyright © 2019 Appwise. All rights reserved.
//

import Foundation

public struct PaginationContextWithObject<Page: PaginationPage, Object> {
	public let pages: [Page]
	public let forceRefresh: Bool
	public let object: Object

	public init(pages: [Page], forceRefresh: Bool, object: Object) {
		self.pages = pages
		self.forceRefresh = forceRefresh
		self.object = object
	}

	public var current: Page? {
		return pages.last
	}

	public var nextPage: URL? {
		return current?.nextPage
	}
}

public typealias PaginationContext<Page: PaginationPage> = PaginationContextWithObject<Page, Void>

public extension PaginationContextWithObject where Object == Void {
	init(pages: [Page], forceRefresh: Bool) {
		self.init(pages: pages, forceRefresh: forceRefresh, object: ())
	}
}
