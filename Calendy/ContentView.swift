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
