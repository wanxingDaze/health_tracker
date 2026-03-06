//
//  ContentView.swift
//  HealthTracker
//
//  主界面 - 体重记录列表
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var weightStore: WeightStore
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            WeightListView()
                .navigationTitle("体重记录")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingAddSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                    }
                }
                .sheet(isPresented: $showingAddSheet) {
                    AddWeightView()
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WeightStore())
}
