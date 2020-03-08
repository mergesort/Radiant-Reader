import Combine
import Foundation

// MARK: URLSession+decodableDataTaskPublisher

extension URLSession {

    // Taken with liberty from https://riteshhh.com/combine/declarative-networking-with-combine/
    func decodableDataTaskPublisher<Output: Decodable>(for url: URL, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Output, Error> {
        return self
            .dataTaskPublisher(for: URLRequest(url: url))
            .mapJsonValue(to: Output.self, decoder: decoder)
            .eraseToAnyPublisher()
    }

}

// MARK: DataTaskResult

typealias DataTaskResult = (data: Data, response: URLResponse)

// MARK: Publisher + DataTaskResult

extension Publisher where Output == DataTaskResult {

    func mapJsonValue<Output: Decodable>(to outputType: Output.Type, decoder: JSONDecoder) -> AnyPublisher<Output, Error> {
        return self
            .map(\.data)
            .decode(type: outputType, decoder: decoder)
            .mapError({
                Swift.print($0)
                return $0
            })
            .eraseToAnyPublisher()
    }

}

// MARK: Local Article Loading For Demo Purposes

extension URLSession {

    enum JSONParsingError: Error {
        case failedToLoadLocalContent
    }

    // Fake delay to simulate network activity
    func fetchLocalArticlesWithDelay(from source: Article.SupportedSource) -> AnyPublisher<ArticlesResponse, Error> {
        return self.fetchLocalArticles(from: source)
            .delay(for: .milliseconds(400), scheduler: RunLoop.main) // Fake delay to simulate network activity
            .eraseToAnyPublisher()
    }

    func fetchLocalArticles(from source: Article.SupportedSource) -> AnyPublisher<ArticlesResponse, Error> {
        guard let url = Bundle.main.url(forResource: source.filename, withExtension: "json") else {
            return Fail(error: JSONParsingError.failedToLoadLocalContent)
                .eraseToAnyPublisher()
        }

        return Result<ArticlesResponse, Error> {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(ArticlesResponse.self, from: data)
        }
        .publisher
        .eraseToAnyPublisher()
    }

}

private extension Article.SupportedSource {

    var filename: String {
        switch self {
        case .bbc:
            return "BBC"

        case .axios:
            return "Axios"

        case .nbc:
            return "NBCNews"
        }
    }

}
