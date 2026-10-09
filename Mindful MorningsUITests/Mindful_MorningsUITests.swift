//
//  Mindful_MorningsUITests.swift
//  Mindful MorningsUITests
//
//  Created by Gregory Marvin on 6/12/24.
//

import XCTest

class MindfulMorningsAppUITests: XCTestCase {

    /// Fresh install → landing → value prop → carousel (skip) → focus → Home.
    func testOnboardingReachesHome() {
        let app = XCUIApplication()
        app.launchArguments = ["-resetState"]
        app.launch()

        app.buttons["Get Started"].tap()

        // Value-prop Continue fades in after ~2s.
        let valuePropContinue = app.buttons["Continue"]
        XCTAssertTrue(valuePropContinue.waitForExistence(timeout: 5))
        valuePropContinue.tap()

        let skip = app.buttons["Skip"]
        XCTAssertTrue(skip.waitForExistence(timeout: 3))
        skip.tap()

        let calm = app.buttons.containing(.staticText, identifier: "Finding calm").firstMatch
        XCTAssertTrue(calm.waitForExistence(timeout: 3))
        calm.tap()
        app.buttons["Continue"].tap()

        XCTAssertTrue(app.buttons["Start Today's Routine"].waitForExistence(timeout: 5))
    }
}
