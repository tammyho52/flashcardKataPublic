//
//  FlashcardKataApp.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Entry point for the FlashcardKata app.
//  - Initializes core services and manages app lifecycle.
//  - Sets up Firebase and Google Sign-In configurations.
//  - Handles app lifecycle events such as entering background or foreground.
//  - Configures Firestore and Firebase Authentication (mock or real) for testing environments.

import SwiftUI
import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn

/// Main entry point for the FlashcardKata app.
/// Sets up the app's environment, including authentication and web view services.
@main
struct FlashcardKataApp: App {
    // MARK: - Environment & State Variables
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.font) private var font
    
    /// The app's delegate, responsible for handling Firebase and Google Sign-In configurations.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    /// Dependency injected authentication manager (mock or real based on environment).
    @StateObject var authenticationManager: AnyAuthenticationManager
    
    /// Shared service for rendering and managing in-app web content (e.g. help pages, external links).
    @StateObject var webViewService: WebViewService = WebViewService()
    
    // MARK: - Initialization
    /// Initializes the app with a mock or real authentication manager based on the environment.
    init() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-UITesting") {
            // Use mock authentication manager for UI testing
            _authenticationManager = StateObject(
                wrappedValue: AnyAuthenticationManager(
                    authenticationManager: MockFirebaseAuthenticationManager()
                )
            )
        } else {
            // Use real authentication manager for development
            _authenticationManager = StateObject(
                wrappedValue: AnyAuthenticationManager(
                    authenticationManager: FirebaseAuthenticationManager()
                )
            )
        }
        #else
        // Use real authentication manager for production
        _authenticationManager = StateObject(
            wrappedValue: AnyAuthenticationManager(
                authenticationManager: FirebaseAuthenticationManager()
            )
        )
        #endif
    }
    
    // MARK: - Scene Body
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
                        // Check if the user is already signed in and handles app resume.
                        await authenticationManager.handleAppResume()
                    }
                case .background:
                    // Optional: Handle app going to background
                    break
                default:
                    break
                }
            }
        }
    }
}

// MARK: - AppDelegate
/// Handles app launch and sets up Firebase and Google Sign-In configurations based on the current environment..
@MainActor
class AppDelegate: NSObject, UIApplicationDelegate {
    /// Called upon app launch.
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        #if DEBUG
        // Configure Firebase only if not running UI tests.
        if !ProcessInfo.processInfo.arguments.contains("-UITesting") {
            FirebaseApp.configure()

            if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
                configureFirebaseEnvironmentIfNeeded()
            }
            FirebaseConfiguration.shared.setLoggerLevel(.error)
            
            guard let clientID = FirebaseApp.app()?.options.clientID else { return false }
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }
        #else
        // Configure Firebase for production.
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.error)

        guard let clientID = FirebaseApp.app()?.options.clientID else { return false }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        #endif
        return true
    }
    
    /// Handles URL redirection for Google Sign-In.
    func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

#if DEBUG
/// Configures Firebase to connect to local emulators for testing purposes.
private func configureFirebaseEnvironmentIfNeeded() {
    setupFirestoreForTesting()
    setupFirebaseAuthForTesting()
}

// MARK: - Firebase Emulator Setup (Testing)
/// Sets up Firestore to use local emulator for testing.
private func setupFirestoreForTesting() {
    Firestore.firestore().useEmulator(withHost: "127.0.0.1", port: 8080)
    let settings = Firestore.firestore().settings
    settings.cacheSettings = MemoryCacheSettings(garbageCollectorSettings: MemoryLRUGCSettings())
    settings.isSSLEnabled = false
    Firestore.firestore().settings = settings
    
    print("Firestore emulator configured for testing.")
}

/// Sets up Firebase Authentication to use local emulator for testing.
private func setupFirebaseAuthForTesting() {
    Auth.auth().useEmulator(withHost:"127.0.0.1", port:9099)
}
#endif


