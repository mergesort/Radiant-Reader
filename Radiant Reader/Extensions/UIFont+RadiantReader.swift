import UIKit

// MARK: UIFont

extension UIFont {

    enum Semantic {
        static var titleFont: UIFont {
            UIFont(name: Self.boldFontName, size: UIFont.pointSize(from: .title2))!
        }
        static var descriptionFont: UIFont {
            UIFont(name: Self.regularFontName, size: UIFont.pointSize(from: .title3))!
        }

        static var metadataFont: UIFont {
            UIFont.boldSystemFont(ofSize: UIFont.pointSize(from: .subheadline))
        }
        static var sourceFont: UIFont {
            UIFont.boldSystemFont(ofSize: UIFont.pointSize(from: .callout))
        }

        private static let regularFontName = "Georgia"
        private static let boldFontName = "Georgia-Bold"
    }

}

// MARK: Private - UIFont

private extension UIFont {

    // An extension to make our call-sites cleaner, as a treat
    static func pointSize(from textStyle: TextStyle) -> CGFloat {
        return UIFont.preferredFont(forTextStyle: textStyle).pointSize
    }

}
