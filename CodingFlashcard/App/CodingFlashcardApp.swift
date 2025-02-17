//
//  CodingFlashcardApp.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.

import SwiftUI
import UIKit
import FirebaseCore
import FirebaseFirestoreInternal
import FirebaseAuth
import GoogleSignIn


@main
struct CodingFlashcardApp: App {
    // MARK: - State Management and Dependencies
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.font) private var font
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authenticationManager: AuthenticationManager = AuthenticationManager()
    @StateObject var webViewService: WebViewService = WebViewService()
    
    init() {
    }
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            ContentView(
                authenticationManager: authenticationManager,
                webViewService: webViewService
            )
            .environment(\.font, Font.customBody)
            .onChange(of: scenePhase) { _, newPhase in
                switch newPhase {
                case .active:
                    Task {
                        await authenticationManager.handleAppResume()
                    }
                case .background:
                    break
                default:
                    break
                }
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}


