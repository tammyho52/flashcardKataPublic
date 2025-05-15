//
//  UILabel+Extensions.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Extension for UILabel to set SFSymbol with text.

import UIKit

extension UILabel {
    func setSFSymbolWithText(symbolName: String, text: String, textColor: UIColor) {
        let symbolAttachment = NSTextAttachment()
        if let symbolImage = UIImage(systemName: symbolName)?.withTintColor(textColor, renderingMode: .alwaysOriginal) {
            symbolAttachment.image = symbolImage
        }
        
        let symbolString = NSAttributedString(attachment: symbolAttachment)
        let textFont = UIFont.customBody
        let textString = NSAttributedString(string: " \(text)", attributes: [.font: textFont, .foregroundColor: textColor])
        
        let combinedString = NSMutableAttributedString()
        combinedString.append(symbolString)
        combinedString.append(textString)
        
        self.attributedText = combinedString
    }
}
