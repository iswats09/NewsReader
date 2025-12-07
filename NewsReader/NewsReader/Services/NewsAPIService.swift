import Foundation
import Combine

protocol NewsAPIServiceProtocol {
    func fetchArticles(
        searchQuery: String,
        pageURL: URL?
    ) -> AnyPublisher<SpaceNewsResponse, APIError>
}

final class NewsAPIService: NewsAPIServiceProtocol {

    private let baseURL = URL(string: "https://api.spaceflightnewsapi.net/v4/articles")!

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()

        let isoWithFractional = ISO8601DateFormatter()
        isoWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        decoder.dateDecodingStrategy = .custom { decoder in
            let c = try decoder.singleValueContainer()
            let s = try c.decode(String.self)
            if let d = isoWithFractional.date(from: s) { return d }
            let simpleISO = ISO8601DateFormatter()
            if let d = simpleISO.date(from: s) { return d }
            throw DecodingError.dataCorruptedError(in: c, debugDescription: "Invalid date: \(s)")
        }

        return decoder
    }()

    func fetchArticles(
        searchQuery: String,
        pageURL: URL?
    ) -> AnyPublisher<SpaceNewsResponse, APIError> {

        let url: URL = {
            if let pageURL { return pageURL }
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
            var items: [URLQueryItem] = [URLQueryItem(name: "limit", value: "10")]
            let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty { items.append(URLQueryItem(name: "search", value: trimmed)) }
            components.queryItems = items
            return components.url!
        }()

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { APIError.network($0) }
            .flatMap { output in
                Just(output.data)
                    .decode(type: SpaceNewsResponse.self, decoder: Self.decoder)
                    .mapError { error in
                        if let decoding = error as? DecodingError { return .decoding(decoding) }
                        return .unknown(error)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
