import SwiftUI
import Combine

final class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    private static let cache = NSCache<NSString, UIImage>()
    private var cancellable: AnyCancellable?

    func load(from urlString: String?) {
        image = nil
        cancellable?.cancel()

        guard let url = sanitizedURL(from: urlString) else {
            return
        }

        let cacheKey = url.absoluteString as NSString

        if let cached = Self.cache.object(forKey: cacheKey) {
            self.image = cached
            return
        }

        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loadedImage in
                guard let self = self, let img = loadedImage else { return }
                Self.cache.setObject(img, forKey: cacheKey)
                self.image = img
            }
    }

    func cancel() {
        cancellable?.cancel()
    }

    /// Upgrade http -> https where possible to satisfy ATS.
    private func sanitizedURL(from urlString: String?) -> URL? {
        guard var string = urlString, !string.isEmpty else { return nil }

        if string.hasPrefix("http://") {
            string = "https://" + string.dropFirst("http://".count)
        }

        return URL(string: string)
    }
}

struct RemoteImageView: View {
    @StateObject private var loader = ImageLoader()
    let urlString: String?

    var body: some View {
        ZStack {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
        }
        .onAppear {
            loader.load(from: urlString)
        }
        .onDisappear {
            loader.cancel()
        }
    }
}
