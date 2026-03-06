//
//  HealthTrackerApp.swift
//  HealthTracker
//
//  体重记录 - iOS 健康追踪
//

import SwiftUI

@main
struct HealthTrackerApp: App {
    @StateObject private var weightStore = WeightStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(weightStore)
        }
    }
}
