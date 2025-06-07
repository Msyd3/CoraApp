//
//  BankAccount.swift
//  Cora
//
//  Created by Mohammed Alsayed on 28/05/2025.
//

import Foundation

struct BankAccount: Identifiable, Codable {
    var id: String { bank_account_id }

    let bank_account_id: String
    let fullname: String
    let iban: String
    let bank: String
    var is_primary: Bool

    private enum CodingKeys: String, CodingKey {
        case bank_account_id
        case fullname = "account_owner_fullname"
        case iban
        case bank = "bank_name_en"
        case is_primary
    }
}

