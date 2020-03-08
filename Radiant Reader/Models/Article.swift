import Foundation

struct ArticlesResponse: Codable {

    enum CodingKeys: String, CodingKey {
        case status
        case totalResults
        case articles
    }

    let status: String
    let totalResults: Int
    let articles: [Article]

}

// MARK: Article

struct Article: Codable {

    // MARK: Source

    struct Source: Codable {
        let id: String
        let name: String
    }

    private enum CodingKeys: String, CodingKey {
        case author
        case description
        case imageUrl = "urlToImage"
        case publishedAt
        case source
        case title
        case url = "url"
    }

    let author: String?
    let description: String
    let imageUrl: URL?
    let publishedAt: Date
    let source: Source
    let title: String
    let url: URL

}

extension Article {

    // MARK: SupportedSource

    enum SupportedSource: String {
        case bbc = "bbc-news"
        case axios = "axios"
        case nbc = "nbc-news"

        var url: URL {
            guard let token = ProcessInfo.processInfo.environment["NEWS_API_ACCESS_TOKEN"] else { fatalError("News API access token is missing") }

            var components = URLComponents()
            components.scheme = "https"
            components.host = "newsapi.org"
            components.path = "/v2/top-headlines"
            components.queryItems = [
                URLQueryItem(name: "sources", value: self.rawValue),
                URLQueryItem(name: "apiKey", value: token)
            ]

            guard let url = components.url else { fatalError("Could not construct valid URL for \(self)") }

            return url
        }
    }

}
