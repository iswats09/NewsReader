# NewsReader

# Space News Reader

A lightweight SwiftUI app for browsing the latest spaceflight news using the Spaceflight News API v4.

- Platform: iOS (SwiftUI)
- Language: Swift
- Minimum iOS: 15+ (uses SwiftUI List + .refreshable + safeAreaInset)
- Architecture: MVVM + simple service/repository and file-based cache

## Features

- Browse articles with title, site, summary, image, and published date
- Open an article detail view
- Bookmark/unbookmark articles (persisted locally)
- Pull to refresh (keeps you on the same page)
- Pagination with Next/Previous controls (always visible and not clipped)
- Search across articles
- Offline fallback to cached articles when the network fails

## Screens

- Article list with a floating search bar and bottom pagination controls
- Article detail view with image, metadata, summary, and a link to the full article

## API

Spaceflight News API v4:
- Base: https://api.spaceflightnewsapi.net/v4/articles
- Pagination: limit + offset via `next` and `previous` URLs in the response
- Search: `search` query parameter

Example responses include:
```json
{
  "count": 1234,
  "next": "https://api.spaceflightnewsapi.net/v4/articles/?limit=10&offset=10",
  "previous": null,
  "results": [ /* Article objects */ ]
}
