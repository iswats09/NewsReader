import Foundation

struct Article: Identifiable, Codable, Equatable {
    let id: Int
    let title: String
    let summary: String
    let url: String
    let imageURL: String?
    let newsSite: String
    let publishedAt: Date
    let updatedAt: Date
    let featured: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case summary
        case url
        case imageURL = "image_url"
        case newsSite = "news_site"
        case publishedAt = "published_at"
        case updatedAt = "updated_at"
        case featured
    }

    // Convenience computed properties for UI wording
    var descriptionText: String { summary }
    var thumbnailURL: String? { imageURL }
}
