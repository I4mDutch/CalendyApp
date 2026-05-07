//
//  CalendyLiveActivity.swift
//  Calendy
//

import ActivityKit
import WidgetKit
import SwiftUI

struct CalendyLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CalendyAttributes.self) { context in
            // Lock screen/notification UI goes here
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(context.state.courseName)
                            .font(.headline)
                        Text("Room \(context.state.room)")
                            .font(.subheadline)
                    }
                    Spacer()
                    Text(context.state.endTime, style: .timer)
                        .font(.title2)
                        .monospacedDigit()
                }
            }
            .padding()

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // leading/trailing/bottom components.
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.courseName)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.endTime, style: .timer)
                        .monospacedDigit()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Room \(context.state.room)")
                }
            } compactLeading: {
                Text(context.state.courseName.prefix(3))
            } compactTrailing: {
                Text(context.state.endTime, style: .timer)
                    .monospacedDigit()
            } minimal: {
                Text(context.state.courseName.prefix(1))
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}
