//
//  WalletResponse.swift
//  Cora
//
//  Created by Mohammed Alsayed on 14/05/2025.
//

import Foundation

struct WalletSetupResponse: Codable {
    let transactionId: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        transactionId = try container.decode(String.self)
    }
}

