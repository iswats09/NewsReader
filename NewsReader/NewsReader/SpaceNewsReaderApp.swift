import SwiftUI

@main
struct SpaceNewsReaderApp: App {
    var body: some Scene {
        WindowGroup {
            ArticleListView(
                viewModel: ArticleListViewModel(
                    service: NewsAPIService()
                )
            )
        }
    }
}
