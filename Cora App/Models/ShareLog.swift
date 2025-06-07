//
//  ShareLog.swift
//  Cora
//
//  Created by Mohammed Alsayed on 23/03/2025.
//

import SwiftUI

struct ShareLog: Identifiable, Codable {
    var id = UUID()
    var tran_date_time: String
    var is_charge: Bool
    var amount: Double
    var is_liked: Bool
    var comments: [String]

  
    var type: String { is_charge ? "send" : "receive" }
    var place: String { is_charge ? "Sent" : "Received" }
    var date: Date {
        ISO8601DateFormatter().date(from: tran_date_time) ?? Date()
    }
}




