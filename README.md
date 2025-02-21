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

## Design + Development
- Implemented a design system for consistent styling throughout the app, including color palettes, button style, iconography, etc.
- Created wireframes by hand to plan the app's layout and flow, then used Figma to design app assets.
- Architecture: MVVM with Managers (Database, Authentication), Services (Firestore), and Helpers for better separation of concerns and maintainability.
- Frontend UI, consisting of 25+ screens and 20+ reusable components, is built with SwiftUI & UIKit.
- Authentication (password, Apple, Google) is implemented using Firebase Authentication, accessed via the Firebase iOS SDK.
- Backend data is stored in a Firebase Firestore database, accessed using the Firebase iOS SDK.
- Network requests are sent using URLRequest and called with Swift Concurrency.
- Design ensures the app remains scalable, maintainable, and easily extensible with reusable components.

## Setup Instructions
To get started with this project, please follow these steps:
1. Configure Project in Firebase: Add this app to your Firebase project and ensure the bundle identifier in the Xcode project matches the one in Firebase.

2. Add Google GoogleService-Info.plist: Download the GoogleService-Info.plist from your Firebase project settings and add this file to the Xcode project.
  
3. Add the GIDClientID Key to Info.plist: Add the following key-value pair to the Info.plist file. `<key>GIDClientID</key> <string>YOUR_CLIENT_ID</string>` (Replace YOUR_CLIENT_ID with the client_id value from your GoogleService-Info.plist file.)

4. Set up Firebase Authentication: In your Firebase Console, enable the required authentication methods: Email/Password Authentication, Google Authentication, and Apple Authentication.
  
5. Provisioning Profile Setup: Ensure that your app’s provisioning profile includes the following capabilities: Push Notifications, Sign In with Apple.
