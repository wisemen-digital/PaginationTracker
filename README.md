# PaginationTracker

![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg)
![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20tvOS-lightgrey.svg)

A small library for tracking scrolling in a collection or table view, and triggering page loads as needed.

## Overview

Once you've created a tracker, you just need to notify it whenever your view will display a cell, and it'll automatically decide whether it needs to load a new page or not.

## Usage

First, create a pagination tracker and store it in a variable in your controller. In your `viewDidLoad`, ensure you start pagination.

```swift
final class NewsController: UITableViewController {
    private lazy var paginationTracker = PaginationTracker(
        nextPageCall: networkClient.loadNextNewsPage
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        // Other setup...

        paginationTracker.startPaging { _ in }
    }
}
```

Then in your data source implement the `willDisplay` delegate function so you can update the tracker.

```swift
extension NewsController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        paginationTracker.track(indexPath: indexPath, for: tableView)
    }
}
```

### Pull-to-refresh

If you're adding pull-to-refresh to your view, make sure to trigger a pagination reset.

```swift
extension NewsController {
    @IBAction private func refresh() {
        paginationTracker.reset(forceRefresh: true) { [weak self] _ in
            guard let self = self else { return }

            self.refreshControl?.endRefreshing()

            // reload data source, for example an FRC:
            try? self.source.controller.performFetch()
        }
    }
}
```

The `forceRefresh` parameter is set to `true` here, so that you can check whether you need to delete old data during your import:

```swift
extension News {
    func didImport(...) {
        let pagination: PaginationContext<News> = ...

        if pagination.forceRefresh {
            // Delete all old news items
        }
    }
}
```

### Pagination Context

The next page call is defined as follows:
``` swift
typealias NextPageCall = (_ context: PaginationContextWithObject<Page, ContextObject>, _ handler: @escaping (Result<Page, Error>) -> Void) -> Void
```

If during your pagination, you need to have a certain context object/information, you can use the following initializer instead:

```swift
final class NewsController: UITableViewController {
    private var category: NewsCategory

    private lazy var paginationTracker = PaginationTrackerWithContext(
        nextPageCall: networkClient.loadNextPage,
        contextObject: category
    )
}
```

Now you can access this object in the next page call:

```swift
func loadNextPage(_ context: PaginationContextWithObject<NewsPage, NewsCategory>, _ handler: @escaping (Result<NewsPage, Error>) -> Void) {
    // get pagination context object (a news category)
    let newsCategory = context.object
}
```

### StatefulUI integration

`PaginationTracker` easily integrates with the StatefulUI library, you just need to provide the `StatefulViewController` during initialization:

```swift
final class NewsController: UITableViewController {
    private lazy var paginationTracker = PaginationTracker(
        nextPageCall: networkClient.loadNextNewsPage,
        statefulController: self
    )
}

extension NewsController: StatefulViewController {
    // Stateful implementation...
}
```

The tracker will automatically set the correct state, whether it is loading a page, has no content or an error occurred.

## Installation

#### CocoaPods

Add the following line to your Podfile.

```ruby
pod "PaginationTracker", "~> 1.0"
```

Then run `pod install` with CocoaPods 1.4 or newer.

## Contributing

* Create something awesome, make the code better, add some functionality,
  whatever (this is the hardest part).
* [Fork it](http://help.github.com/forking/)
* Create new branch to make your changes
* Commit all your changes to your branch
* Submit a [pull request](http://help.github.com/pull-requests/)

## Credits

PaginationTracker is brought to you by [David Jennes](https://twitter.com/davidjennes).

## License

PaginationTracker is available under the MIT license. See the LICENSE file for more info.
