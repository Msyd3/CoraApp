//
//  AppShareLog.swift
//  Cora
//
//  Created by Mohammed Alsayed on 10/04/2025.
//

import SwiftUI

struct AppShareLog: Identifiable, Codable {
    let id = UUID()
    let message: String
    let date: Date
}
