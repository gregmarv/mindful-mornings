//
//  Mindful_MorningsTests.swift
//  Mindful MorningsTests
//
//  Created by Gregory Marvin on 6/12/24.
//

import XCTest
@testable import Mindful_Mornings

class MindfulMorningsAppTests: XCTestCase {

    func testRandomMantra() {
        let userData = UserData()
        userData.mantras = ["Mantra 1", "Mantra 2", "Mantra 3"]
        let selectedMantra = userData.randomMantra()
        XCTAssertNotNil(selectedMantra)
        XCTAssertTrue(userData.mantras.contains(selectedMantra))
    }

    func testRandomMantraWhenEmpty() {
        let userData = UserData()
        userData.mantras = []
        let result = userData.randomMantra()
        XCTAssertEqual(result, "No mantras available")
    }

    func testSetPresetMantras() {
        let userData = UserData()
        let presetMantras: Set<String> = ["Mantra A", "Mantra B"]
        userData.setPresetMantras(presetMantras)
        XCTAssertEqual(Set(userData.mantras), presetMantras)
    }

    func testAddCustomMantra() {
        let userData = UserData()
        userData.mantras = []
        userData.addCustomMantra("New Mantra")
        XCTAssertEqual(userData.mantras, ["New Mantra"])
    }

    func testAddCustomMantraLimit() {
        let userData = UserData()
        userData.mantras = Array(repeating: "Mantra", count: 15)
        userData.addCustomMantra("One Too Many")
        XCTAssertEqual(userData.mantras.count, 15)
    }

    func testUpdateEmail() {
        let userData = UserData()
        userData.updateEmail("test@example.com")
        XCTAssertEqual(userData.email, "test@example.com")
    }

    func testUpdatePassword() {
        let userData = UserData()
        userData.updatePassword("newpassword")
        XCTAssertEqual(userData.password, "newpassword")
    }

    func testUpdateUseFaceID() {
        let userData = UserData()
        userData.updateUseFaceID(true)
        XCTAssertTrue(userData.useFaceID)
    }

    func testCompleteOnboarding() {
        let userData = UserData()
        XCTAssertFalse(userData.isOnboarded)
        userData.completeOnboarding()
        XCTAssertTrue(userData.isOnboarded)
    }

    func testResetAccount() {
        let userData = UserData()
        userData.email = "test@example.com"
        userData.mantras = ["Mantra 1"]
        userData.completeOnboarding()
        userData.resetAccount()
        XCTAssertEqual(userData.email, "")
        XCTAssertTrue(userData.mantras.isEmpty)
        XCTAssertFalse(userData.isOnboarded)
    }

    func testRemoveMantra() {
        let userData = UserData()
        userData.mantras = ["A", "B", "C"]
        userData.removeMantra(at: 1)
        XCTAssertEqual(userData.mantras, ["A", "C"])
    }

    func testRemoveMantraOutOfBounds() {
        let userData = UserData()
        userData.mantras = ["A"]
        userData.removeMantra(at: 5)
        XCTAssertEqual(userData.mantras, ["A"])
    }

    func testUpdateMantra() {
        let userData = UserData()
        userData.mantras = ["Old"]
        userData.updateMantra(at: 0, with: "New")
        XCTAssertEqual(userData.mantras, ["New"])
    }
}
