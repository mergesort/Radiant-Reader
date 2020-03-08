import UIKit

// MARK: ArticleTableViewCell

final class ArticleTableViewCell: UITableViewCell {

    var longPressAction: (() -> Void)?

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8.0

        return stackView
    }()

    let backgroundColorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4.0

        return view
    }()

    let authorLabel: UILabel = {
        let label = UILabel()

        return label
    }()

    let sourceLabel: UILabel = {
        let label = PaddingLabel()

        label.padding = UIEdgeInsets(top: 2.0, left: 4.0, bottom: 2.0, right: 4.0)
        label.textColor = UIColor.label
        label.layer.cornerRadius = 4.0
        label.clipsToBounds = true

        return label
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.label

        return label
    }()

    let metadataLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.label

        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 5
        label.textColor = UIColor.label

        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.metadataLabel.text = ""
        self.titleLabel.text = ""
        self.descriptionLabel.text = ""
        self.backgroundColorView.backgroundColor = UIColor.systemBackground
    }

}

// MARK: Internal

extension ArticleTableViewCell {

    func setViewModel(_ viewModel: ArticlesTableCellViewModel) {
        self.authorLabel.text = viewModel.authorText
        self.sourceLabel.text = viewModel.sourceText

        self.metadataLabel.text = viewModel.dateText

        self.titleLabel.text = viewModel.titleText
        self.descriptionLabel.text = viewModel.descriptionText

        self.sourceLabel.textColor = UIColor.white

        self.sourceLabel.backgroundColor = viewModel.tintColor
        self.sourceLabel.layer.shadowColor = viewModel.tintColor.cgColor
        self.sourceLabel.layer.shadowOpacity = 0.4
        self.sourceLabel.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
    }

}

// MARK: Private

private extension ArticleTableViewCell {

    func setup() {
        self.backgroundColorView.backgroundColor = UIColor.systemBackground
        self.contentView.backgroundColor = UIColor.tertiarySystemGroupedBackground

        self.contentView.addSubview(self.backgroundColorView)
        self.backgroundColorView.addSubview(self.stackView)

        let sourceStackView = UIStackView(arrangedSubviews: [self.sourceLabel, UIView(), self.metadataLabel])
        sourceStackView.spacing = 8.0
        self.sourceLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.stackView.addArrangedSubview(sourceStackView)

        self.stackView.addArrangedSubview(self.authorLabel)
        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.addArrangedSubview(self.descriptionLabel)

        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressedTableCell))
        self.addGestureRecognizer(longPressGestureRecognizer)

        self.setupConstraints()

        self.titleLabel.font = UIFont.Semantic.titleFont
        self.sourceLabel.font = UIFont.Semantic.sourceFont
        self.descriptionLabel.font = UIFont.Semantic.descriptionFont

        self.authorLabel.font = UIFont.Semantic.metadataFont
        self.authorLabel.textColor = UIColor.secondaryLabel

        self.metadataLabel.font = UIFont.Semantic.metadataFont
        self.metadataLabel.textColor = UIColor.secondaryLabel
    }

    func setupConstraints() {
        let verticalInset: CGFloat = 8.0
        let horizontalInset: CGFloat = 8.0

        self.backgroundColorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.backgroundColorView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: horizontalInset),
            self.backgroundColorView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -horizontalInset),
            self.backgroundColorView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: verticalInset),
            self.backgroundColorView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0.0),
        ])

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.stackView.leadingAnchor.constraint(equalTo: self.backgroundColorView.leadingAnchor, constant: horizontalInset),
            self.stackView.trailingAnchor.constraint(equalTo: self.backgroundColorView.trailingAnchor, constant: -horizontalInset),
            self.stackView.topAnchor.constraint(equalTo: self.backgroundColorView.topAnchor, constant: verticalInset),
            self.stackView.bottomAnchor.constraint(equalTo: self.backgroundColorView.bottomAnchor, constant: -verticalInset),
        ])
    }

    @objc func longPressedTableCell() {
        self.longPressAction?()
    }

}

// MARK: ArticlesTableCellViewModel

struct ArticlesTableCellViewModel {

    let tintColor: UIColor
    let titleText: String
    let dateText: String
    let authorText: String
    let sourceText: String
    let descriptionText: String

    init(article: Article) {
        self.titleText = article.title

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        self.dateText = dateFormatter.string(from: article.publishedAt)

        self.authorText = article.author ?? article.source.name

        self.sourceText = article.source.name

        self.descriptionText = article.description

        self.tintColor = article.primaryColor
    }

}

// MARK: Private - PaddingLabel

// Adding some padding around the source name, in the easiest way possible. :)
private final class PaddingLabel: UILabel {

    var padding: UIEdgeInsets = .zero

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: self.padding.top, left: self.padding.left, bottom: self.padding.bottom, right: self.padding.right)

        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize

        return CGSize(width: size.width + self.padding.left + self.padding.right, height: size.height + self.padding.top + self.padding.bottom)
    }

}
