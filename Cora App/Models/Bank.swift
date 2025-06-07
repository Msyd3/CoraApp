//
//  Bank.swift
//  Cora
//
//  Created by Mohammed Alsayed on 15/04/2025.
//

import Foundation

struct Bank: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let logo: String
    let code: String
}
