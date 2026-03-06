//
//  AddWeightView.swift
//  HealthTracker
//
//  添加体重记录
//

import SwiftUI

struct AddWeightView: View {
    @EnvironmentObject var weightStore: WeightStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var weight: String = ""
    @State private var date = Date()
    @State private var note: String = ""
    @FocusState private var isWeightFocused: Bool
    
    private var weightValue: Double? {
        Double(weight.replacingOccurrences(of: ",", with: "."))
    }
    
    private var isValid: Bool {
        guard let w = weightValue else { return false }
        return w > 0 && w < 500
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        TextField("体重 (kg)", text: $weight)
                            .keyboardType(.decimalPad)
                            .focused($isWeightFocused)
                        Text("kg")
                            .foregroundStyle(.secondary)
                    }
                    .font(.title2)
                    
                    DatePicker("日期时间", selection: $date, displayedComponents: [.date, .hourAndMinute])
                } header: {
                    Text("体重")
                }
                
                Section {
                    TextField("备注（可选）", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("添加记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        save()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                isWeightFocused = true
            }
        }
    }
    
    private func save() {
        guard let w = weightValue, isValid else { return }
        let record = WeightRecord(weight: w, date: date, note: note.isEmpty ? nil : note)
        weightStore.add(record)
        dismiss()
    }
}

#Preview {
    AddWeightView()
        .environmentObject(WeightStore())
}
