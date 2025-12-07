import SwiftUI

struct RefreshableScrollView<Content: View>: UIViewRepresentable {
    @Binding var isRefreshing: Bool
    let onRefresh: () -> Void
    let content: () -> Content

    init(
        isRefreshing: Binding<Bool>,
        onRefresh: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isRefreshing = isRefreshing
        self.onRefresh = onRefresh
        self.content = content
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            context.coordinator,
            action: #selector(Coordinator.handleRefresh),
            for: .valueChanged
        )
        scrollView.refreshControl = refreshControl

        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(hostedView)

        NSLayoutConstraint.activate([
            hostedView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            hostedView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            hostedView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            hostedView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            hostedView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.hostingController.rootView = content()

        // Do NOT manipulate contentOffset here.
        // Just end refreshing when the binding changes to false.
        if !isRefreshing {
            uiView.refreshControl?.endRefreshing()
        }
    }

    class Coordinator: NSObject {
        let parent: RefreshableScrollView
        let hostingController: UIHostingController<Content>

        init(parent: RefreshableScrollView) {
            self.parent = parent
            self.hostingController = UIHostingController(rootView: parent.content())
            self.hostingController.view.backgroundColor = .clear
        }

        @objc func handleRefresh() {
            parent.onRefresh()
        }
    }
}
