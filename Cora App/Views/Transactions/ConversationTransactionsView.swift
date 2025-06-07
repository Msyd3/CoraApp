//
//  ConversationTransactionsView.swift
//  Cora
//
//  Created by Mohammed Alsayed on 31/05/2025.
//

import SwiftUI

struct ConversationTransactionsView: View {
    let beneficiaryID: String
    @State private var interactions: [TransactionInteraction] = []
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                Text("Transactions")
                    .customFont(size: 16, weight: "Rubik-Regular")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.gray)
                    .padding(.top, 40)
                    .environment(\.layoutDirection, .rightToLeft)
                
                if interactions.isEmpty {
                    Text("No transactions available")
                        .customFont(size: 16, weight: "Rubik-Regular")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(interactions) { interaction in
                        TransactionCardView(interaction: binding(for: interaction))
                    }
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            fetchTransactions()
        }
        .refreshable {
            fetchTransactions()
        }
    }
    
    private func binding(for interaction: TransactionInteraction) -> Binding<TransactionInteraction> {
        guard let index = interactions.firstIndex(where: { $0.id == interaction.id }) else {
            return .constant(interaction)
        }
        return $interactions[index]
    }
    
    private func fetchTransactions() {
        guard var components = URLComponents(string: "\(APIConfig.baseURL)/api/endUser/beneficiaries/list-beneficiary-transactions") else { return }
        
        components.queryItems = [
            URLQueryItem(name: "beneficiary_id", value: beneficiaryID),
            URLQueryItem(name: "page_index", value: "1"),
            URLQueryItem(name: "page_size", value: "100")
        ]
        
        guard let url = components.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request error:", error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status code:", httpResponse.statusCode)
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            do {
                struct APIResponse: Decodable {
                    let transactions_count: Int
                    let transactions: [TransactionItem]
                }
                
                struct TransactionItem: Decodable {
                    let transaction_id: String
                    let amount: Double
                    let created_at: String
                    let is_outgoing: Bool
                }
                
                let decoded = try JSONDecoder().decode(APIResponse.self, from: data)
                
                DispatchQueue.main.async {
                    interactions = decoded.transactions.map {
                        let log = ShareLog(
                            tran_date_time: $0.created_at,
                            is_charge: $0.is_outgoing,
                            amount: $0.amount,
                            is_liked: false,
                            comments: []
                        )
                        return TransactionInteraction(log: log, likes: 0, comments: [])
                    }
                }
            } catch {
                print("❌ Decoding error:", error)
            }
        }.resume()
    }
}


#Preview {
    ConversationTransactionsView(beneficiaryID: "b2555b3f-6c2c-4434-95b7-4c6996265763")
}
