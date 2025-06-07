//
//  TransactionViewModel.swift
//  Cora
//
//  Created by Mohammed Alsayed on 18/05/2025.
//

import Foundation
import Combine

class TransactionViewModel: ObservableObject {
    @Published var interactions: [TransactionInteraction] = []
    
    func fetchTransactions() {
        guard let url = URL(string: "https://\(APIConfig.baseURL)/api/endUser/wallet-transaction-history/fetch-wallet-trans-history") else {
            print("❌ رابط غير صالح")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer YOUR_TOKEN", forHTTPHeaderField: "Authorization") 
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ خطأ في الشبكة: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ لم يتم استلام بيانات")
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(TransactionResponse.self, from: data)
                DispatchQueue.main.async {
                    self.interactions = decoded.transactions_list.map {
                        TransactionInteraction(log: $0, likes: $0.is_liked ? 1 : 0, comments: $0.comments)
                    }
                }
            } catch {
                print("❌ خطأ في فك البيانات: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct TransactionResponse: Codable {
    var transactions_list: [ShareLog]
    var total_transactions_count: Int
}
