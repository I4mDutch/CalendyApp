//
//  ContentView.swift
//  Calendy
//
//  Created by Caden Erwin on 5/7/26.
//

import SwiftUI
import SwiftData
import Combine

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var courses: [Course]
    @Query private var periods: [Period]
    @Query private var schoolDays: [SchoolDay]

    @State private var showingAddCourse = false
    @State private var showingSettings = false
    @State private var scheduleManager: ScheduleManager?

    var currentPeriod: Period? {
        scheduleManager?.getCurrentPeriod()
    }

    var nextPeriod: Period? {
        scheduleManager?.getNextPeriod()
    }

    var currentDayType: String {
        scheduleManager?.getDayType(for: Date()) ?? "None"
    }

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            List {
                if courses.isEmpty {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Welcome to Calendy!")
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("Get started by adding your first course and setting up your schedule in Settings.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Button("Add My First Course") {
                                showingAddCourse = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 8)
                    }
                }

                Section("Now") {
                    if let period = currentPeriod {
                        PeriodRow(period: period, isCurrent: true)
                    } else {
                        Text("No class right now")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Next") {
                    if let period = nextPeriod {
                        PeriodRow(period: period, isCurrent: false)
                    } else {
                        Text("No more classes today")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Today's Schedule (\(currentDayType))") {
                    if currentDayType == "None" {
                        Text("Please assign a Day Type in Settings to see today's schedule.")
                            .font(.callout)
                            .foregroundStyle(.orange)
                    } else {
                        let todayPeriods = scheduleManager?.getPeriods(for: Date()) ?? []
                        if todayPeriods.isEmpty {
                            Text("No classes scheduled for today")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(todayPeriods) { period in
                                PeriodRow(period: period, isCurrent: period.id == currentPeriod?.id)
                            }
                        }
                    }
                }

                Section("All Courses") {
                    if courses.isEmpty {
                        Text("No courses added yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(courses) { course in
                            HStack {
                                Circle()
                                    .fill(course.color)
                                    .frame(width: 12, height: 12)
                                VStack(alignment: .leading) {
                                    Text(course.name)
                                        .font(.headline)
                                    Text("\(course.periods.count) periods scheduled")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete(perform: deleteCourses)
                    }
                }
            }
            .navigationTitle("Calendy")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddCourse = true
                    } label: {
                        Label("Add Course", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCourse) {
                AddCourseView()
            }
            .sheet(isPresented: $showingSettings) {
                NavigationStack {
                    ScheduleSettingsView()
                        .toolbar {
                            Button("Done") { showingSettings = false }
                        }
                }
            }
            .onReceive(timer) { _ in
                updateLiveActivity()
            }
            .onChange(of: periods) {
                refreshBackgroundTasks()
            }
            .onChange(of: schoolDays) {
                refreshBackgroundTasks()
            }
            .onAppear {
                refreshBackgroundTasks()
                updateLiveActivity()
            }
        }
    }

    private func updateLiveActivity() {
        if let current = currentPeriod {
            LiveActivityManager.shared.updateOrCreateActivity(for: current)
        } else {
            LiveActivityManager.shared.endAllActivities()
        }
    }

    private func deleteCourses(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(courses[index])
        }
    }

    private func refreshBackgroundTasks() {
        if scheduleManager == nil {
            scheduleManager = ScheduleManager(modelContext: modelContext)
        }
        let upcoming = scheduleManager?.getAllUpcomingPeriods() ?? []
        NotificationManager.shared.scheduleNotifications(for: upcoming)
    }
}

struct PeriodRow: View {
    let period: Period
    let isCurrent: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(period.course?.name ?? "Unknown")
                    .font(.headline)
                    .foregroundStyle(isCurrent ? .primary : .secondary)
                Text("\(period.startTime, style: .time) - \(period.endTime, style: .time)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if let room = period.course?.room {
                Text(room)
                    .font(.subheadline)
                    .padding(6)
                    .background(period.course?.color.opacity(0.2) ?? .gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Course.self, Period.self, SchoolDay.self], inMemory: true)
}
