//
//  Contact.swift
//  Cora
//
//  Created by Mohammed Alsayed on 02/05/2025.
//

import SwiftUI

struct Contact: Identifiable, Codable, Equatable {
    var id: String { beneficiary_id }
    let beneficiary_id: String
    let name: String
    let iban: String
}

