import Foundation
import Combine
import SwiftUI

final class ArticleListViewModel: ObservableObject {

    // MARK: - Inputs
    @Published var searchQuery: String = ""

    // MARK: - Outputs
    @Published private(set) var articles: [Article] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isLoadingPage: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var errorMessage: String?

    // Pagination URLs
    @Published private(set) var nextPageURL: URL?
    @Published private(set) var previousPageURL: URL?

    // Track the URL used to produce the current page so refresh can reload same page.
    private var currentPageURL: URL?

    // Bookmarks stored as '|' separated URLs
    @AppStorage("bookmarkedArticleURLs")
    private var bookmarkedArticleURLsString: String = ""

    private var bookmarkedURLs: Set<String> {
        get { Set(bookmarkedArticleURLsString.split(separator: "|").map(String.init)) }
        set { bookmarkedArticleURLsString = newValue.joined(separator: "|") }
    }

    // Dependencies
    private let service: NewsAPIServiceProtocol
    private let cache: NewsCacheProtocol

    private var cancellables = Set<AnyCancellable>()
    private var searchCancellable: AnyCancellable?

    // MARK: - Init

    init(service: NewsAPIServiceProtocol,
         cache: NewsCacheProtocol = NewsCache()) {
        self.service = service
        self.cache = cache
        setupSearchPipeline()
        loadCachedOnLaunch()
        fetchArticles(pageURL: nil, isReset: true)
    }

    // MARK: - Public

    func refresh() {
        isRefreshing = true
        fetchArticles(pageURL: currentPageURL, isReset: false)
    }

    var canGoNext: Bool { nextPageURL != nil }
    var canGoPrevious: Bool { previousPageURL != nil }

    func goToNextPage() {
        guard let url = nextPageURL, !isLoading && !isLoadingPage else { return }
        isLoadingPage = true
        fetchArticles(pageURL: url, isReset: false)
    }

    func goToPreviousPage() {
        guard let url = previousPageURL, !isLoading && !isLoadingPage else { return }
        isLoadingPage = true
        fetchArticles(pageURL: url, isReset: false)
    }

    func isBookmarked(_ article: Article) -> Bool {
        bookmarkedURLs.contains(article.url)
    }

    func toggleBookmark(for article: Article) {
        var set = bookmarkedURLs
        if !set.insert(article.url).inserted { set.remove(article.url) }
        bookmarkedURLs = set
        objectWillChange.send()
    }

    // MARK: - Private

    private func setupSearchPipeline() {
        searchCancellable = $searchQuery
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.fetchArticles(pageURL: nil, isReset: true)
            }
    }

    private func loadCachedOnLaunch() {
        if let cached = try? cache.load() {
            self.articles = cached
        }
    }

    private func fetchArticles(pageURL: URL?, isReset: Bool) {
        errorMessage = nil

        if isReset {
            isLoading = true
            nextPageURL = nil
            previousPageURL = nil
            currentPageURL = nil
        }

        service.fetchArticles(searchQuery: searchQuery, pageURL: pageURL)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                self.isLoadingPage = false
                self.isRefreshing = false

                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                    if isReset, let cached = try? self.cache.load() {
                        self.articles = cached
                        self.errorMessage = "Showing offline data.\n\(error.localizedDescription)"
                    }
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }

                self.articles = response.results
                _ = try? self.cache.save(articles: self.articles)

                self.nextPageURL = response.next.flatMap(URL.init(string:))
                self.previousPageURL = response.previous.flatMap(URL.init(string:))

                // Track current page
                if let requestedURL = pageURL {
                    self.currentPageURL = requestedURL
                } else if self.previousPageURL == nil {
                    self.currentPageURL = Self.buildFirstPageURL(searchQuery: self.searchQuery)
                }
            }
            .store(in: &cancellables)
    }

    private static func buildFirstPageURL(searchQuery: String) -> URL? {
        var components = URLComponents(string: "https://api.spaceflightnewsapi.net/v4/articles")
        var items: [URLQueryItem] = [URLQueryItem(name: "limit", value: "10")]
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { items.append(URLQueryItem(name: "search", value: trimmed)) }
        components?.queryItems = items
        return components?.url
    }
}
