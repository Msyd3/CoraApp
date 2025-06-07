//
//  AddBankAccountSheet.swift
//  Cora
//
//  Created by Mohammed Alsayed on 01/05/2025.
//

import SwiftUI

struct AddBankAccountSheet: View {
    @State private var name = ""
    @State private var iban = ""
    @State private var isSubmitting = false
    @Environment(\.dismiss) var dismiss
    
    var onAdd: (BankAccount) -> Void
    
    var isIBANValid: Bool {
        let trimmed = iban.trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
            .replacingOccurrences(of: " ", with: "")
        
        guard trimmed.count == 24 else { return false }
        guard trimmed.hasPrefix("SA") else { return false }
        
        let digits = String(trimmed.dropFirst(2))
        return digits.count == 22 && digits.allSatisfy { $0.isNumber }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Bank Account")
                .customFont(size: 22, weight: "Rubik-Bold")
                .padding(.top, 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Account Name").customFont(size: 14, weight: "Rubik-Medium")
                TextField("Enter name", text: $name)
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("IBAN").customFont(size: 14, weight: "Rubik-Medium")
                TextField("SA", text: $iban)
                    .textInputAutocapitalization(.characters)
                    .keyboardType(.asciiCapable)
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .onChange(of: iban) { _ in formatIBAN() }
                
                if !iban.isEmpty && !isIBANValid {
                    Text("IBAN must start with SA and be exactly 24 digits")
                        .font(.caption).foregroundColor(.red)
                }
            }
            
            Spacer()
            
            Button(action: submitAccount) {
                if isSubmitting {
                    ProgressView().padding()
                } else {
                    Text("Add Account")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .background((name.isEmpty || !isIBANValid) ? Color.gray.opacity(0.3) : Color("Bur"))
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(name.isEmpty || !isIBANValid || isSubmitting)
            
            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(Color("Rede"))
            .padding(.bottom, 16)
        }
        .padding(.horizontal)
    }
    
    func submitAccount() {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/endUser/bank-accounts/add-my-bank-account") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let cleanedIBAN = iban.uppercased().replacingOccurrences(of: " ", with: "")
        let body: [String: String] = ["iban": cleanedIBAN, "fullname": name]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        isSubmitting = true
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Status code: \(httpResponse.statusCode)")
                }
                
                if let data = data, let raw = String(data: data, encoding: .utf8) {
                    print("📦 Raw response: \(raw)")
                }
                
                guard let data = data,
                      let response = try? JSONDecoder().decode(AddBankResponse.self, from: data) else {
                    print("❌ Failed to decode or request failed")
                    return
                }
                
                let newAccount = BankAccount(
                    bank_account_id: response.bank_account_id,
                    fullname: name,
                    iban: cleanedIBAN,
                    bank: response.bank_name_english,
                    is_primary: false
                )
                onAdd(newAccount)
                dismiss()
            }
        }.resume()
    }
    
    func formatIBAN() {
        var cleaned = iban.uppercased().replacingOccurrences(of: " ", with: "")
        if !cleaned.hasPrefix("SA") {
            cleaned = "SA" + cleaned.drop { $0 == "S" || $0 == "A" }
        }
        if cleaned.count > 24 {
            cleaned = String(cleaned.prefix(24))
        }
        iban = cleaned.chunked(into: 4).joined(separator: " ")
    }
}

struct AddBankResponse: Decodable {
    var bank_account_id: String
    var bank_name_arabic: String
    var bank_name_english: String
}

extension String {
    func chunked(into size: Int) -> [String] {
        stride(from: 0, to: count, by: size).map {
            let start = index(startIndex, offsetBy: $0)
            let end = index(start, offsetBy: size, limitedBy: endIndex) ?? endIndex
            return String(self[start..<end])
        }
    }
}



#Preview {
    AddBankAccountSheet { account in
        print("Added account: \(account.fullname)")
    }
}
