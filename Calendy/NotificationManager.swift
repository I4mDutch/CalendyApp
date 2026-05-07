//
//  NotificationManager.swift
//  Calendy
//

import Foundation
import UserNotifications
import SwiftData

class NotificationManager {
    static let shared = NotificationManager()

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    func scheduleNotifications(for periods: [Period]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        let calendar = Calendar.current

        // We only have 64 available slots for local notifications.
        for period in periods.prefix(64) {
            guard let course = period.course else { continue }

            // Schedule 5 minutes before
            let notificationTime = calendar.date(byAdding: .minute, value: -5, to: period.startTime) ?? period.startTime

            if notificationTime < Date() { continue }

            let content = UNMutableNotificationContent()
            content.title = "Next Class: \(course.name)"
            content.body = "Starts in 5 minutes in room \(course.room)"
            content.sound = .default

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            let request = UNNotificationRequest(identifier: period.id.uuidString, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request)
        }
    }
}
