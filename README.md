 <img src="https://github.com/tammyho52/flashcardKataImages/blob/596cd54533b5f818efe1dada76e0b360bb8c5a66/Icon-Light-1024x1024%20(5).png" width="100px" height="auto" style="border-radius:50%"> 
 
# Flashcard Kata

![swift-badge](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)
![firebase-badge](https://img.shields.io/badge/firebase-ffca28?style=for-the-badge&logo=firebase&logoColor=black)
![figma-badge](https://img.shields.io/badge/Figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white)

<div style="display: flex; gap: 10px; flex-wrap: wrap;">
  <img src="https://github.com/tammyho52/flashcardKataImages/blob/a08438bd4ed73a3ac78125b62aeb4ceb1bdcba7e/01.png" width="150px" height="auto" style="border-radius: 15px;">
  <img src="https://github.com/tammyho52/flashcardKataImages/blob/a08438bd4ed73a3ac78125b62aeb4ceb1bdcba7e/02.png" width="150px" height="auto" style="border-radius: 15px;">
  <img src="https://github.com/tammyho52/flashcardKataImages/blob/a08438bd4ed73a3ac78125b62aeb4ceb1bdcba7e/03.png" width="150px" height="auto" style="border-radius: 15px;">
  <img src="https://github.com/tammyho52/flashcardKataImages/blob/a08438bd4ed73a3ac78125b62aeb4ceb1bdcba7e/04.png" width="150px" height="auto" style="border-radius: 15px;">
  <img src="https://github.com/tammyho52/flashcardKataImages/blob/a08438bd4ed73a3ac78125b62aeb4ceb1bdcba7e/05.png" width="150px" height="auto" style="border-radius: 15px;">
</div>

[Youtube: Watch Video of Read Tab functionality here](https://youtu.be/4bl6CohKzxk)

[Youtube: Watch Video of Review Tab functionality here](https://youtu.be/3dfcb6wLR2E)

## Requirements

This project requires Xcode 16.0+, Swift 6.0+, and targets iOS 17.5+ or later.

## Overview

Create and study flashcards your way through our unique review sessions (Kata)!

Unlock your full learning potential with Flashcard Kata, the flashcard app designed to make studying more engaging and efficient. Whether you’re mastering a new language, preparing for exams, or reinforcing key concepts, Flashcard Kata helps you learn smarter with flexible deck / flashcard creation and personalized review sessions.

Download the app from the [App Store](https://apps.apple.com/us/app/flashcard-kata/id6741719150)!

## Features
- Create custom decks, subdecks, and flashcards: Organize your study materials however you like.
- Study at your own pace: Read and review flashcards at your leisure, without time pressure.
- Interactive study modes: Choose from 4 engaging study modes to review flashcards and reinforce learning.
- Track your progress: Monitor key metrics from your review sessions to see improvements over time.

## Design + Development Highlights
- Implemented a design system for consistent styling throughout the app, including color palettes, button style, iconography, etc.
- Created wireframes by hand to plan the app's layout and flow, then used Figma to design app assets.
- Architecture: MVVM with Managers (Database, Authentication), Services (Firestore), and Helpers for better separation of concerns and maintainability.
- Frontend UI, consisting of 25+ screens and 20+ reusable components, is built with SwiftUI & UIKit.
- Authentication (Apple, Google, email/password) is implemented using Firebase Authentication, accessed via the Firebase iOS SDK.
- Backend data is stored in a Firebase Firestore database, accessed using the Firebase iOS SDK.
- Network requests are sent using URLRequest and called with Swift Concurrency.
- Design ensures the app remains scalable, maintainable, and easily extensible with reusable components.

## Architecture
<img src="https://github.com/tammyho52/flashcardKataImages/blob/730292387da6d6b84e04e6d152de87fef47c0fa9/FlashcardKataArchitectureDiagram.jpg" width="1000px" height="auto" style="border-radius: 15px;">

## Design Decisions

**MVVM with Managers and Services**

The MVVM (Model-View-ViewModel) architectural pattern was chosen for maintainability, scalability, and testability.
- Views (primarily SwiftUI-based) handle UI presentation.
- ViewModels manage UI logic and state.
- Models represent data structures.

Each section of the app follows the MVVM structure:
- `LandingPageScreen`: Implements MVVM for pre-authentication features (e.g. sign up, sign in).
- `HomeScreen` tabs: Applies MVVM for post-authentication features (e.g. core deck and flashcard functionalities).
- Shared components: Provides common MVVM components to ensure consistency and reusability across the app.

To further enhance separation of concerns, the app utilizes Managers and Services. 
- Managers abstract external dependencies like Firebase Firestore for database storage and Firebase Authentication for user authentication, and manage individualized features like search and caching.
  - `DatabaseManager`: Abstraction layer that allows easy swapping of database implementations with minimal impact on the app.
  - `SearchBarManager`: Manages reusable search bar state across deck and flashcard lists, inluding the search text, search results, and search process state.
  - `CacheManager`: Provides reusable caching for items like decks and flashcards, optimizing data retrieval and performance. 
- Services encapsulate specific functionalities, such as:
  - `WebViewService`: Manages the display of web views for loading URLs, such as Terms & Conditions and Private Policy.
  - `DebouncerService`: Handles debounced form validation, reducing unnecessary processing by delaying validation checks.
  - `FirestoreService`: Provides a reusable service that centralizes Firestore CRUD operations, preventing redundant implementations. Services that interact with Firestore, such as `DeckService` and `FlashcardService`, inject `FirestoreService` as a dependency to manage data retrieval, updates, and persistence efficiently.
  
---

**Component Breakdown**

To ensure UI consistency and reusability, common views, components, and view modifiers are stored under the `Shared` folder. 

Notable reusable components include: 
- Customizable Default Empty Views & Guest Views:
  - `DefaultEmptyScreen`: Displays an empty state when no user data exists (e.g. no decks or flashcards have been created), with navigation buttons prompting the user to create new content.
  - `GuestDefaultScreen`: Supports guest user access (e.g. for unauthenticated users) and provides buttons to encourage account creation to unlock all app features.
- Bulk Actions:
  - `SelectAllScreen`: Provides reusable functionality, including `ExpandAllHelper` and `SelectAllHelper` for choosing decks and flashcard for review. This functionality is used across both `Read` and `Review` tabs.
- Themed Navigation Bar Style: 
  - `ColoredGlobalNavigationBarStyle`: Supports custom gradient backgrounds using 3 colors for each Tab. The navigation bar style dynamically adjusts the Tab's views to ensure content visibility behind the custom tab bar.

---

**Reusable Data & Helpers**
- `AppConstants`: Defines design, content, and color constants to ensure consistency across the app.
- Mock Data: Provides sample data to facilitate efficient Xcode previews for UI development. 
- Helpers: Provide self-contained utility functions for tasks such as form validation, time conversion, and deck ordering.

---

**State Management**

The app leverages Swift Concurrency (async/await) for efficient state handling, while Combine is used selectively for tasks like search bar updates, form field change monitoring with debouncing, and review session timer management.

SwiftUI property wrappers ensure reactive state updates:
- @State and @StateObject for UI-related state management.
- @Binding, @Published, @ObservedObject, and ObservableObject for reactive data flow.

---

**Caching & Performance Optimization**

To reduce network requests and enhance performance, `CacheManager` implements a First In, First Out (FIFO) strategy for efficient data retrieval, prioritizing recently created and updated data. 

*Deck & Flashcard List Fetching Strategy*
- If cached data exists, Firestore fetches only new data based on the cache’s last updated date. The newly fetched and cached data are then displayed together.
- If cached data is unavailable or more data is needed beyond the cache size, the app loads 10 items at a time (matching Firestore’s pagination limit). If the cache is not full, newly fetched items are added to the cache.

---

**Concurrency**

The app leverages Swift’s concurrency model to ensure smooth, responsive UI, and efficient background data operations:
- Async/Await: Used for all asynchronous tasks, especially fetching and updating data from Firebase, to prevent UI blocking.
- Main Actor: UI updates happen on the main actor, guaranteeing thread safety when interacting with views and state. The @MainActor attribute is also combined with @State properties as needed to ensure updates occur safely within a Task context.
- Background Processing: Intensive operations like data serialization and processing run off the main thread, ensuring smooth user interactions.

---

**Error Handling**
- The app uses Swift’s do-catch blocks and optional error propagation (try?, try!, throws) to gracefully handle failures during networking, data parsing, and authentication flows.
- Custom error enums are defined for structured error categorization. User-friendly error messages are surfaced through reusable toast components. 
- All caught errors are logged to Firebase Crashlytics using a custom utility (`reportError`) that captures the file name, line number, and function for context. This provides actionable insights into production issues without disrupting the user experience.

---

**Navigation**

Navigation follows a state-driven approach using NavigationStack, with modal views for actions that break from the core app flow. Smooth animations and transitions are primarily used to enhance user experience on the landing screen, review session screens, and flashcard flips & transitions.

---

**Testing**
- The testing strategy targets main user flows to verify core functionality and edge cases, achieving 55%+ test coverage (excluding third-party packages, mock data, and non-production code).
- Testing leverages both XCTest and Swift Testing frameworks across multiple levels:
  - Unit Tests cover Models, View Models, Managers, and Helpers
  - Integration Tests focus on Firestore backend interactions
  - UI Tests simulate main user actions
- Dependency injection and protocol-oriented design enable mocking of Firebase services, facilitating isolated tests. UI Tests use the Firebase Emulator Suite via launch arguments to simulate backend behavior locally.
- Key backend components like 'DatabaseManager' and 'AuthenticationManager' are wrapped in type-erased protocol-based abstractions, allowing seamless swapping between real and mock implementations during testing. This ensures UI and business logic can be tested independently from the backend.

---

**Memory Management**

The app follows best practices for memory management in Swift to ensure efficient resource use and prevent leaks.
- Uses Automatic Reference Counting (ARC) effectively by avoiding retain cycles with careful use of 'weak' and 'unowned' references, especially in closures and delegate patterns.
- ViewModels and Managers clean up listeners and observers properly to avoid memory leaks during lifecycle events.
- Instruments such as Xcode’s Memory Graph Debugger and Leaks tool are regularly used to detect and fix retain cycles and memory leaks during development. During development, Instruments were also used to monitor FPS and detect performance spikes during typical app flows, ensuring smooth UI performance.
- Heavy or asynchronous tasks are dispatched off the main thread to avoid blocking the UI and unnecessary memory pressure.

---

**Code Quality & Documentation**

- The project uses SwiftLint to enforce consistent Swift style and best practices, helping maintain readable and clean code.
- Code is documented with concise comments, including function-level and inline explanations, especially around special cases and complex logic.
- This approach ensures maintainability, ease of onboarding, and better collaboration.

---

**CI/CD and Automation**

The project includes Fastlane scripts to automate testing, build, and deployment workflows, aiming to streamline continuous integration and continuous deployment (CI/CD) processes. While GitHub Actions or other CI pipelines are not fully set up yet, these scripts enable consistent, repeatable testing and deployment with minimal manual intervention. Future work includes integrating these Fastlane scripts with CI services for fully automated pipelines.

---

**Firebase Emulator (for UI Testing)**

This project includes UI Testing support using the Firebase Emulator Suite. The following Firebase-related files are used to configure and run local emulators for Firestore, Authentication, and other services:
- firebase.json
- .firebaserc
- firestore.rules
- firebase-debug.log*

Important: The Firebase Emulator Suite must be running locally for UI tests to interact correctly with the mock backend. Please ensure your Firebase Emulator configuration matches the project’s setup. 
Note: These files are intended for local development only and do not contain any production credentials.

---

**Future Development**

- Enhance app flexibility by supporting pre-built decks and flashcards, configurable via an environment toggle to switch between user-generated content and curated pre-built data.
- Add offline browsing capabilities using CoreData for seamless study access without internet connectivity.
- Implement a spaced repetition system integrated with Notification Center to optimize review schedules and boost learning retention.
  
---

## Setup Instructions
**Option 1: Use Mock Data (Default Setup)**

By default, the app is configured to use mock data for previews. No external setup is required, and you can get started immediately.<br><br>

**Option 2: Setting up Google Firebase and Project Dependencies (Optional Setup)**

1. General Xcode Project Setup: Update the bundle identifier and connect your Apple Developer Account.

2. Configure the Project in Firebase: Add this app to your Firebase project and ensure the bundle identifier in the Xcode project matches the one in Firebase.

3. Add `GoogleService-Info.plist`: Download the `GoogleService-Info.plist` from your Firebase project settings and add this file to the Xcode project.
  
4. Configure `Info.plist`: In `Info.plist`, locate the `CFBundlesURLTypes` key and replace the value `com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID` with the `REVERSED_CLIENT_ID` from your `GoogleService-Info.plist` file.

5. Set up Firebase Authentication: In the Firebase Console, enable the required authentication methods: Apple Authentication, Email/Password Authentication, and Google Authentication.

6. Provisioning Profile Setup: Ensure that your app’s provisioning profile includes the necessary capabilities: Push Notifications, Sign In with Apple.

## License
This project is licensed under a **private license**. It is **not open source**. Unauthorized distribution, modification, or commercial use is prohibited. For inquiries about usage rights, please contact flashcardkata@gmail.com.  
