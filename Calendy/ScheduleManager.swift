//
//  ScheduleManager.swift
//  Calendy
//

import Foundation
import SwiftData

@Observable
class ScheduleManager {
    var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func getDayType(for date: Date) -> String? {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let fetchDescriptor = FetchDescriptor<SchoolDay>(
            predicate: #Predicate { $0.date == startOfDay }
        )

        do {
            let days = try modelContext.fetch(fetchDescriptor)
            return days.first?.dayType
        } catch {
            print("Fetch failed: \(error)")
            return nil
        }
    }

    func getPeriods(for date: Date) -> [Period] {
        guard let dayType = getDayType(for: date) else { return [] }

        let fetchDescriptor = FetchDescriptor<Period>(
            predicate: #Predicate { $0.dayType == dayType },
            sortBy: [SortDescriptor(\.startTime)]
        )

        do {
            return try modelContext.fetch(fetchDescriptor)
        } catch {
            print("Fetch failed: \(error)")
            return []
        }
    }

    func getCurrentPeriod() -> Period? {
        let now = Date()
        let periods = getPeriods(for: now)

        return periods.first { period in
            let calendar = Calendar.current
            let nowComponents = calendar.dateComponents([.hour, .minute], from: now)
            let startComponents = calendar.dateComponents([.hour, .minute], from: period.startTime)
            let endComponents = calendar.dateComponents([.hour, .minute], from: period.endTime)

            let nowMinutes = nowComponents.hour! * 60 + nowComponents.minute!
            let startMinutes = startComponents.hour! * 60 + startComponents.minute!
            let endMinutes = endComponents.hour! * 60 + endComponents.minute!

            return nowMinutes >= startMinutes && nowMinutes < endMinutes
        }
    }

    func getNextPeriod() -> Period? {
        let now = Date()
        let periods = getPeriods(for: now)

        let calendar = Calendar.current
        let nowComponents = calendar.dateComponents([.hour, .minute], from: now)
        let nowMinutes = nowComponents.hour! * 60 + nowComponents.minute!

        return periods.first { period in
            let startComponents = calendar.dateComponents([.hour, .minute], from: period.startTime)
            let startMinutes = startComponents.hour! * 60 + startComponents.minute!

            return startMinutes > nowMinutes
        }
    }

    func getAllUpcomingPeriods() -> [Period] {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let fetchDescriptor = FetchDescriptor<SchoolDay>(
            predicate: #Predicate { $0.date >= startOfToday },
            sortBy: [SortDescriptor(\.date)]
        )

        var allPeriods: [Period] = []

        do {
            let days = try modelContext.fetch(fetchDescriptor)
            for day in days {
                let dayType = day.dayType
                let periodFetch = FetchDescriptor<Period>(
                    predicate: #Predicate { $0.dayType == dayType },
                    sortBy: [SortDescriptor(\.startTime)]
                )
                let dayPeriods = try modelContext.fetch(periodFetch)

                // We need to adjust the startTime/endTime to the actual date of the SchoolDay
                for period in dayPeriods {
                    let adjustedPeriod = createAdjustedPeriod(from: period, for: day.date)
                    allPeriods.append(adjustedPeriod)
                }
            }
        } catch {
            print("Fetch failed: \(error)")
        }

        return allPeriods.filter { $0.startTime > Date() }
    }

    private func createAdjustedPeriod(from period: Period, for date: Date) -> Period {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)

        var startComponents = calendar.dateComponents([.hour, .minute], from: period.startTime)
        startComponents.year = dateComponents.year
        startComponents.month = dateComponents.month
        startComponents.day = dateComponents.day

        var endComponents = calendar.dateComponents([.hour, .minute], from: period.endTime)
        endComponents.year = dateComponents.year
        endComponents.month = dateComponents.month
        endComponents.day = dateComponents.day

        let adjustedStart = calendar.date(from: startComponents) ?? period.startTime
        let adjustedEnd = calendar.date(from: endComponents) ?? period.endTime

        let newPeriod = Period(startTime: adjustedStart, endTime: adjustedEnd, dayType: period.dayType)
        newPeriod.course = period.course
        return newPeriod
    }
}
