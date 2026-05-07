//
//  CalendyBundle.swift
//  Calendy
//

import WidgetKit
import SwiftUI

// Note: In a real Xcode project, this would be in a separate 'Widget Extension' target.
// @main is commented out here to avoid multiple entry point errors in the main app target.
// @main
struct CalendyBundle: WidgetBundle {
    var body: some Widget {
        CalendyWidget()
        CalendyLiveActivity()
    }
}
