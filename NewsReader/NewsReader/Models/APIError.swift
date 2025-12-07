import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case network(Error)
    case decoding(DecodingError)
    case unknown(Error?)
    case noCachedData

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .network(let error):
            return "Network error: \(error.localizedDescription)"
        case .decoding:
            return "Failed to decode server response."
        case .unknown(let error):
            return "Unknown error: \(error?.localizedDescription ?? "Unknown error")"
        case .noCachedData:
            return "No offline data available."
        }
    }
}
