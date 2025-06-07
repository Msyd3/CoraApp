//
//  UserLinkView.swift
//  Cora
//
//  Created by Mohammed Alsayed on 03/05/2025.
//

import SwiftUI

struct UserLinkView: View {
    @State private var showTransactionSheet = false
    @State private var navigateToFastTransaction = false
    @ObservedObject var logManager = ShareLogManager()
    @State private var selectedContactForSheet: Contact? = nil
    @Binding var contacts: [Contact]
    @Environment(\.dismiss) var dismiss
    let contact: Contact
    var onOpen: () -> Void
    var onDelete: () -> Void
    var onFastTransfer: () -> Void = {}
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 12) {
                    // Header
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.backward")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.black)
                        }
                        Spacer()
                        Image("cora-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Contact Info
                    HStack {
                        Button(action: {
                            deleteContact(contact)
                        }) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.2))
                                .frame(width: 40, height: 60)
                                .overlay(
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.red)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.leading, 2)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(contact.name)
                                .customFont(size: 14, weight: "Rubik-Bold")
                            
                            Text("IBAN")
                                .customFont(size: 10, weight: "Rubik-Regular")
                                .foregroundColor(.gray)
                            
                            Text(contact.iban)
                                .customFont(size: 10, weight: "Rubik-Regular")
                                .foregroundColor(.gray)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        .padding(.trailing, 16)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // Buttons
                    HStack(spacing: 8) {
                        // Add User (disabled)
                        Button(action: {}) {
                            Text("Add user")
                                .customFont(size: 14, weight: "Rubik-SemiBold")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(true)
                    }
                    .padding(.horizontal)
                    
                    .navigationDestination(isPresented: $navigateToFastTransaction) {
                        FastTransactionView(
                            showSuccess: .constant(false),
                            contacts: $contacts
                        )
                    }
                    
                    // Transactions (if needed)
                    if let contact = selectedContactForSheet {
                        VStack(alignment: .trailing, spacing: 8) {
                            ConversationTransactionsView(beneficiaryID: contact.beneficiary_id)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .environment(\.layoutDirection, .leftToRight)
                .background(Color.white.ignoresSafeArea())
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    
    func deleteContact(_ contact: Contact) {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/endUser/beneficiaries/delete-beneficiary") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let body: [String: String] = ["beneficiary_id": contact.beneficiary_id]
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error:", error)
                return
            }
            
            guard let data = data,
                  let responseString = String(data: data, encoding: .utf8),
                  responseString.trimmingCharacters(in: .whitespacesAndNewlines) == contact.beneficiary_id else {
                print("❌ Failed or invalid response")
                return
            }
            
            DispatchQueue.main.async {
                contacts.removeAll { $0.beneficiary_id == contact.beneficiary_id }
                dismiss()
                print("✅ Beneficiary deleted:", contact.name)
            }
        }.resume()
    }
}


#Preview {
    StatefulPreviewWrapper([
        Contact(
            beneficiary_id: UUID().uuidString,
            name: "Test User",
            iban: "SA12345678901234567890"
        )
    ]) { contactsBinding in
        UserLinkView(
            contacts: contactsBinding,
            contact: contactsBinding.wrappedValue[0],
            onOpen: { print("Open pressed") },
            onDelete: { print("Delete pressed") }
        )
    }
}

