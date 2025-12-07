import Foundation

protocol NewsCacheProtocol {
    func save(articles: [Article]) throws
    func load() throws -> [Article]
}

final class NewsCache: NewsCacheProtocol {

    private let fileName = "cached_articles.json"

    private var fileURL: URL {
        let urls = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )
        return urls[0].appendingPathComponent(fileName)
    }

    func save(articles: [Article]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(articles)
        try data.write(to: fileURL, options: .atomic)
    }

    func load() throws -> [Article] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw APIError.noCachedData
        }
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Article].self, from: data)
    }
}
