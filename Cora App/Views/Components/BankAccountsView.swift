//
//  BankAccountsView.swift
//  Cora
//
//  Created by Mohammed Alsayed on 01/05/2025.
//

import SwiftUI

struct BankAccountsView: View {
    @State private var bankAccounts: [BankAccount] = []
    @State private var primaryAccountID: String?
    @State private var showAddSheet = false
    @State private var showDeleteConfirmation = false
    @State private var accountToDelete: BankAccount?
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                buildContent()
            }
            
            Button(action: { showAddSheet = true }) {
                Text("Add Bank Account")
                    .customFont(size: 16, weight: "Rubik-Medium")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("Bur"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .environment(\.layoutDirection, .rightToLeft)
        .onAppear(perform: fetchBankAccounts)
        .sheet(isPresented: $showAddSheet) {
            AddBankAccountSheet { newAccount in
                bankAccounts.append(newAccount)
                showAddSheet = false
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .alert("Are you sure you want to delete this account?", isPresented: $showDeleteConfirmation, presenting: accountToDelete) { account in
            Button("Delete", role: .destructive) {
                bankAccounts.removeAll { $0.id == account.id }
                if primaryAccountID == account.id { primaryAccountID = nil }
            }
            Button("Cancel", role: .cancel) { }
        } message: { account in
            Text("This will remove the bank account for \(account.fullname).")
        }
    }
    
    @ViewBuilder
    private func buildContent() -> some View {
        VStack(alignment: .trailing, spacing: 16) {
            Text("Bank Accounts")
                .customFont(size: 24, weight: "Rubik-Bold")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 40)
            
            if bankAccounts.isEmpty {
                emptyState
            } else {
                ForEach(bankAccounts) { account in
                    BankAccountRowView(
                        account: account,
                        isPrimary: account.is_primary,
                        onSetPrimary: {
                            setPrimaryAccount(accountID: account.bank_account_id)
                        },
                        onDelete: {
                            accountToDelete = account
                            showDeleteConfirmation = true
                        }
                    )
                }
            }
            
            Spacer(minLength: 100)
        }
        .environment(\.layoutDirection, .rightToLeft)
        .padding(.top, 10)
    }
    
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image("empty")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .opacity(0.7)
            
            Text("Add your first account to receive payments")
                .customFont(size: 12, weight: "Rubik-Regular")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func fetchBankAccounts() {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else {
            print("❌ Missing auth token")
            return
        }
        
        var components = URLComponents(string: "\(APIConfig.baseURL)/api/endUser/bank-accounts/list-my-bank-accounts")!
        components.queryItems = [
            URLQueryItem(name: "page_index", value: "0"),
            URLQueryItem(name: "page_size", value: "10")
        ]
        
        guard let url = components.url else {
            print("❌ Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            if let raw = String(data: data, encoding: .utf8) {
                print("📦 Raw response: \(raw)")
            }
            
            do {
                let decoded = try JSONDecoder().decode(BankAccountsResponse.self, from: data)
                DispatchQueue.main.async {
                    self.bankAccounts = decoded.my_accounts
                    self.primaryAccountID = decoded.my_accounts.first(where: { $0.is_primary })?.id
                    print("✅ Loaded \(decoded.my_accounts.count) accounts")
                }
            } catch {
                print("❌ Decode error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    
    private func setPrimaryAccount(accountID: String) {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/endUser/bank-accounts/set-primary-bank-account"),
              let token = UserDefaults.standard.string(forKey: "auth_token") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let body = ["bank_account_id": accountID]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let raw = data.flatMap({ String(data: $0, encoding: .utf8) }) {
                print("✅ Set Primary Response: \(raw)")
            }
            DispatchQueue.main.async {
                primaryAccountID = accountID
                bankAccounts = bankAccounts.map { account in
                    var updated = account
                    updated.is_primary = account.bank_account_id == accountID
                    return updated
                }
            }
        }.resume()
    }
}

struct BankAccountsResponse: Codable {
    let accounts_count: Int
    let my_accounts: [BankAccount]
}


#Preview {
    NavigationView {
        BankAccountsView()
    }
}

