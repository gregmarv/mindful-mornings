//
//  UserData.swift
//  Mindful Mornings
//
//  Created by Gregory Marvin on 6/13/24.
//

import Foundation
import SwiftUI

class UserData: ObservableObject {
    @Published var email: String {
        didSet { UserDefaults.standard.set(email, forKey: "userEmail") }
    }
    @Published var useFaceID: Bool {
        didSet { UserDefaults.standard.set(useFaceID, forKey: "useFaceID") }
    }
    @Published var mantras: [String] {
        didSet { UserDefaults.standard.set(mantras, forKey: "userMantras") }
    }
    @Published var isOnboarded: Bool {
        didSet { UserDefaults.standard.set(isOnboarded, forKey: "isOnboarded") }
    }
    @Published var eveningReflectionEnabled: Bool {
        didSet { UserDefaults.standard.set(eveningReflectionEnabled, forKey: "eveningReflectionEnabled") }
    }
    @Published var reflectionEntries: [ReflectionEntry] {
        didSet { saveReflectionEntries() }
    }
    @Published var completedDates: Set<String> {
        didSet { saveCompletedDates() }
    }

    // Password is not persisted for security reasons
    @Published var password: String = ""

    init() {
        self.email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        self.useFaceID = UserDefaults.standard.bool(forKey: "useFaceID")
        self.mantras = UserDefaults.standard.stringArray(forKey: "userMantras") ?? []
        self.isOnboarded = UserDefaults.standard.bool(forKey: "isOnboarded")
        self.eveningReflectionEnabled = UserDefaults.standard.bool(forKey: "eveningReflectionEnabled")
        self.reflectionEntries = UserData.loadReflectionEntries()
        self.completedDates = UserData.loadCompletedDates()
    }

    // MARK: - Mantra Management

    func addCustomMantra(_ mantra: String) {
        if mantras.count < 15 {
            mantras.append(mantra)
        }
    }

    func setPresetMantras(_ selectedMantras: Set<String>) {
        mantras = Array(selectedMantras)
    }

    func removeMantra(at index: Int) {
        guard mantras.indices.contains(index) else { return }
        mantras.remove(at: index)
    }

    func updateMantra(at index: Int, with newMantra: String) {
        guard mantras.indices.contains(index) else { return }
        mantras[index] = newMantra
    }

    func randomMantra() -> String {
        guard !mantras.isEmpty else { return "No mantras available" }
        return mantras.randomElement() ?? "No mantras available"
    }

    // MARK: - Account Management

    func updateEmail(_ newEmail: String) {
        email = newEmail
    }

    func updatePassword(_ newPassword: String) {
        password = newPassword
    }

    func updateUseFaceID(_ newValue: Bool) {
        useFaceID = newValue
    }

    func completeOnboarding() {
        isOnboarded = true
    }

    func resetAccount() {
        email = ""
        password = ""
        useFaceID = false
        mantras = []
        isOnboarded = false
        eveningReflectionEnabled = false
        reflectionEntries = []
        completedDates = []
    }

    // MARK: - Streak & Completion Tracking

    func markTodayComplete() {
        completedDates.insert(Self.dateKey(for: Date()))
    }

    func isCompleted(on date: Date) -> Bool {
        completedDates.contains(Self.dateKey(for: date))
    }

    var currentStreak: Int {
        var streak = 0
        let calendar = Calendar.current
        var checkDate = calendar.startOfDay(for: Date())

        // If today isn't done yet, still count streak from previous days
        while completedDates.contains(Self.dateKey(for: checkDate)) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }
        return streak
    }

    private static func dateKey(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    private func saveCompletedDates() {
        UserDefaults.standard.set(Array(completedDates), forKey: "completedDates")
    }

    private static func loadCompletedDates() -> Set<String> {
        let arr = UserDefaults.standard.stringArray(forKey: "completedDates") ?? []
        return Set(arr)
    }

    // MARK: - Rotating Journal Prompts

    static let helpPrompts: [String] = [
        "Who can I help, connect with, or positively impact today?",
        "What can I do today that I'll feel good about tonight?",
        "Who do I care about, and what could I do for them today?",
        "What's something worth doing today, even if it takes courage?",
    ]

    static let gratitudePrompts: [String] = [
        "What am I feeling grateful for today?",
        "What would I miss if it were gone tomorrow?",
        "What am I walking past every day without really noticing?",
        "What's going right that I haven't stopped to acknowledge?",
        "Who made my life a little easier recently without me saying thank you?",
        "What's one small, ordinary thing I'm glad exists?",
    ]

    /// Returns a prompt that's stable within a given day but rotates across days.
    static func dailyPrompt(from list: [String]) -> String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return list[dayOfYear % list.count]
    }

    // MARK: - Reflection Entry Management

    func addOrUpdateReflectionEntry(obligationsRating: Int, contentmentRating: Int) {
        let calendar = Calendar.current
        if let index = reflectionEntries.firstIndex(where: { calendar.isDateInToday($0.date) }) {
            reflectionEntries[index].obligationsRating = obligationsRating
            reflectionEntries[index].contentmentRating = contentmentRating
        } else {
            let entry = ReflectionEntry(
                date: calendar.startOfDay(for: Date()),
                obligationsRating: obligationsRating,
                contentmentRating: contentmentRating
            )
            reflectionEntries.append(entry)
        }
    }

    func reflectionEntryForToday() -> ReflectionEntry? {
        reflectionEntries.first { Calendar.current.isDateInToday($0.date) }
    }

    // MARK: - Reflection Persistence

    private func saveReflectionEntries() {
        if let encoded = try? JSONEncoder().encode(reflectionEntries) {
            UserDefaults.standard.set(encoded, forKey: "reflectionEntries")
        }
    }

    private static func loadReflectionEntries() -> [ReflectionEntry] {
        guard let data = UserDefaults.standard.data(forKey: "reflectionEntries"),
              let entries = try? JSONDecoder().decode([ReflectionEntry].self, from: data) else {
            return []
        }
        return entries
    }
}
