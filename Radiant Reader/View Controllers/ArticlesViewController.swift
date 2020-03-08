import Combine
import SafariServices
import TableFlip
import UIKit

// MARK: ArticlesViewController

class ArticlesViewController: UIViewController {

    private let viewModel: ArticlesViewModel
    private var subscriptions: Set<AnyCancellable> = []

    let confettiView: ConfettiView = {
        let confettiView = ConfettiView()
        confettiView.alpha = 0.8

        return confettiView
    }()

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.Semantic.background

        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: String(describing: ArticleTableViewCell.self))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200.0 // Picking a mostly random value honestly

        return tableView
    }()

    // MARK: Initializers

    init(articles: [Article]) {
        self.viewModel = ArticlesViewModel(articles: articles)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = ArticlesViewModel(articles: [])

        super.init(coder: coder)

        self.title = NSLocalizedString("The Latest", comment: "Title for articles view")

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "heart.circle.fill"), style: .plain, target: self, action: #selector(presentFavoritesViewController))

        self.viewModel.fetchAllArticles()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { articles in
                    self.viewModel.articles = articles
                    self.tableView.reloadData()
            })
            .store(in: &subscriptions)
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
    }

}

// MARK: UITableViewDataSource

extension ArticlesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = self.viewModel.articles[indexPath.row]

        self.presentSafariViewController(for: article)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ArticleTableViewCell else { return }

        let currentArticle = self.viewModel.articles[indexPath.row]

        cell.longPressAction = { [weak self] in
            guard let self = self else { return }
            self.presentSaveArticleActionSheet(article: currentArticle)
        }
    }

}

// MARK: Private

private extension ArticlesViewController {

    func setup() {
        self.view.addSubview(self.tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self.viewModel

        self.view.addSubview(self.confettiView)

        self.setupConstraints()
    }

    func setupConstraints() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])

        self.confettiView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.confettiView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.confettiView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.confettiView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.confettiView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }

    @objc func presentFavoritesViewController() {
        self.viewModel.fetchFavoritedArticles()
            .sink(receiveValue: { articles in
                // Abstract this into it's own function
                let articlesViewController = ArticlesViewController(articles: articles)
                let navigationController = UINavigationController(rootViewController: articlesViewController)
                articlesViewController.title = NSLocalizedString("Favorites", comment: "Title for screen where articles the user has favorited")

                articlesViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "\(articles.count)", style: .done, target: nil, action: nil)
                articlesViewController.navigationItem.rightBarButtonItem?.isEnabled = false

                self.present(navigationController, animated: true, completion: nil)
            })
            .store(in: &subscriptions)
    }

    func presentSafariViewController(for article: Article) {
        let safariViewController = SFSafariViewController(url: article.url)
        self.present(safariViewController, animated: true, completion: nil)
    }

    func presentSaveArticleActionSheet(article: Article) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alertController.addAction(
            UIAlertAction(title: "Favorite this article", style: .default, handler: { action in
                self.viewModel.favoriteArticle(article)
            })
        )

        alertController.addAction(
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        )

        self.present(alertController, animated: true, completion: nil)
    }

    func displayConfetti() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
            self.confettiView.emit(
                for: 3.0,
                with: [
                    .text("❤️"),
                    .text("💚"),
                    .text("💜"),
                    .text("💙"),
                    .text("💛"),
                    .text("🧡"),
            ])
        })
    }

    func animateFavoriteButton(with animation: FavoriteButtonAnimation) {
        guard let buttonView = self.navigationItem.rightBarButtonItem?.value(forKey: "view") as? UIView else { return }

        switch animation {

        case .fadeIn:
            UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.85, animations: {
                buttonView.layer.opacity = 1.0
            }).startAnimation()

        case .fadeOut:
            UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.85, animations: {
                buttonView.layer.opacity = 0.0
            }).startAnimation()

        case .scaleUp:
            buttonView.layer.opacity = 1.0
            buttonView.layer.setAffineTransform(CGAffineTransform(scaleX: 0.01, y: 0.01))

            UIViewPropertyAnimator(duration: 0.4, dampingRatio: 0.6, animations: {
                buttonView.layer.setAffineTransform(.identity)
            }).startAnimation()

        }
    }

    enum FavoriteButtonAnimation {
        case scaleUp
        case fadeIn
        case fadeOut
    }

}
