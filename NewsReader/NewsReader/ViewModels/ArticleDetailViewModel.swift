import Foundation
import Combine

final class ArticleDetailViewModel: ObservableObject {
    
    let article: Article

    init(article: Article) {
        self.article = article
    }

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var formattedDate: String {
        Self.formatter.string(from: article.publishedAt)
    }
}
