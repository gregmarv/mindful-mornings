//
//  Mindful_MorningsTests.swift
//  Mindful MorningsTests
//
//  Created by Gregory Marvin on 6/12/24.
//

import XCTest
@testable import Mindful_Mornings

class MindfulMorningsAppTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        // Isolated store per test so tests never read or wipe real app data.
        suiteName = "MindfulMorningsTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    private func makeUserData() -> UserData {
        UserData(defaults: defaults)
    }

    // MARK: - Seeding

    func testSeedExcludesGriefUnlessOptedIn() {
        let userData = makeUserData()
        userData.seedMantras(forFocusArea: "Finding calm")
        let grief = UserData.presetMantras.filter { $0.theme == "grief" }.map(\.text)
        XCTAssertEqual(userData.mantras.count, 25)
        XCTAssertTrue(grief.allSatisfy { !userData.mantras.contains($0) })
        XCTAssertEqual(userData.mantraWeights["I release what I can't control"], 1.3)
        XCTAssertEqual(userData.mantraWeights["I trust the process"], 1.0)
    }

    func testSeedIncludesGriefWhenProcessingLoss() {
        let userData = makeUserData()
        userData.seedMantras(forFocusArea: "Processing loss")
        XCTAssertEqual(userData.mantras.count, 30)
    }

    // MARK: - Mantra selection & curation

    func testWeightedRandomMantraReturnsDeckMember() {
        let userData = makeUserData()
        userData.mantras = ["A", "B", "C"]
        for _ in 0..<50 {
            XCTAssertTrue(userData.mantras.contains(userData.weightedRandomMantra()))
        }
    }

    func testWeightedRandomMantraRespectsExclusions() {
        let userData = makeUserData()
        userData.mantras = ["A", "B", "C"]
        for _ in 0..<50 {
            XCTAssertEqual(userData.weightedRandomMantra(excluding: ["A", "B"]), "C")
        }
    }

    func testWeightedRandomMantraWhenEmpty() {
        let userData = makeUserData()
        XCTAssertEqual(userData.weightedRandomMantra(), "No mantras available")
    }

    func testLikeAndSkipAreClamped() {
        let userData = makeUserData()
        userData.addCustomMantra("A")
        for _ in 0..<10 { userData.likeMantra("A") }
        XCTAssertEqual(userData.mantraWeights["A"], 3.0)
        for _ in 0..<20 { userData.skipMantra("A") }
        XCTAssertEqual(userData.mantraWeights["A"], 0.1)
    }

    func testAddCustomMantraTrimsAndDedupes() {
        let userData = makeUserData()
        userData.addCustomMantra("  New Mantra  ")
        userData.addCustomMantra("New Mantra")
        userData.addCustomMantra("   ")
        XCTAssertEqual(userData.mantras, ["New Mantra"])
        XCTAssertEqual(userData.mantraWeights["New Mantra"], 1.0)
    }

    func testRemoveMantraDropsWeight() {
        let userData = makeUserData()
        userData.addCustomMantra("A")
        userData.addCustomMantra("B")
        userData.removeMantra("A")
        XCTAssertEqual(userData.mantras, ["B"])
        XCTAssertNil(userData.mantraWeights["A"])
    }

    // MARK: - Focus area changes

    func testChangeFocusAreaKeepsCustomMantras() {
        let userData = makeUserData()
        userData.seedMantras(forFocusArea: "Finding calm")
        userData.addCustomMantra("My own")
        userData.changeFocusArea(to: "Processing loss")
        XCTAssertEqual(userData.focusArea, "Processing loss")
        XCTAssertTrue(userData.mantras.contains("My own"))
        XCTAssertEqual(userData.mantras.count, 31)

        userData.changeFocusArea(to: "Seeking growth")
        XCTAssertTrue(userData.mantras.contains("My own"))
        XCTAssertEqual(userData.mantras.count, 26)
    }

    // MARK: - Prompts

    func testDailyPromptIsStableAndSkipsGrief() {
        let userData = makeUserData()
        userData.focusArea = "Seeking growth"
        let first = userData.dailyPrompt(from: UserData.intentionPrompts)
        XCTAssertEqual(first, userData.dailyPrompt(from: UserData.intentionPrompts))
        let grief = UserData.intentionPrompts.filter { $0.themes.contains("grief") }.map(\.text)
        XCTAssertFalse(grief.contains(first))
    }

    // MARK: - Streaks

    func testStreakCountsConsecutiveDaysEndingToday() {
        let userData = makeUserData()
        let cal = Calendar.current
        let today = Date()
        for offset in [0, -1, -2, -4] {
            let day = cal.date(byAdding: .day, value: offset, to: today)!
            userData.completedDates.insert(UserData.dateKey(for: day))
        }
        XCTAssertEqual(userData.currentStreak, 3)
        XCTAssertTrue(userData.isCompleted(on: today))
    }

    func testStreakIsZeroWhenTodayNotDone() {
        let userData = makeUserData()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        userData.completedDates.insert(UserData.dateKey(for: yesterday))
        XCTAssertEqual(userData.currentStreak, 0)
    }

    func testDateKeyRoundTrips() {
        let key = UserData.dateKey(for: Date())
        XCTAssertNotNil(UserData.date(fromKey: key))
        XCTAssertEqual(UserData.dateKey(for: UserData.date(fromKey: key)!), key)
    }

    // MARK: - Reflections

    func testReflectionUpsertsTodaysEntry() {
        let userData = makeUserData()
        userData.addOrUpdateReflectionEntry(obligationsRating: 5, contentmentRating: 6)
        userData.addOrUpdateReflectionEntry(obligationsRating: 8, contentmentRating: 9)
        XCTAssertEqual(userData.reflectionEntries.count, 1)
        XCTAssertEqual(userData.reflectionEntryForToday()?.obligationsRating, 8)
        XCTAssertEqual(userData.reflectionEntryForToday()?.contentmentRating, 9)
    }

    // MARK: - Persistence & lifecycle

    func testStatePersistsAcrossInstances() {
        let userData = makeUserData()
        userData.seedMantras(forFocusArea: "Building gratitude")
        userData.focusArea = "Building gratitude"
        userData.markTodayComplete()
        userData.addOrUpdateReflectionEntry(obligationsRating: 7, contentmentRating: 7)
        userData.completeOnboarding()

        let reloaded = makeUserData()
        XCTAssertTrue(reloaded.isOnboarded)
        XCTAssertEqual(reloaded.focusArea, "Building gratitude")
        XCTAssertEqual(reloaded.mantras, userData.mantras)
        XCTAssertEqual(reloaded.mantraWeights, userData.mantraWeights)
        XCTAssertEqual(reloaded.currentStreak, 1)
        XCTAssertEqual(reloaded.reflectionEntries.count, 1)
    }

    func testResetAccount() {
        let userData = makeUserData()
        userData.seedMantras(forFocusArea: "Finding calm")
        userData.markTodayComplete()
        userData.completeOnboarding()
        userData.resetAccount()
        XCTAssertTrue(userData.mantras.isEmpty)
        XCTAssertTrue(userData.completedDates.isEmpty)
        XCTAssertFalse(userData.isOnboarded)
        XCTAssertEqual(userData.focusArea, "")
    }
}
