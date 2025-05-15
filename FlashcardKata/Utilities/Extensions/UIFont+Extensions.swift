//
//  UIFont+Extensions.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Extension for UIFont to provide custom font styles.

import UIKit

extension UIFont {
    static var customLargeTitle: UIFont {
        return UIFont(name: "Avenir", size: 34) ?? UIFont.systemFont(ofSize: 34)
    }

    static var customTitle: UIFont {
        return UIFont(name: "Avenir", size: 28) ?? UIFont.systemFont(ofSize: 28)
    }

    static var customTitle2: UIFont {
        return UIFont(name: "Avenir", size: 22) ?? UIFont.systemFont(ofSize: 22)
        }

    static var customTitle3: UIFont {
        return UIFont(name: "Avenir", size: 20) ?? UIFont.systemFont(ofSize: 20)
    }

    static var customHeadline: UIFont {
        return UIFont(name: "Avenir", size: 18) ?? UIFont.systemFont(ofSize: 18)
    }

    static var customSubheadline: UIFont {
        return UIFont(name: "Avenir", size: 15) ?? UIFont.systemFont(ofSize: 15)
    }

    static var customBody: UIFont {
        return UIFont(name: "Avenir", size: 17) ?? UIFont.systemFont(ofSize: 17)
    }

    static var customCallout: UIFont {
        return UIFont(name: "Avenir", size: 16) ?? UIFont.systemFont(ofSize: 16)
    }

    static var customFootnote: UIFont {
        return UIFont(name: "Avenir", size: 13) ?? UIFont.systemFont(ofSize: 13)
    }

    static var customCaption: UIFont {
        return UIFont(name: "Avenir", size: 12) ?? UIFont.systemFont(ofSize: 12)
    }

    static var customCaption2: UIFont {
        return UIFont(name: "Avenir", size: 11) ?? UIFont.systemFont(ofSize: 11)
    }
}
