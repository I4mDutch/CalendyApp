//
//  ScheduleSettingsView.swift
//  Calendy
//

import SwiftUI
import SwiftData

struct ScheduleSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var schoolDays: [SchoolDay]

    @State private var selectedDate = Date()
    @State private var selectedDayType = "A"

    var body: some View {
        Form {
            Section("Assign Day Type") {
                DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                Picker("Day Type", selection: $selectedDayType) {
                    Text("A Day").tag("A")
                    Text("B Day").tag("B")
                }
                Button("Assign") {
                    assignDay()
                }
            }

            Section("Assigned Days") {
                List {
                    ForEach(schoolDays.sorted(by: { $0.date < $1.date })) { day in
                        HStack {
                            Text(day.date, style: .date)
                            Spacer()
                            Text(day.dayType)
                                .fontWeight(.bold)
                        }
                    }
                    .onDelete(perform: deleteDays)
                }
            }
        }
        .navigationTitle("Schedule Settings")
    }

    private func assignDay() {
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)

        // Remove existing if any
        let descriptor = FetchDescriptor<SchoolDay>(predicate: #Predicate { $0.date == startOfDay })
        if let existing = try? modelContext.fetch(descriptor).first {
            modelContext.delete(existing)
        }

        let newDay = SchoolDay(date: selectedDate, dayType: selectedDayType)
        modelContext.insert(newDay)
    }

    private func deleteDays(offsets: IndexSet) {
        let sortedDays = schoolDays.sorted(by: { $0.date < $1.date })
        for index in offsets {
            modelContext.delete(sortedDays[index])
        }
    }
}
