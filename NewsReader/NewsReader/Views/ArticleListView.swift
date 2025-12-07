import SwiftUI

struct ArticleListView: View {
    @ObservedObject var viewModel: ArticleListViewModel
    @State private var pageToken: String = ""

    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                Group {
                    if viewModel.isLoading && viewModel.articles.isEmpty {
                        // Initial loading state
                        VStack(spacing: 16) {
                            ProgressView("Loading…")
                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .id("top") // Ensure a top anchor exists even during initial load
                    } else {
                        List {
                            // Invisible top anchor to scroll to (no extra space)
                            Color.clear
                                .frame(height: 0)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .id("top")

                            if let error = viewModel.errorMessage {
                                Section {
                                    Text(error)
                                        .foregroundColor(.red)
                                }
                            }

                            ForEach(Array(viewModel.articles.enumerated()), id: \.element.id) { index, article in
                                NavigationLink(
                                    destination: ArticleDetailView(
                                        viewModel: ArticleDetailViewModel(article: article),
                                        isBookmarked: viewModel.isBookmarked(article),
                                        onToggleBookmark: { viewModel.toggleBookmark(for: article) }
                                    )
                                ) {
                                    ArticleRowView(
                                        article: article,
                                        isBookmarked: viewModel.isBookmarked(article)
                                    )
                                }
                                // Hide the top separator for the first actual content row
                                .listRowSeparator(index == 0 ? .hidden : .automatic, edges: .top)
                            }
                        }
                        // Native pull-to-refresh
                        .refreshable {
                            viewModel.refresh()
                        }
                        .listStyle(.plain)
                    }
                }
                // Floating search bar overlayed at the top, not consuming List's inset
                .safeAreaInset(edge: .top) {
                    HStack {
                        SearchBarView(text: $viewModel.searchQuery)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 6)
                    .background(.ultraThinMaterial)
                }
                // Bottom pagination controls pinned above home indicator
                .safeAreaInset(edge: .bottom) {
                    PaginationControls(viewModel: viewModel)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                }
                // Remove/Hide the title to avoid extra space
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("") // no title text
                .toolbar(.hidden, for: .navigationBar)
                // Update page token when pagination URLs change (indicates a new page)
                .onChange(of: viewModel.nextPageURL) { _ in
                    updatePageTokenAndScrollToTop(proxy: proxy)
                }
                .onChange(of: viewModel.previousPageURL) { _ in
                    updatePageTokenAndScrollToTop(proxy: proxy)
                }
                // Also handle initial appearance
                .onAppear {
                    updatePageTokenAndScrollToTop(proxy: proxy, animated: false)
                }
            }
        }
    }

    private func updatePageTokenAndScrollToTop(proxy: ScrollViewProxy, animated: Bool = true) {
        let token = (viewModel.previousPageURL?.absoluteString ?? "nil")
                 + "|"
                 + (viewModel.nextPageURL?.absoluteString ?? "nil")

        guard token != pageToken else { return }
        pageToken = token

        if animated {
            withAnimation(.easeInOut(duration: 0.25)) {
                proxy.scrollTo("top", anchor: .top)
            }
        } else {
            proxy.scrollTo("top", anchor: .top)
        }
    }
}

// MARK: - Pagination Controls

private struct PaginationControls: View {
    @ObservedObject var viewModel: ArticleListViewModel

    var body: some View {
        HStack {
            Button(action: { viewModel.goToPreviousPage() }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Previous")
                }
            }
            .disabled(!viewModel.canGoPrevious)

            Spacer()

            if viewModel.isLoadingPage {
                ProgressView()
            } else {
                Button(action: { viewModel.goToNextPage() }) {
                    HStack(spacing: 4) {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                }
                .disabled(!viewModel.canGoNext)
            }
        }
        .font(.subheadline)
        .padding(.horizontal)
    }
}
