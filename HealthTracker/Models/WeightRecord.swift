//
//  WeightRecord.swift
//  HealthTracker
//
//  体重记录数据模型
//

import Foundation

struct WeightRecord: Identifiable, Codable, Equatable {
    let id: UUID
    var weight: Double      // 体重 (kg)
    var date: Date
    var note: String?
    
    init(id: UUID = UUID(), weight: Double, date: Date = Date(), note: String? = nil) {
        self.id = id
        self.weight = weight
        self.date = date
        self.note = note
    }
    
    var formattedWeight: String {
        String(format: "%.1f kg", weight)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}
