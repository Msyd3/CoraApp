//
//  WalletState.swift
//  Cora
//
//  Created by Mohammed Alsayed on 14/05/2025.
//

import Foundation

class WalletState: ObservableObject {
    @Published var transactionId: String?
    @Published var amount: Int?
    @Published var currency: String = "SAR"
    @Published var status: String = "pending"
    @Published var externalKey: String?
}
