//
//  CalendyAttributes.swift
//  Calendy
//

import Foundation
import ActivityKit

struct CalendyAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var courseName: String
        var room: String
        var endTime: Date
    }

    // Fixed non-changing properties about your activity go here!
    var totalPeriods: Int
}
