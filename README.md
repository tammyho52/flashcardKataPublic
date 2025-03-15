 <img src="https://github.com/tammyho52/flashcardKataImages/blob/596cd54533b5f818efe1dada76e0b360bb8c5a66/Icon-Light-1024x1024%20(5).png" width="100px" height="auto" style="border-radius:50%"> 
 
# Flashcard Kata

![swift-badge](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)
![firebase-badge](https://img.shields.io/badge/firebase-ffca28?style=for-the-badge&logo=firebase&logoColor=black)
![figma-badge](https://img.shields.io/badge/Figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white)

<div style="display: flex; gap: 10px; flex-wrap: wrap;">
  <img src="https://github.com/tammyho52/flashcardKataImages/blob/24b2827a2c31daed8731047eea97670683bba15a/01.png" width="150px" height="auto" style="border-radius: 15px;">
  <img src="https://github.com/tammyho52/flashcardKataImages/blob/24b2827a2c31daed8731047eea97670683bba15a/02.png" width="150px" height="auto" style="border-radius: 15px;">
  <img src="https://github.com/tammyho52/flashcardKataImages/blob/24b2827a2c31daed8731047eea97670683bba15a/03.png" width="150px" height="auto" style="border-radius: 15px;">
  <img src="https://github.com/tammyho52/flashcardKataImages/blob/24b2827a2c31daed8731047eea97670683bba15a/04.png" width="150px" height="auto" style="border-radius: 15px;">
  <img src="https://github.com/tammyho52/flashcardKataImages/blob/24b2827a2c31daed8731047eea97670683bba15a/05.png" width="150px" height="auto" style="border-radius: 15px;">
</div>

[Youtube: Watch Video of Read Tab functionality here](https://youtu.be/4bl6CohKzxk)

[Youtube: Watch Video of Review Tab functionality here](https://youtu.be/3dfcb6wLR2E)

## Overview

Create and study flashcards your way through our unique review sessions (Kata)!

Unlock your full learning potential with Flashcard Kata, the flashcard app designed to make studying more engaging and efficient. Whether you’re mastering a new language, preparing for exams, or reinforcing key concepts, Flashcard Kata helps you learn smarter with flexible deck / flashcard creation and personalized review sessions.

You can download the app [here](https://apps.apple.com/us/app/flashcard-kata/id6741719150)!

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
- Authentication (password, Apple, Google) is implemented using Firebase Authentication, accessed via the Firebase iOS SDK.
- Backend data is stored in a Firebase Firestore database, accessed using the Firebase iOS SDK.
- Network requests are sent using URLRequest and called with Swift Concurrency.
- Design ensures the app remains scalable, maintainable, and easily extensible with reusable components.

## Architecture
<img src="https://github.com/tammyho52/flashcardKataImages/blob/730292387da6d6b84e04e6d152de87fef47c0fa9/FlashcardKataArchitectureDiagram.jpg" width="1000px" height="auto" style="border-radius: 15px;">

## Design Decisions

**MVVM with Services and Managers**

The MVVM (Model-View-ViewModel) pattern was chosen for testability, maintainability, and scalability. 
- Views (primarily SwiftUI-based) handle UI presentation.
- ViewModels manages UI logic and state.
- Models represent data structures.

MVVM components are structured based on the below:
- `LandingPageScreen` (pre-authentication)
- By `HomeScreen` tabs (post-authentication)
- Shared components for reusability 

To further enhance separation of concerns, the app utilizes Managers and Services. 
- Managers abstract external dependencies like Firebase Firestore for database storage and Firebase Authentication, and handle individualized features like search and caching. 
- Services include specific functionalities, such as:
  - Displaying web view and handling debouncing
  - `FirestoreService` is a reusable service that prevents redundant Firestore CRUD implementations. Models that interact with Firestore each build separate services using `FirestoreService`.
  - `DatabaseManager` is an abstraction layer that enables swapping database implementations with minimal impact.
  
---

**Component Breakdown**

To UI consistency and reusability, common views, components, and view modifiers are stored under the `Shared` folder. 

Notable reusable components include: 
- Default Empty Views & Guest Views
  - Handle cases where no user data exists (i.e. no decks or flashcards have been created) 
  - Supports guest user access (i.e. unauthenticated users)
- Bulk Actions such as reusable expand all and select all functionalities for decks and flashcards used for both `Read` and `Review` tabs.
- Themed Navigation Bar Style: `ColoredGlobalNavigationBarStyle` supports custom gradient backgrounds using 3 colors for each Tab. The navigation bar style dynamically adjusts to ensure content visibility behind the custom tab bar.

---

**Reusable Data & Helpers**
- `AppConstants` defines design, content, and color constants for consistency.
- Mock data supports Xcode previews for UI development. 
- Helpers provide self-contained utility functions like form validation, time conversion, and deck ordering.

---

**State Management**

The app leverages Swift Concurrency (async/await) for efficient state handling, with Combine used selectively for functions such as search bar updates, form field change monitoring with debouncing, and review session timer management.

SwiftUI property wrappers ensure reactive state updates:
- @State and @StateObject for UI-related state.
- @Binding, @Published, and ObservableObject for reactive data flow.

---

**Caching & Performance Optimization**

To reduce network requests and enhance performance, `CacheManager` implements a First In, First Out (FIFO) strategy for efficient data retrieval, prioritizing recently created and updated data. 

*Deck & Flashcard List Fetching Strategy*
- If cached data exists, Firestore fetches only new data based on the cache’s last updated date. The newly fetched and cached data are then displayed together.
- If cached data is unavailable or more data is needed beyond the cache size, the app loads 10 items at a time (matching Firestore’s pagination limit). If the cache is not full, newly fetched items are added to the cache.

---

**Error Handling**

The app uses custom error enums for structured error logging. User-friendly error messages are displayed using reusable toast components.

---

**Navigation**

Navigation follows a state-driven approach using NavigationStack, with modal views for actions that break from the core app flow. Smooth animations and transitions are primarily used to enhance user experience on the landing screen, review session screens, and flashcard flips & transitions.

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
This project is licensed under a **private license**. Unauthorized distribution, modification, or commercial use is prohibited. For inquiries about usage rights, please contact flashcardkata@gmail.com.  
