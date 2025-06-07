//
//  NotificationManager.swift
//  Cora
//
//  Created by Mohammed Alsayed on 08/04/2025.
//

import Foundation

class NotificationManager: ObservableObject {
    @Published var notifications: [CoraNotification] = []

    static let shared = NotificationManager()

    private init() {
        load()
    }

    func addNotification(title: String, message: String) {
        let new = CoraNotification(title: title, message: message)
        notifications.insert(new, at: 0)
        save()
    }

    func clearAll() {
        notifications.removeAll()
        UserDefaults.standard.removeObject(forKey: "saved_notifications")
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(notifications) {
            UserDefaults.standard.set(data, forKey: "saved_notifications")
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: "saved_notifications") {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let decoded = try? decoder.decode([CoraNotification].self, from: data) {
                notifications = decoded
            }
        }
    }
}

