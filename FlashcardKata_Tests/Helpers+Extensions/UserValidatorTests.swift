//
//  UserValidatorTests.swift
//  FlashcardKataTests
//
//  Created by Tammy Ho.
//

import Testing

struct UserValidatorTests {

    @Test func testValidateIsNotEmpty_EmptyString() async throws {
        let fieldName = SignInSignUpField.name
        let emptyField = ""
        #expect(UserValidator.validateIsNotEmpty(emptyField, for: fieldName) == "Name is required")
    }
    
    @Test func testValidateIsNotEmpty_NonEmptyString() async throws {
        let fieldName = SignInSignUpField.name
        let nonEmptyField = "Guest"
        #expect(UserValidator.validateIsNotEmpty(nonEmptyField, for: fieldName) == nil)
    }
    
    @Test func testValidateIsTrue_TrueCondition() async throws {
        let fieldName = SignInSignUpField.agreedToLegal
        let trueCondition = true
        #expect(UserValidator.validateIsTrue(trueCondition, for: fieldName) == nil)
    }
    
    @Test func testValidateIsTrue_FalseCondition() async throws {
        let fieldName = SignInSignUpField.agreedToLegal
        let falseCondition = false
        #expect(UserValidator.validateIsTrue(falseCondition, for: fieldName) == "Please agree to the Legal Agreements to proceed.")
    }
    
    @Test func testValidateEmail_ValidEmail() async throws {
        let email = "test@example.com"
        #expect(UserValidator.validateEmail(email) == nil)
    }
    
    @Test func testValidateEmail_InvalidEmail() async throws {
        let invalidEmail = "invalid-email"
        #expect(UserValidator.validateEmail(invalidEmail) == "Invalid email address")
    }
    
    @Test func testValidateEmail_EmptyEmail() async throws {
        let emptyEmail = ""
        #expect(UserValidator.validateEmail(emptyEmail) == "Email is required")
    }
    
    @Test func testValidatePassword_ValidPassword() async throws {
        let validPassword = "password123"
        #expect(UserValidator.validatePassword(validPassword) == nil)
    }
    
    @Test func testValidatePassword_InvalidPassword() async throws {
        let invalidPassword = "short"
        #expect(UserValidator.validatePassword(invalidPassword) == "Password must be at least 8 characters long")
    }
    
    @Test func testValidatePassword_EmptyPassword() async throws {
        let emptyPassword = ""
        #expect(UserValidator.validatePassword(emptyPassword) == "Password is required")
    }
    
    @Test func testCheckPasswordMatch_MatchingPasswords() async throws {
        let password = "password123"
        let confirmPassword = "password123"
        #expect(UserValidator.checkPasswordMatch(password, confirmPassword: confirmPassword) == nil)
    }
    
    @Test func testCheckPasswordMatch_NonMatchingPasswords() async throws {
        let password = "password123"
        let confirmPassword = "differentPassword"
        #expect(UserValidator.checkPasswordMatch(password, confirmPassword: confirmPassword) == "Passwords do not match")
    }
    
    @Test func testCheckPasswordMatch_EmptyConfirmPassword() async throws {
        let password = "password123"
        let emptyConfirmPassword = ""
        #expect(UserValidator.checkPasswordMatch(password, confirmPassword: emptyConfirmPassword) == "Confirm Password is required")
    }
}
