//
//  Message.swift
//  Cora
//
//  Created by Mohammed Alsayed on 10/04/2025.
//

import Foundation

struct Message: Hashable, Codable, Identifiable {
    let id = UUID()
    let role: String // "user" or "assistant"
    let content: String
}
