//
//  AppLogger.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Centralized logging mechanism using Apple's `os.log`.

import Foundation
import os.log

struct AppLogger {
    static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "FlashcardKata",
        category: "default"
    )

    static func logError(
        _ errorMessage: String,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent // Extract the file name from the full file path
        logger.error("ERROR in \(fileName) at line \(line) in function \(function): \(errorMessage)")
    }

    static func logInfo(_ message: String, function: String = #function, file: String = #file, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        logger.info("INFO in \(fileName) at line \(line) in function \(function): \(message)")
    }

    static func logDebug(_ message: String, function: String = #function, file: String = #file, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        logger.debug("DEBUG in \(fileName) at line \(line) in function \(function): \(message)")
    }

    static func logFault(_ message: String, function: String = #function, file: String = #file, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        logger.fault("FAULT in \(fileName) at line \(line) in function \(function): \(message)")
    }
}
