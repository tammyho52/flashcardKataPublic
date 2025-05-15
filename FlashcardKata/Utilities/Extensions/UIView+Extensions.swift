//
//  UIView+Extensions.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Extension for UIView to apply default shadow settings.

import UIKit

extension UIView {
    func applyDefaultShadowToLayer() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 1
        self.layer.masksToBounds = false
    }
}
