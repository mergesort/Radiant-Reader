import Combine
import UIKit

// MARK: ArticlesViewModel

final class ArticlesViewModel: NSObject {

    var articles: [Article]

    var usesArticleStyle = false

    init(articles: [Article]) {
        self.articles = articles

        super.init()
    }

    func fetchAllArticles() -> AnyPublisher<[Article], Error> {
        return Publishers.Zip3(
            self.fetchLocalArticles(from: .axios),
            self.fetchLocalArticles(from: .bbc),
            self.fetchLocalArticles(from: .nbc)
        )
        .map({ ($0.0.articles, $0.1.articles, $0.2.articles) })
        .map({ zip(zip($0, $1), $2).flatMap { [$0.0, $0.1, $1].shuffled() } })
        .eraseToAnyPublisher()
    }

    // Fetches a random subset of 10 articles, for demo purposes. ;)
    func fetchFavoritedArticles() -> AnyPublisher<[Article], Never> {
        return Publishers.Zip3(
            self.fetchLocalArticles(from: .bbc),
            self.fetchLocalArticles(from: .axios),
            self.fetchLocalArticles(from: .nbc)
        )
        .map({ ($0.0.articles, $0.1.articles, $0.2.articles) })
        .map({ zip(zip($0, $1), $2).flatMap { [$0.0, $0.1, $1].shuffled() } })
        .map({ Array($0.prefix(10)) })
        .replaceError(with: [])
        .eraseToAnyPublisher()
    }

    func favoriteArticle(_ article: Article) {
        // Nice try, but there's no code in here. I didn't have time for it!
    }

}

// MARK: UITableViewDataSource

extension ArticlesViewModel: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentArticle = self.articles[indexPath.row]

        // Added for demo purposes, in a production app we'd render all the rows as `ArticleTableViewCell`s.
        if self.usesArticleStyle {
            let reuseIdentifier = String(describing: ArticleTableViewCell.self)
            guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? ArticleTableViewCell else { fatalError("Could not properly dequeue \(reuseIdentifier)") }

            let viewModel = ArticlesTableCellViewModel(article: currentArticle)
            cell.setViewModel(viewModel)

            return cell
        } else {
            let reuseIdentifier = String(describing: UITableViewCell.self)
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)

            cell.textLabel?.text = "\(currentArticle.source.name): \(currentArticle.title)"
            cell.detailTextLabel?.text = currentArticle.description
            cell.detailTextLabel?.numberOfLines = 0

            return cell
        }
    }

}

// MARK: Private

private extension ArticlesViewModel {

    func fetchArticles(from source: Article.SupportedSource) -> AnyPublisher<ArticlesResponse, Error> {
        let session = URLSession(configuration: URLSessionConfiguration.default)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return session.decodableDataTaskPublisher(for: source.url, decoder: decoder)
    }

    func fetchLocalArticles(from source: Article.SupportedSource) -> AnyPublisher<ArticlesResponse, Error> {
        let session = URLSession(configuration: URLSessionConfiguration.default)

        return session.fetchLocalArticles(from: source)
    }

}
