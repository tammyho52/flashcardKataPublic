//
//  Font+Extensions.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  A collection of custom font categories relative to standard Apple font categories.

import SwiftUI

extension Font {
    static var customLargeTitle: Font {
        return Font.custom("Avenir", size: 34, relativeTo: .largeTitle)
    }

    static var customTitle: Font {
        return Font.custom("Avenir", size: 28, relativeTo: .title)
    }

    static var customTitle2: Font {
        return Font.custom("Avenir", size: 22, relativeTo: .title2)
        }

    static var customTitle3: Font {
        return Font.custom("Avenir", size: 20, relativeTo: .title3)
    }

    static var customHeadline: Font {
        return Font.custom("Avenir", size: 18, relativeTo: .headline)
    }

    static var customSubheadline: Font {
        return Font.custom("Avenir", size: 15, relativeTo: .subheadline)
    }

    static var customBody: Font {
        return Font.custom("Avenir", size: 17, relativeTo: .body)
    }

    static var customCallout: Font {
        return Font.custom("Avenir", size: 16, relativeTo: .callout)
    }

    static var customFootnote: Font {
        return Font.custom("Avenir", size: 13, relativeTo: .footnote)
    }

    static var customCaption: Font {
        return Font.custom("Avenir", size: 12, relativeTo: .caption)
    }

    static var customCaption2: Font {
        return Font.custom("Avenir", size: 11, relativeTo: .caption2)
    }
}
