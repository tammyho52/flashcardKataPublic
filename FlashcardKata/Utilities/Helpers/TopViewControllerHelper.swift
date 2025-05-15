//
//  TopViewControllerHelper.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Utility class that helps identify the topmost view controller in a view controller hierarchy.

import Foundation
import UIKit

/// Identifies the topmost view controller in a view controller hierarchy.
@MainActor
final class TopViewControllerHelper {

    static let shared = TopViewControllerHelper()

    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let controller = controller ?? UIApplication.shared.connectedScenes.compactMap {
            ($0 as? UIWindowScene)?.keyWindow
        }.last?.rootViewController

        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
