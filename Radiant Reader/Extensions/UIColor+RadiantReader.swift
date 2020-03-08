import UIKit

// MARK: UIColor

extension UIColor {

    enum Semantic {
        static let background = UIColor.systemGroupedBackground
    }

}

// MARK: Article

extension Article {

    var primaryColor: UIColor {
        guard let source = SupportedSource(rawValue: self.source.id) else { return UIColor.systemBackground }

        switch source {

        case .axios:
            return UIColor.systemBlue

        case .bbc:
            return UIColor.systemPurple

        case .nbc:
            return UIColor.systemRed

        }
    }

}
