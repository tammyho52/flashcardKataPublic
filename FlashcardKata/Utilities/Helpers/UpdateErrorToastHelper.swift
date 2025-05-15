//
//  UpdateErrorToastHelper.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Helper function to update the error toast message.

import SwiftUI

/// Function to update the error toast message as app error or backup error.
func updateErrorToast(
    _ error: Error,
    errorToast: Binding<Toast?>,
    backupErrorMessage: String = AppError.systemError.message
) {
    if let appError = error as? AppError {
        errorToast.wrappedValue = Toast(style: .warning, message: appError.message)
    } else {
        errorToast.wrappedValue = Toast(style: .warning, message: backupErrorMessage)
    }
}

func sleepTaskForToast() async {
    try? await Task.sleep(nanoseconds: 3_000_000_000)
}

