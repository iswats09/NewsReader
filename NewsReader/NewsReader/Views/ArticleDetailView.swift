import SwiftUI

struct ArticleDetailView: View {
    @ObservedObject var viewModel: ArticleDetailViewModel

    let isBookmarked: Bool
    let onToggleBookmark: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                RemoteImageView(urlString: viewModel.article.imageURL)
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .clipped()

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.article.title)
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text(viewModel.article.newsSite)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(viewModel.formattedDate)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button(action: onToggleBookmark) {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .imageScale(.large)
                    }
                }

                Text(viewModel.article.summary)
                    .font(.body)

                if let url = URL(string: viewModel.article.url) {
                    Divider()
                    Link("Open Full Article", destination: url)
                        .font(.headline)
                }

                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationBarTitle("Article", displayMode: .inline)
    }
}
