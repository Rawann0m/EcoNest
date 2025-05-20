//
//  AuthViewTest.swift
//  EcoNest
//
//  Created by Rawan on 18/05/2025.
//

import XCTest

final class AuthViewPageUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
//    func testNavigateToWelcome() {
//
//        // Wait until MainTabView or something in it appears
//        let welcome = app.otherElements["Welcome"]
//        XCTAssertTrue(welcome.waitForExistence(timeout: 5), "Welcome didn't appear in time")
//    }
//    
//    func testNavigateToMainTabView() {
//        testNavigateToWelcome()
//        // Wait until MainTabView or something in it appears
//        let mainTab = app.otherElements["MainTabView"]
//        XCTAssertTrue(mainTab.waitForExistence(timeout: 5), "MainTabView didn't appear in time")
//    }
    
    func waitForMainTabView() {
        let welcome = app.otherElements["Welcome"]
        if welcome.waitForExistence(timeout: 3) {
            // Wait for Welcome to disappear and MainTabView to appear
            let mainTab = app.otherElements["MainTabView"]
            XCTAssertTrue(mainTab.waitForExistence(timeout: 5), "MainTabView didn't appear after Welcome screen")
        } else {
            // Fallback in case Welcome screen is skipped for some reason
            let mainTab = app.otherElements["MainTabView"]
            XCTAssertTrue(mainTab.waitForExistence(timeout: 5), "MainTabView didn't appear")
        }
    }
    
    func testNavigateToLoginFromAlert() {
        waitForMainTabView()
        // Step 1: Tap the plus button
        let plusButton = app.buttons["AddToCart_Peace Lily"]
        XCTAssertTrue(plusButton.waitForExistence(timeout: 1), "Plus button not found")
        plusButton.tap()
        // Step 2: Wait for alert and tap Login
        let loginButton = app.alerts.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5), "Login alert button not found")
        loginButton.tap()

        // Step 3: Confirm navigation to login screen
        let loginEmail = app.textFields["LoginEmail"]
        XCTAssertTrue(loginEmail.waitForExistence(timeout: 5), "Login screen did not appear")
    }
    
//    func navigateToLoginFromAlert() {
//        waitForMainTabView()
//
//        let plusButton = app.buttons["AddToCart_Peace Lily"]
//        XCTAssertTrue(plusButton.waitForExistence(timeout: 3), "Plus button not found")
//        plusButton.tap()
//
//        let loginButton = app.alerts.buttons["Login"]
//        XCTAssertTrue(loginButton.waitForExistence(timeout: 3), "Login alert button not found")
//        loginButton.tap()
//
//        let loginEmail = app.textFields["LoginEmail"]
//        XCTAssertTrue(loginEmail.waitForExistence(timeout: 5), "Login screen did not appear")
//    }


    // MARK: - Login Tests

    func testLoginUIElementsExist() {
        testNavigateToLoginFromAlert()
        XCTAssertTrue(app.textFields["LoginEmail"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.secureTextFields["LoginPassword"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.buttons["LoginTogglePasswordVisibility"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.buttons["LoginButton"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.buttons["ForgotPasswordButton"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.buttons["SwitchToSignUp"].waitForExistence(timeout: 1))
    }

    func testPasswordVisibilityToggleInLogin() {
        testNavigateToLoginFromAlert()
        let toggleButton = app.buttons["LoginTogglePasswordVisibility"]
        let exists = toggleButton.waitForExistence(timeout: 2)
        XCTAssertTrue(exists)
        toggleButton.tap()
    }

    func testLoginWithInvalidCredentialsShowsAlert() {
        testNavigateToLoginFromAlert()
        let emailField = app.textFields["LoginEmail"]
        let passwordField = app.secureTextFields["LoginPassword"]
        let loginButton = app.buttons["LoginButton"]

        emailField.tap()
        emailField.typeText("wrong@example.com")

        passwordField.tap()
        passwordField.typeText("badpassword")

        loginButton.tap()

        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.buttons["OK"].tap()
    }

    // MARK: - Navigation Tests
    
    func testSwitchToSignUpAndBack() {
        testNavigateToLoginFromAlert()
        app.buttons["SwitchToSignUp"].tap()
        XCTAssertTrue(app.textFields["SignUpName"].waitForExistence(timeout: 1))
        
        app.buttons["SwitchToLogin"].tap()
        XCTAssertTrue(app.textFields["LoginEmail"].waitForExistence(timeout: 1))
    }

    func testForgotPasswordNavigation() {
        testNavigateToLoginFromAlert()
        app.buttons["ForgotPasswordButton"].tap()

        let resetTitle = app.staticTexts["ResetPasswordTitle"]
        XCTAssertTrue(resetTitle.waitForExistence(timeout: 5))
    }

    // MARK: - Signup Tests

    func testSignUpWithoutNameShowsAlert() {
        testNavigateToLoginFromAlert()
        app.buttons["SwitchToSignUp"].tap()

        app.textFields["SignUpEmail"].tap()
        app.textFields["SignUpEmail"].typeText("new@example.com")

        app.secureTextFields["SignUpPassword"].tap()
        app.secureTextFields["SignUpPassword"].typeText("ValidPass123")

        app.secureTextFields["ConfirmPassword"].tap()
        app.secureTextFields["ConfirmPassword"].typeText("ValidPass123")

        app.buttons["SignUpButton"].tap()

        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.buttons["OK"].tap()
    }

    func testSignupPasswordMismatchShowsAlert() {
        testNavigateToLoginFromAlert()
        app.buttons["SwitchToSignUp"].tap()

        app.textFields["SignUpName"].tap()
        app.textFields["SignUpName"].typeText("Test User")

        app.textFields["SignUpEmail"].tap()
        app.textFields["SignUpEmail"].typeText("test@example.com")

        app.secureTextFields["SignUpPassword"].tap()
        app.secureTextFields["SignUpPassword"].typeText("Password123")

        app.secureTextFields["ConfirmPassword"].tap()
        app.secureTextFields["ConfirmPassword"].typeText("WrongPassword")

        app.buttons["SignUpButton"].tap()

        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.buttons["OK"].tap()
    }

    func testSignUpPasswordToggle() {
        testNavigateToLoginFromAlert()
        app.buttons["SwitchToSignUp"].tap()
        let toggle = app.buttons["SignUpTogglePasswordVisibility"]
        let toggleP = toggle.waitForExistence(timeout: 2)
        XCTAssertTrue(toggleP)
        toggle.tap()
    }

    // MARK: - Back Button

    func testBackButtonExistsAndTaps() {
        testNavigateToLoginFromAlert()
        app.buttons["LoginButton"].tap()
        let backButton = app.buttons["BackButton"]
        let button = backButton.waitForExistence(timeout: 2)
        XCTAssertTrue(button)
        backButton.tap()
    }
}
