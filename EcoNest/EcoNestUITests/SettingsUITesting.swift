//
//  SettingsUITesting.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 22/11/1446 AH.
//

import XCTest

final class SettingsScreenTests: XCTestCase {
    let app = XCUIApplication()
    override func setUp() {
        continueAfterFailure = false
        app.launch()
//        app.buttons["Sign Up"].tap()
    }

    func testSettingFormFieldsExist() {
        XCTAssertTrue(app.textFields["Name"].exists)
    }
    
    func testSettingButtonExist() {
        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()
    }
    
}
