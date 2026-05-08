//
//  CalendyWidget.swift
//  Calendy
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    @MainActor
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), courseName: "Calculus", room: "A102")
    }

    @MainActor
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), courseName: "Calculus", room: "A102")
        completion(entry)
    }

    @MainActor
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let container = try? SharedContainer.create()

        var entries: [SimpleEntry] = []
        let currentDate = Date()

        guard let modelContext = container?.mainContext else {
            let entry = SimpleEntry(date: currentDate, courseName: "Error", room: "DB Fail")
            completion(Timeline(entries: [entry], policy: .atEnd))
            return
        }

        let scheduleManager = ScheduleManager(modelContext: modelContext)

        let next = scheduleManager.getNextPeriod()
        let current = scheduleManager.getCurrentPeriod()

        let displayPeriod = current ?? next

        let entry = SimpleEntry(
            date: currentDate,
            courseName: displayPeriod?.course?.name ?? "No Class",
            room: displayPeriod?.course?.room ?? "-"
        )
        entries.append(entry)

        let nextUpdate = displayPeriod?.endTime ?? Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let courseName: String
    let room: String
}

struct CalendyWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text("Next Class")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(entry.courseName)
                .font(.headline)
            Text(entry.room)
                .font(.subheadline)
        }
    }
}

struct CalendyWidget: Widget {
    let kind: String = "CalendyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                CalendyWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                CalendyWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Next Class")
        .description("See your next class period.")
    }
}
