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
    @Published var mantraWeights: [String: Double] {
        didSet { saveMantraWeights() }
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
    @Published var focusArea: String {
        didSet { UserDefaults.standard.set(focusArea, forKey: "focusArea") }
    }

    // Password is not persisted for security reasons
    @Published var password: String = ""

    init() {
        self.email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        self.useFaceID = UserDefaults.standard.bool(forKey: "useFaceID")
        self.mantras = UserDefaults.standard.stringArray(forKey: "userMantras") ?? []
        self.mantraWeights = UserData.loadMantraWeights()
        self.isOnboarded = UserDefaults.standard.bool(forKey: "isOnboarded")
        self.eveningReflectionEnabled = UserDefaults.standard.bool(forKey: "eveningReflectionEnabled")
        self.reflectionEntries = UserData.loadReflectionEntries()
        self.completedDates = UserData.loadCompletedDates()
        self.focusArea = UserDefaults.standard.string(forKey: "focusArea") ?? ""
    }

    // MARK: - Mantra Management

    /// Seeds the mantra deck with presets. Focus-area mantras start at 1.3, others at 1.0.
    /// Grief-themed mantras are only included if the user selected "Processing loss."
    func seedMantras(forFocusArea area: String) {
        let theme = UserData.focusAreaToTheme[area] ?? ""
        var texts: [String] = []
        var weights: [String: Double] = [:]

        for m in UserData.presetMantras {
            // Suppress grief content unless user opted into it
            if m.theme == "grief" && theme != "grief" { continue }

            texts.append(m.text)
            let boost: Double = (!theme.isEmpty && m.theme == theme) ? 1.3 : 1.0
            weights[m.text] = boost
        }

        mantras = texts
        mantraWeights = weights
    }

    func addCustomMantra(_ mantra: String) {
        let trimmed = mantra.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !mantras.contains(trimmed) else { return }
        mantras.append(trimmed)
        mantraWeights[trimmed] = 1.0
    }

    func removeMantra(_ mantra: String) {
        mantras.removeAll { $0 == mantra }
        mantraWeights.removeValue(forKey: mantra)
    }

    /// Weighted random selection, excluding any already-seen mantras this session.
    func weightedRandomMantra(excluding: Set<String> = []) -> String {
        let available = mantras.filter { !excluding.contains($0) }
        guard !available.isEmpty else {
            // All exhausted — recycle from full deck
            return mantras.randomElement() ?? "No mantras available"
        }

        let weights = available.map { mantraWeights[$0] ?? 1.0 }
        let total = weights.reduce(0, +)
        guard total > 0 else { return available.randomElement() ?? "No mantras available" }

        var roll = Double.random(in: 0..<total)
        for (i, w) in weights.enumerated() {
            roll -= w
            if roll <= 0 { return available[i] }
        }
        return available.last ?? "No mantras available"
    }

    /// User liked this mantra — boost its weight.
    func likeMantra(_ mantra: String) {
        let current = mantraWeights[mantra] ?? 1.0
        mantraWeights[mantra] = min(current + 0.5, 3.0)
    }

    /// User skipped this mantra — reduce its weight.
    func skipMantra(_ mantra: String) {
        let current = mantraWeights[mantra] ?? 1.0
        mantraWeights[mantra] = max(current * 0.7, 0.1)
    }

    /// User permanently discarded this mantra.
    func discardMantra(_ mantra: String) {
        removeMantra(mantra)
    }

    // Legacy support
    func randomMantra() -> String {
        weightedRandomMantra()
    }

    // MARK: - Mantra Weight Persistence

    private func saveMantraWeights() {
        if let data = try? JSONEncoder().encode(mantraWeights) {
            UserDefaults.standard.set(data, forKey: "mantraWeights")
        }
    }

    private static func loadMantraWeights() -> [String: Double] {
        guard let data = UserDefaults.standard.data(forKey: "mantraWeights"),
              let weights = try? JSONDecoder().decode([String: Double].self, from: data) else {
            return [:]
        }
        return weights
    }

    // MARK: - Account Management

    func updateEmail(_ newEmail: String) { email = newEmail }
    func updatePassword(_ newPassword: String) { password = newPassword }
    func updateUseFaceID(_ newValue: Bool) { useFaceID = newValue }

    func completeOnboarding() {
        isOnboarded = true
    }

    func resetAccount() {
        email = ""
        password = ""
        useFaceID = false
        mantras = []
        mantraWeights = [:]
        isOnboarded = false
        eveningReflectionEnabled = false
        reflectionEntries = []
        completedDates = []
        focusArea = ""
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

    // MARK: - Themed Content

    struct ThemedPrompt {
        let text: String
        let themes: [String]
    }

    struct ThemedMantra {
        let text: String
        let theme: String
    }

    // MARK: - Preset Mantras (themed, 5 per theme + 5 general = 30 total)

    static let presetMantras: [ThemedMantra] = [
        // Calm
        ThemedMantra(text: "I choose presence over perfection", theme: "calm"),
        ThemedMantra(text: "I don't need everything to be perfect to have a good day", theme: "calm"),
        ThemedMantra(text: "I am allowed to slow down", theme: "calm"),
        ThemedMantra(text: "Peace is always one breath away", theme: "calm"),
        ThemedMantra(text: "I release what I can't control", theme: "calm"),
        // Grief
        ThemedMantra(text: "What I had was real, and it shaped who I am", theme: "grief"),
        ThemedMantra(text: "I am grateful for the time we had", theme: "grief"),
        ThemedMantra(text: "Love doesn't disappear — it becomes part of me", theme: "grief"),
        ThemedMantra(text: "I can carry what I've learned into today", theme: "grief"),
        ThemedMantra(text: "The good that came from what I loved is never lost", theme: "grief"),
        // Gratitude
        ThemedMantra(text: "I am grateful for this ordinary day", theme: "gratitude"),
        ThemedMantra(text: "There is enough good in today", theme: "gratitude"),
        ThemedMantra(text: "I choose to notice what's beautiful", theme: "gratitude"),
        ThemedMantra(text: "Every day holds something worth appreciating", theme: "gratitude"),
        ThemedMantra(text: "I already have so much", theme: "gratitude"),
        // Growth
        ThemedMantra(text: "I can do difficult things", theme: "growth"),
        ThemedMantra(text: "My actions today reflect my values", theme: "growth"),
        ThemedMantra(text: "I give my best to what matters most", theme: "growth"),
        ThemedMantra(text: "I am becoming who I want to be", theme: "growth"),
        ThemedMantra(text: "Progress, not perfection", theme: "growth"),
        // Connection
        ThemedMantra(text: "The people in my life are worth my full attention", theme: "connection"),
        ThemedMantra(text: "Today I will show up fully for myself and others", theme: "connection"),
        ThemedMantra(text: "Kindness costs nothing and changes everything", theme: "connection"),
        ThemedMantra(text: "I take care of what's mine to take care of", theme: "connection"),
        ThemedMantra(text: "Today I will be someone worth being around", theme: "connection"),
        // General
        ThemedMantra(text: "I choose how I respond to whatever comes my way", theme: ""),
        ThemedMantra(text: "I hold my plans loosely and my values firmly", theme: ""),
        ThemedMantra(text: "Today is a new beginning", theme: ""),
        ThemedMantra(text: "I trust the process", theme: ""),
        ThemedMantra(text: "I am enough, right now", theme: ""),
    ]

    // MARK: - Themed Journal Prompts (5 per theme + 5 general = 30 each)

    static let intentionPrompts: [ThemedPrompt] = [
        // Calm (5)
        ThemedPrompt(text: "What's one thing I can let go of today?", themes: ["calm"]),
        ThemedPrompt(text: "What would make today feel manageable, even if not perfect?", themes: ["calm"]),
        ThemedPrompt(text: "Where can I build in a moment of stillness today?", themes: ["calm"]),
        ThemedPrompt(text: "What's the one thing that actually needs my attention today?", themes: ["calm"]),
        ThemedPrompt(text: "What boundary can I set today to protect my peace?", themes: ["calm"]),
        // Grief (5)
        ThemedPrompt(text: "What's one gentle thing I can do for myself today?", themes: ["grief"]),
        ThemedPrompt(text: "How can I honor what I'm feeling without fighting it?", themes: ["grief"]),
        ThemedPrompt(text: "Who or what can I lean on today?", themes: ["grief"]),
        ThemedPrompt(text: "What small comfort can I give myself permission to enjoy today?", themes: ["grief"]),
        ThemedPrompt(text: "What would the person I'm missing want for me today?", themes: ["grief"]),
        // Gratitude (5)
        ThemedPrompt(text: "What ordinary moment am I going to pay closer attention to today?", themes: ["gratitude"]),
        ThemedPrompt(text: "Who deserves a thank you I haven't given yet?", themes: ["gratitude"]),
        ThemedPrompt(text: "What simple pleasure am I going to savor today?", themes: ["gratitude"]),
        ThemedPrompt(text: "How can I bring a little more joy into someone else's day?", themes: ["gratitude"]),
        ThemedPrompt(text: "What's something I usually rush through that I'll slow down for today?", themes: ["gratitude"]),
        // Growth (5)
        ThemedPrompt(text: "What's one important thing I want to accomplish today?", themes: ["growth"]),
        ThemedPrompt(text: "What would make me proud of myself at the end of today?", themes: ["growth"]),
        ThemedPrompt(text: "What's something worth doing today, even if it takes courage?", themes: ["growth"]),
        ThemedPrompt(text: "What's one small step I can take toward something I care about?", themes: ["growth"]),
        ThemedPrompt(text: "What habit am I trying to build, and how can I practice it today?", themes: ["growth"]),
        // Connection (5)
        ThemedPrompt(text: "Who can I help, connect with, or positively impact today?", themes: ["connection"]),
        ThemedPrompt(text: "Who do I care about, and what could I do for them today?", themes: ["connection"]),
        ThemedPrompt(text: "How can I be more present with the people I see today?", themes: ["connection"]),
        ThemedPrompt(text: "Who might need to hear from me today?", themes: ["connection"]),
        ThemedPrompt(text: "What's one way I can be a better listener today?", themes: ["connection"]),
        // General (5)
        ThemedPrompt(text: "What can I do today that I'll feel good about tonight?", themes: []),
        ThemedPrompt(text: "What does a good day look like for me today?", themes: []),
        ThemedPrompt(text: "What's one thing I'm going to do differently today?", themes: []),
        ThemedPrompt(text: "What matters most to me today?", themes: []),
        ThemedPrompt(text: "If I could only do one thing today, what would it be?", themes: []),
    ]

    static let gratitudePrompts: [ThemedPrompt] = [
        // Calm (5)
        ThemedPrompt(text: "What's one source of peace in my life right now?", themes: ["calm"]),
        ThemedPrompt(text: "What helped me get through a hard moment recently?", themes: ["calm"]),
        ThemedPrompt(text: "What part of my routine brings me the most comfort?", themes: ["calm"]),
        ThemedPrompt(text: "What's a place that always makes me feel safe?", themes: ["calm"]),
        ThemedPrompt(text: "What sound or smell instantly calms me?", themes: ["calm"]),
        // Grief (5)
        ThemedPrompt(text: "What's a quality I received from someone I miss?", themes: ["grief"]),
        ThemedPrompt(text: "What's still here that I'm grateful for, even in this season?", themes: ["grief"]),
        ThemedPrompt(text: "What moment of kindness has stayed with me?", themes: ["grief"]),
        ThemedPrompt(text: "What memory still makes me smile, even through the sadness?", themes: ["grief"]),
        ThemedPrompt(text: "Who has held space for me when I needed it most?", themes: ["grief"]),
        // Gratitude (5)
        ThemedPrompt(text: "What am I feeling grateful for today?", themes: ["gratitude"]),
        ThemedPrompt(text: "What's going right that I haven't stopped to acknowledge?", themes: ["gratitude"]),
        ThemedPrompt(text: "What's one small, ordinary thing I'm glad exists?", themes: ["gratitude"]),
        ThemedPrompt(text: "What am I walking past every day without really noticing?", themes: ["gratitude"]),
        ThemedPrompt(text: "What's something I take for granted that someone else would love to have?", themes: ["gratitude"]),
        // Growth (5)
        ThemedPrompt(text: "What challenge taught me something I'm now grateful for?", themes: ["growth"]),
        ThemedPrompt(text: "What's a strength I have that I don't give myself enough credit for?", themes: ["growth"]),
        ThemedPrompt(text: "What's something I can do now that I couldn't a year ago?", themes: ["growth"]),
        ThemedPrompt(text: "What difficult decision am I glad I made?", themes: ["growth"]),
        ThemedPrompt(text: "What's a habit I've built that I'm proud of?", themes: ["growth"]),
        // Connection (5)
        ThemedPrompt(text: "Who made my life a little easier recently?", themes: ["connection"]),
        ThemedPrompt(text: "What relationship am I most grateful for right now?", themes: ["connection"]),
        ThemedPrompt(text: "When did I last feel truly seen by someone?", themes: ["connection"]),
        ThemedPrompt(text: "What's a conversation that changed how I see things?", themes: ["connection"]),
        ThemedPrompt(text: "Who is someone that believes in me?", themes: ["connection"]),
        // General (5)
        ThemedPrompt(text: "What would I miss if it were gone tomorrow?", themes: []),
        ThemedPrompt(text: "What am I looking forward to?", themes: []),
        ThemedPrompt(text: "What happened recently that I want to remember?", themes: []),
        ThemedPrompt(text: "Who made my life a little easier recently without me saying thank you?", themes: []),
        ThemedPrompt(text: "What's the best thing that happened this week?", themes: []),
    ]

    /// Maps focus area display names to theme tags.
    static let focusAreaToTheme: [String: String] = [
        "Finding calm": "calm",
        "Processing loss": "grief",
        "Building gratitude": "gratitude",
        "Seeking growth": "growth",
        "Strengthening connections": "connection",
        "Just exploring": "",
    ]

    /// Returns a prompt that's stable within a given day, weighted toward the user's focus area.
    /// Grief-themed prompts are suppressed unless the user selected "Processing loss."
    func dailyPrompt(from list: [ThemedPrompt]) -> String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let theme = UserData.focusAreaToTheme[focusArea] ?? ""

        // Filter out grief content unless user opted in
        let eligible = (theme == "grief")
            ? list
            : list.filter { !$0.themes.contains("grief") }

        if !theme.isEmpty {
            let themed = eligible.filter { $0.themes.contains(theme) }
            let general = eligible.filter { !$0.themes.contains(theme) }

            if dayOfYear % 5 < 3, !themed.isEmpty {
                return themed[dayOfYear % themed.count].text
            } else if !general.isEmpty {
                return general[dayOfYear % general.count].text
            }
        }

        return eligible[dayOfYear % eligible.count].text
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
