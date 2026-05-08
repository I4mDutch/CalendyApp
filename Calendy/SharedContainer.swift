//
//  SharedContainer.swift
//  Calendy
//

import Foundation
import SwiftData

enum SharedContainer {
    static let groupIdentifier = "group.com.calendy"

    static func create() -> ModelContainer {
        let schema = Schema([
            Course.self,
            Period.self,
            SchoolDay.self,
        ])

        let modelConfiguration: ModelConfiguration
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier) {
            let url = groupURL.appendingPathComponent("Calendy.sqlite")
            modelConfiguration = ModelConfiguration(schema: schema, url: url)
        } else {
            modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        }

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
