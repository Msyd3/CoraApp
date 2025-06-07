//
//  AddContactSheet.swift
//  Cora
//
//  Created by Mohammed Alsayed on 02/05/2025.
//

import SwiftUI

struct AddContactSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var iban = ""
    @StateObject private var bankVM = BankListViewModel()
    @State private var selectedBank: Bank? = nil
    @State private var showBankList = false
    
    var onAdd: (Contact) -> Void
    
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
            Text("Add Contact")
                .customFont(size: 22, weight: "Rubik-Bold")
                .padding(.top, 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Contact Name")
                    .customFont(size: 14, weight: "Rubik-Medium")
                
                TextField("Enter name", text: $name)
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("IBAN")
                    .customFont(size: 14, weight: "Rubik-Medium")
                
                HStack {
                    TextField("SA", text: $iban)
                        .textInputAutocapitalization(.characters)
                        .keyboardType(.asciiCapable)
                        .padding()
                        .onChange(of: iban) { _ in
                            formatIBAN()
                        }
                    
                    Button(action: {
                        if let pastedText = UIPasteboard.general.string {
                            iban = pastedText
                            formatIBAN()
                        }
                    }) {
                        Image(systemName: "doc.on.clipboard")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 12)
                }
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                if !iban.isEmpty && !isIBANValid {
                    Text("IBAN must start with SA and be exactly 24 characters")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bank")
                        .customFont(size: 14, weight: "Rubik-Medium")
                        .padding(.top, 10)
                    Button(action: {
                        showBankList = true
                    }) {
                        HStack {
                            Text(selectedBank?.name ?? "Select Bank")
                                .foregroundColor(selectedBank == nil ? .gray : .black)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                    .sheet(isPresented: $showBankList) {
                        VStack(alignment: .leading) {
                            HStack {
                                Spacer()
                                Text("Select Bank")
                                    .font(.headline)
                                    .padding()
                                Spacer()
                            }
                            
                            ScrollView {
                                VStack(spacing: 12) {
                                    ForEach(bankVM.banks) { bank in
                                        Button(action: {
                                            selectedBank = bank
                                            showBankList = false
                                        }) {
                                            HStack(spacing: 12) {
                                                Image(bank.logo)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 36, height: 36)
                                                    .clipShape(Circle())
                                                Text(bank.name)
                                                    .foregroundColor(.black)
                                                    .font(.system(size: 16, weight: .medium))
                                                Spacer()
                                            }
                                            .padding()
                                            .background(Color.gray.opacity(0.05))
                                            .cornerRadius(12)
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                    
                }
                
            }
            
            Spacer()
            
            Button("Add Contact") {
                addContactToServer()
            }
            .disabled(name.isEmpty || !isIBANValid || selectedBank == nil)
            .frame(maxWidth: .infinity)
            .padding()
            .background((name.isEmpty || !isIBANValid || selectedBank == nil) ? Color.gray.opacity(0.3) : Color("Bur"))
            .foregroundColor(.white)
            .cornerRadius(12)
            
            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(Color("Rede"))
            .padding(.bottom, 16)
        }
        .padding(.horizontal)
    }
    
    func formatIBAN() {
        var cleaned = iban.uppercased().replacingOccurrences(of: " ", with: "")
        
        if !cleaned.hasPrefix("SA") {
            cleaned = "SA" + cleaned.drop { $0 == "S" || $0 == "A" }
        }
        
        if cleaned.count > 24 {
            cleaned = String(cleaned.prefix(24))
        }
        
        let formatted = cleaned.enumerated().map { index, char in
            return (index % 4 == 0 && index != 0) ? " \(char)" : String(char)
        }.joined()
        
        iban = formatted
    }
    
    func addContactToServer() {
        guard let selectedBank = selectedBank else { return }
        guard let url = URL(string: "\(APIConfig.baseURL)/api/endUser/beneficiaries/add-new-beneficiary") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let ibanFormatted = iban.uppercased().replacingOccurrences(of: " ", with: "")
        let body: [String: Any] = [
            "iban": ibanFormatted,
            "account_owner_fullname": name,
            "bank_name_key": selectedBank.code
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error:", error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status code:", httpResponse.statusCode)
            }
            
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    print("📨 JSON Response:", json)
                } else {
                    print("📨 Raw Response:", String(data: data, encoding: .utf8) ?? "")
                }
                
                if let idString = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        let contact = Contact(
                            beneficiary_id: idString.trimmingCharacters(in: .whitespacesAndNewlines),
                            name: name,
                            iban: iban.uppercased().replacingOccurrences(of: " ", with: "")
                        )
                        onAdd(contact)
                        dismiss()
                    }
                }
            }
        }.resume()
    }
}


#Preview {
    AddContactSheet { newContact in
        print("Added contact: \(newContact.name), \(newContact.iban)")
    }
}

