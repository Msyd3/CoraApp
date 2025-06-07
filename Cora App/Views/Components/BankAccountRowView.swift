//
//  BankAccountRowView.swift
//  Cora
//
//  Created by Mohammed Alsayed on 01/05/2025.
//

import SwiftUI

struct BankAccountRowView: View {
    let account: BankAccount
    let isPrimary: Bool
    var onSetPrimary: () -> Void
    var onDelete: () -> Void
    
    @State private var isSettingPrimary = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(account.fullname)
                    .customFont(size: 16, weight: "Rubik-Medium")
                Text(account.iban)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(account.bank)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            Spacer()
            
            if isPrimary {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(Color("Greend"))
            }
            
            Menu {
                Button {
                    setPrimaryAccount()
                } label: {
                    if isSettingPrimary {
                        ProgressView()
                    } else {
                        Text("Set Primary")
                    }
                }
                
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .padding(.horizontal, 6)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    func setPrimaryAccount() {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/endUser/bank-accounts/set-primary-bank-account") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let body = ["bank_account_id": account.id]
        request.httpBody = try? JSONEncoder().encode(body)
        
        isSettingPrimary = true
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSettingPrimary = false
            }
            
            guard let data = data,
                  let responseString = String(data: data, encoding: .utf8),
                  responseString == "true" else {
                print("❌ Failed to set primary account or invalid response")
                return
            }
            
            DispatchQueue.main.async {
                onSetPrimary()
            }
        }.resume()
    }
    
    func deleteAccount() {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/endUser/bank-accounts/delete-bank-account") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body = ["bank_account_id": account.id]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request error:", error)
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status code:", httpResponse.statusCode)
            }

            guard let data = data,
                  let responseString = String(data: data, encoding: .utf8) else {
                print("❌ No response data or decoding failed")
                return
            }

            print("📩 Response string:", responseString)

       
            if !responseString.isEmpty {
                DispatchQueue.main.async {
                    onDelete()
                }
            } else {
                print("❌ Empty response string")
            }
        }.resume()
    }
}
