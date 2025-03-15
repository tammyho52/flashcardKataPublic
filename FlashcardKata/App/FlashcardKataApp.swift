//
//  FlashcardKataApp.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Main entry point of App.
//  Initializes core services and manages app lifecycle.

import SwiftUI
import UIKit
import FirebaseCore
import FirebaseFirestoreInternal
import FirebaseAuth
import GoogleSignIn

@main
struct FlashcardKataApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.font) private var font
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authenticationManager: AuthenticationManager = AuthenticationManager()
    @StateObject var webViewService: WebViewService = WebViewService()

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
                        await authenticationManager.handleAppResume() // Restore session when app becomes active.
                    }
                case .background:
                    break // No background actions required
                default:
                    break
                }
            }
        }
    }
}

// Configure Firebase and Google Sign In
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        guard let clientID = FirebaseApp.app()?.options.clientID else { return false }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        return true
    }

    func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
