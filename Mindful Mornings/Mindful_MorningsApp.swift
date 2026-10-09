//
//  Mindful_MorningsApp.swift
//  Mindful Mornings
//
//  Created by Gregory Marvin on 6/12/24.
//

import SwiftUI
import StoreKit
import UserNotifications

@main
struct Mindful_MorningsApp: App {
    @StateObject private var userData = UserData()
    @State private var showReflectionSurvey = false
    @State private var transactionListener: Task<Void, Never>?

    init() {
        #if DEBUG
        // Pass `-resetState` as a launch argument (Edit Scheme → Run → Arguments) to wipe
        // all saved data and test onboarding from scratch. Off by default so streaks,
        // history and the heatmap can be tested across launches.
        if ProcessInfo.processInfo.arguments.contains("-resetState"),
           let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
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
                    if NotificationDelegate.shared.consumePendingReflectionSurvey() {
                        showReflectionSurvey = true
                    }
                }
                .onAppear {
                    if NotificationDelegate.shared.consumePendingReflectionSurvey() {
                        showReflectionSurvey = true
                    }
                }
                .task {
                    // Finish tip transactions that complete outside DonateView
                    // (Ask to Buy approvals, interrupted purchases, etc.).
                    guard transactionListener == nil else { return }
                    transactionListener = Task.detached {
                        for await update in Transaction.updates {
                            if case .verified(let transaction) = update {
                                await transaction.finish()
                            }
                        }
                    }
                }
        }
    }
}
