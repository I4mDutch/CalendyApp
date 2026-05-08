//
//  CalendyApp.swift
//  Calendy
//
//  Created by Caden Erwin on 5/7/26.
//

import SwiftUI
import SwiftData

@main
struct CalendyApp: App {
    var sharedModelContainer: ModelContainer = SharedContainer.create()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    NotificationManager.shared.requestAuthorization()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
