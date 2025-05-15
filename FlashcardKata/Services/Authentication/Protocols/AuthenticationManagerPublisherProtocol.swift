//
//  AuthenticationManagerPublisherProtocol.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Protocol for AuthenticationManager to publish authentication-related events.

import Foundation

@MainActor
protocol AuthenticationManagerPublisherProtocol {
    var errorMessagePublisher: Published<String?>.Publisher { get }
    var authenticationStatePublisher: Published<AuthenticationState>.Publisher { get }
    var userIDPublisher: Published<String?>.Publisher { get }
    var authenticationToastPublisher: Published<Toast?>.Publisher { get }
}
