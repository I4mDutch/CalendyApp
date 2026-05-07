//
//  Models.swift
//  Calendy
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Course {
    var id: UUID
    var name: String
    var room: String
    var teacher: String
    var colorHex: String

    @Relationship(deleteRule: .cascade, inverse: \Period.course)
    var periods: [Period]

    init(name: String, room: String, teacher: String, colorHex: String = "#007AFF") {
        self.id = UUID()
        self.name = name
        self.room = room
        self.teacher = teacher
        self.colorHex = colorHex
        self.periods = []
    }

    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
}

@Model
final class Period {
    var id: UUID
    var startTime: Date
    var endTime: Date
    var dayType: String // "A", "B", "Mon", "Tue", etc.
    var course: Course?

    init(startTime: Date, endTime: Date, dayType: String) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = endTime
        self.dayType = dayType
    }
}

@Model
final class SchoolDay {
    var date: Date
    var dayType: String // "A", "B"

    init(date: Date, dayType: String) {
        self.date = Calendar.current.startOfDay(for: date)
        self.dayType = dayType
    }
}
