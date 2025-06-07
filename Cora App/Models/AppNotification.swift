//
//  AppNotification.swift
//  Cora
//
//  Created by Mohammed Alsayed on 08/04/2025.
//

import Foundation

struct CoraNotification: Identifiable, Codable {
    let id: UUID
    let title: String
    let message: String
    let date: Date

    init(title: String, message: String, date: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.message = message
        self.date = date
    }
}
