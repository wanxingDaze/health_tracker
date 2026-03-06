//
//  WeightStore.swift
//  HealthTracker
//
//  体重数据持久化
//

import Foundation
import SwiftUI

@MainActor
class WeightStore: ObservableObject {
    @Published var records: [WeightRecord] = []
    
    private let saveKey = "WeightRecords"
    
    init() {
        load()
    }
    
    func add(_ record: WeightRecord) {
        records.insert(record, at: 0)
        save()
    }
    
    func delete(_ record: WeightRecord) {
        records.removeAll { $0.id == record.id }
        save()
    }
    
    func delete(at offsets: IndexSet) {
        records.remove(atOffsets: offsets)
        save()
    }
    
    func update(_ record: WeightRecord) {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
            save()
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([WeightRecord].self, from: data) else {
            return
        }
        records = decoded.sorted { $0.date > $1.date }
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    var latestWeight: Double? {
        records.first?.weight
    }
}
