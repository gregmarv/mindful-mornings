//
//  Mindful_MorningsApp.swift
//  Mindful Mornings
//
//  Created by Gregory Marvin on 6/12/24.
//

import SwiftUI
import UserNotifications

@main
struct Mindful_MorningsApp: App {
    @StateObject private var userData = UserData()
    @State private var showReflectionSurvey = false

    init() {
        #if DEBUG
        // Reset all state so the full flow can be tested from scratch.
        // Remove this block (or set to false) before submitting to the App Store.
        UserDefaults.standard.set(false, forKey: "isOnboarded")
        UserDefaults.standard.removeObject(forKey: "completedDates")
        UserDefaults.standard.removeObject(forKey: "userMantras")
        UserDefaults.standard.removeObject(forKey: "mantraWeights")
        UserDefaults.standard.removeObject(forKey: "focusArea")
        #endif
        // Register notification delegate before app finishes launching
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userData)
                .sheet(isPresented: $showReflectionSurvey) {
                    EveningReflectionSurveyView()
                        .environmentObject(userData)
                }
                .onReceive(NotificationCenter.default.publisher(for: .showReflectionSurvey)) { _ in
                    showReflectionSurvey = true
                }
        }
    }
}
