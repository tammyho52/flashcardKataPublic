//
//  LogError.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Function to log errors to Firebase Crashlytics.

import FirebaseCrashlytics

/// Logs an error to Firebase Crashlytics.
func reportError(
    _ error: Error,
    function: String = #function,
    file: String = #file,
    line: Int = #line
) {
    let fileName = (file as NSString).lastPathComponent
    Crashlytics.crashlytics().log("Error in \(fileName) at line \(line) in function \(function): \(error.localizedDescription)")
    Crashlytics.crashlytics().record(error: error)
}
