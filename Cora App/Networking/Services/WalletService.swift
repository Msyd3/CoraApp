//
//  WalletService.swift
//  Cora
//
//  Created by Mohammed Alsayed on 14/05/2025.
//

import Foundation

struct WalletService {
    
    // 1. Setup Wallet Charge
    static func setupWalletCharge(amount: Int, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/endUser/wallet-charge-resolver/setup-wallet-charge") else {
            print("❌ خطأ: رابط API غير صالح")
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else {
            print("❌ No token found")
            completion(.failure(NSError(domain: "", code: -999)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = ["amount": amount]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let httpResponse = response as? HTTPURLResponse
            print("🔁 Status Code:", httpResponse?.statusCode ?? 0)
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1)))
                return
            }
            
            print("↩️ Raw response:", String(data: data, encoding: .utf8) ?? "No response")
            
            if httpResponse?.statusCode == 200,
               let transactionId = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\"", with: ""),
               !transactionId.isEmpty {
                completion(.success(transactionId))
            } else {
                completion(.failure(NSError(domain: "", code: httpResponse?.statusCode ?? -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response or transaction ID."])))
            }
            
        }.resume()
    }
    
    static func fetchCurrentBalance(completion: @escaping (Result<Double, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else {
            completion(.failure(NSError(domain: "", code: -401, userInfo: [NSLocalizedDescriptionKey: "Missing token"])))
            return
        }
        
        guard let url = URL(string: "\(APIConfig.baseURL)/api/endUser/wallet-transaction-history/check-current-balance") else {
            completion(.failure(NSError(domain: "", code: -400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -404, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            
            do {
                let balance = try JSONDecoder().decode(Double.self, from: data)
                completion(.success(balance))
            } catch {
                print("❌ Decode error:", error)
                print("↩️ Raw response:", String(data: data, encoding: .utf8) ?? "No response")
                completion(.failure(error))
            }
            
        }.resume()
    }
}

