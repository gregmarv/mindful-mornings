//
//  Mindful_MorningsUITests.swift
//  Mindful MorningsUITests
//
//  Created by Gregory Marvin on 6/12/24.
//

import XCTest

class MindfulMorningsAppUITests: XCTestCase {

    func testDonateFlow() {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Donate"].tap()
        let donateTextField = app.textFields["Enter donation amount"]
        donateTextField.tap()
        donateTextField.typeText("20.00")

        app.buttons["Donate"].tap()
        
        // Handle in-app purchase flow here.
        // This example assumes the test stops here as IAP flow would be difficult to automate.
    }

    func testLoginFlow() {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Get Started"].tap()

        let emailTextField = app.textFields["Email"]
        emailTextField.tap()
        emailTextField.typeText("test@example.com")

        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("password")

        app.switches["Enable Face ID"].tap()

        app.buttons["Login"].tap()
        
        // Verify that login was successful, e.g., by checking if the home screen is displayed.
    }
    
    func testMantraSelectionFlow() {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Get Started"].tap()
        app.buttons["Continue"].tap()

        app.buttons["Use Custom Mantras"].tap()
        
        let firstMantraTextField = app.textFields["Enter mantra"]
        firstMantraTextField.tap()
        firstMantraTextField.typeText("My custom mantra")

        app.buttons["Add More"].tap()
        let secondMantraTextField = app.textFields["Enter mantra"].element(boundBy: 1)
        secondMantraTextField.tap()
        secondMantraTextField.typeText("Another custom mantra")

        app.buttons["Save Mantras"].tap()

        // Verify that the mantras were saved successfully.
    }
}
