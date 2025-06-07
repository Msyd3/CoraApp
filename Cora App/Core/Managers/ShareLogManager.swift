//
//  ShareLogManager.swift
//  Cora
//
//  Created by Mohammed Alsayed on 23/03/2025.
//

import SwiftUI

class ShareLogManager: ObservableObject {
    static let shared = ShareLogManager()
    
    @Published var logs: [ShareLog] = []
    
    private var currentPhone: String {
        UserDefaults.standard.string(forKey: "phone_number") ?? "unknown_user"
    }
    
    private var userKey: String {
        "logs_\(currentPhone)"
    }
    
    init() {
        loadLogs(for: currentPhone)
    }
    
    func add(log: ShareLog) {
        logs.append(log)
        saveLogs(for: currentPhone)
    }
    
    func saveLogs(for phone: String) {
        let key = "logs_\(phone)"
        if let encoded = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func loadLogs(for phone: String) {
        let key = "logs_\(phone)"
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([ShareLog].self, from: data) {
            logs = decoded
        } else {
            logs = []
        }
    }
    
    func resetLogsIfNeeded() {
        let lastReset = UserDefaults.standard.object(forKey: "logs_reset_date_\(currentPhone)") as? Date ?? .distantPast
        if !Calendar.current.isDateInToday(lastReset) {
            logs = []
            saveLogs(for: currentPhone)
            UserDefaults.standard.set(Date(), forKey: "logs_reset_date_\(currentPhone)")
        }
    }
}
