//
//  AuthorizationControllerPresenter.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Presenter for handling authorization controller presentation context.

import UIKit
import AuthenticationServices

@MainActor
class AuthorizationControllerPresenter: NSObject, ASAuthorizationControllerPresentationContextProviding {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return viewController?.view.window ?? ASPresentationAnchor()
    }
}
    
