//
//  WeightListView.swift
//  HealthTracker
//
//  体重记录列表
//

import SwiftUI

struct WeightListView: View {
    @EnvironmentObject var weightStore: WeightStore
    
    var body: some View {
        Group {
            if weightStore.records.isEmpty {
                emptyState
            } else {
                listContent
            }
        }
    }
    
    private var emptyState: some View {
        ContentUnavailableView {
            Label("暂无记录", systemImage: "scalemass")
        } description: {
            Text("点击右上角 + 添加第一条体重记录")
        }
        .symbolRenderingMode(.hierarchical)
    }
    
    private var listContent: some View {
        List {
            Section {
                WeightChartView()
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowBackground(Color.clear)
            
            if let latest = weightStore.latestWeight {
                Section {
                    HStack {
                        Text("当前体重")
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.1f kg", latest))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.accentColor)
                    }
                    .listRowBackground(Color.accentColor.opacity(0.1))
                }
            }
            
            Section("历史记录") {
                ForEach(weightStore.records) { record in
                    WeightRowView(record: record)
                }
                .onDelete(perform: weightStore.delete)
            }
        }
    }
}

struct WeightRowView: View {
    let record: WeightRecord
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.formattedWeight)
                    .font(.headline)
                Text(record.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let note = record.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        WeightListView()
            .environmentObject(WeightStore())
    }
}
