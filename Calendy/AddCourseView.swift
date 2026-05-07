//
//  AddCourseView.swift
//  Calendy
//

import SwiftUI
import SwiftData

struct AddCourseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var room = ""
    @State private var teacher = ""
    @State private var colorHex = "#007AFF"

    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)
    @State private var dayType = "A"

    var body: some View {
        NavigationStack {
            Form {
                Section("Course Info") {
                    TextField("Name", text: $name)
                    TextField("Room", text: $room)
                    TextField("Teacher", text: $teacher)
                    ColorPicker("Color", selection: Binding(
                        get: { Color(hex: colorHex) ?? .blue },
                        set: { colorHex = $0.toHex() ?? "#007AFF" }
                    ))
                }

                Section("Period Info") {
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                    Picker("Day Type", selection: $dayType) {
                        Text("A Day").tag("A")
                        Text("B Day").tag("B")
                    }
                }
            }
            .navigationTitle("Add Course")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCourse()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func saveCourse() {
        let newCourse = Course(name: name, room: room, teacher: teacher, colorHex: colorHex)
        let newPeriod = Period(startTime: startTime, endTime: endTime, dayType: dayType)
        newPeriod.course = newCourse

        modelContext.insert(newCourse)
        modelContext.insert(newPeriod)

        dismiss()
    }
}
