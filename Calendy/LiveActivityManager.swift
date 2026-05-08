//
//  LiveActivityManager.swift
//  Calendy
//

import Foundation
import ActivityKit

class LiveActivityManager {
    static let shared = LiveActivityManager()

    private init() {}

    func updateOrCreateActivity(for period: Period) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        guard let course = period.course else { return }

        let state = CalendyAttributes.ContentState(
            courseName: course.name,
            room: course.room,
            endTime: period.endTime
        )

        if let activity = Activity<CalendyAttributes>.activities.first {
            Task {
                await activity.update(using: state)
            }
        } else {
            let attributes = CalendyAttributes(totalPeriods: 1)
            do {
                _ = try Activity.request(attributes: attributes, content: .init(state: state, staleDate: nil))
            } catch {
                print("Error starting live activity: \(error.localizedDescription)")
            }
        }
    }

    func endAllActivities() {
        for activity in Activity<CalendyAttributes>.activities {
            Task {
                await activity.end(dismissalPolicy: .immediate)
            }
        }
    }
}
