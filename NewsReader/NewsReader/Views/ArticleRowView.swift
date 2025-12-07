import SwiftUI

struct ArticleRowView: View {
    let article: Article
    let isBookmarked: Bool

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    private var formattedDate: String {
        Self.dateFormatter.string(from: article.publishedAt)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RemoteImageView(urlString: article.imageURL)
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(article.title)
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 0)

                    if isBookmarked {
                        Image(systemName: "bookmark.fill")
                            .foregroundColor(.yellow)
                            .imageScale(.medium)
                            .accessibilityLabel("Bookmarked")
                    }
                }

                Text(article.newsSite)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text(article.summary)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                Text(formattedDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}
