//
//  NotificationManager.swift
//  Mindful Mornings
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private let reflectionIdentifier = "evening-reflection"

    private init() {}

    // MARK: - Permission

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async { completion(settings.authorizationStatus) }
        }
    }

    // MARK: - Scheduling

    func scheduleEveningReflection(hour: Int = 20, minute: Int = 0) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [reflectionIdentifier])

        let content = UNMutableNotificationContent()
        content.title = "Evening Reflection"
        content.body = "How did your day go? Take a moment to reflect."
        content.sound = .default
        content.userInfo = ["type": "evening-reflection"]

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: reflectionIdentifier,
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    func cancelEveningReflection() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [reflectionIdentifier]
        )
    }
}

// MARK: - Notification Delegate

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    /// Set when the reflection notification is tapped. On a cold launch the tap can
    /// arrive before any view is subscribed to `.showReflectionSurvey`, so the app
    /// also checks this flag when its root view appears.
    private(set) var pendingReflectionSurvey = false

    private override init() {}

    /// Returns true (once) if a reflection-notification tap hasn't been handled yet.
    func consumePendingReflectionSurvey() -> Bool {
        defer { pendingReflectionSurvey = false }
        return pendingReflectionSurvey
    }

    // Show notification even when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    // Handle tap on notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let type = userInfo["type"] as? String, type == "evening-reflection" {
            pendingReflectionSurvey = true
            NotificationCenter.default.post(name: .showReflectionSurvey, object: nil)
        }
        completionHandler()
    }
}

// MARK: - Notification Name

extension Notification.Name {
    static let showReflectionSurvey = Notification.Name("showReflectionSurvey")
}
