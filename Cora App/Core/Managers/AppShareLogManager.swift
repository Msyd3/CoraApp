//
//  AppShareLogManager.swift
//  Cora
//
//  Created by Mohammed Alsayed on 10/04/2025.
//

import SwiftUI

class AppShareLogManager: ObservableObject {
    static let shared = AppShareLogManager()
    
    @Published var logs: [AppShareLog] = []
    
    init() {
        load()
    }
    
    func add(log: AppShareLog) {
        logs.append(log)
        save()
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(data, forKey: "app_share_logs")
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: "app_share_logs"),
           let decoded = try? JSONDecoder().decode([AppShareLog].self, from: data) {
            logs = decoded
        }
    }
}
