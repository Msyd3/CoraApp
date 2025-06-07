//
//  BalanceManager.swift
//  Cora
//
//  Created by Mohammed Alsayed on 09/05/2025.
//

import SwiftUI
import Combine

class BalanceManager: ObservableObject {
    @Published var currentBalance: Double = 0.0

      init() {
          fetchCurrentBalance()
      }
    
    func fetchCurrentBalance() {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else {
            print("❌ No token found")
            return
        }
        
        guard let url = URL(string: "\(APIConfig.baseURL)/api/endUser/wallet-transaction-history/check-current-balance") else {
            print("❌ Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error fetching balance:", error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    return
                }
                
                do {
                    let balance = try JSONDecoder().decode(Double.self, from: data)
                    self.currentBalance = balance
                } catch {
                    print("❌ Decode error:", error)
                    print("↩️ Raw response:", String(data: data, encoding: .utf8) ?? "No response")
                }
            }
        }.resume()
    }
}
