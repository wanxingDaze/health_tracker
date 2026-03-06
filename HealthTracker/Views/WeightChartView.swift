//
//  WeightChartView.swift
//  HealthTracker
//
//  体重趋势图表
//

import SwiftUI
import Charts

struct WeightChartView: View {
    @EnvironmentObject var weightStore: WeightStore
    
    /// 图表数据：按日期正序（从左到右）
    private var chartData: [WeightRecord] {
        weightStore.records.sorted { $0.date < $1.date }
    }
    
    private var weightRange: (min: Double, max: Double) {
        guard !chartData.isEmpty else { return (0, 100) }
        let weights = chartData.map(\.weight)
        let minW = (weights.min() ?? 0) - 2
        let maxW = (weights.max() ?? 100) + 2
        return (max(0, minW), maxW)
    }
    
    var body: some View {
        if chartData.isEmpty {
            ContentUnavailableView {
                Label("暂无数据", systemImage: "chart.line.uptrend.xyaxis")
            } description: {
                Text("添加体重记录后即可查看趋势图")
            }
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("体重趋势")
                    .font(.headline)
                
                Chart(chartData) { record in
                    LineMark(
                        x: .value("日期", record.date),
                        y: .value("体重", record.weight)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.accentColor)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    PointMark(
                        x: .value("日期", record.date),
                        y: .value("体重", record.weight)
                    )
                    .foregroundStyle(.accentColor)
                    .symbolSize(40)
                }
                .chartYScale(domain: weightRange.min...weightRange.max)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: max(1, chartData.count / 5))) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic(desiredCount: 5)) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let w = value.as(Double.self) {
                                Text(String(format: "%.0f", w))
                            }
                        }
                    }
                }
                .frame(height: 200)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    let store = WeightStore()
    return WeightChartView()
        .environmentObject(store)
        .padding()
}
