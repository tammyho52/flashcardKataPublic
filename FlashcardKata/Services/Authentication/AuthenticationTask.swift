//
//  AuthenticationTask.swift
//  FlashcardKata
//
//  Created by Tammy Ho on 2/25/25.
//
//  A protocol representing tasks for user authentication.

protocol AuthenticationTask {
    func signIn() async throws
    func signUp() async throws
    func reauthenticate() async throws
}
