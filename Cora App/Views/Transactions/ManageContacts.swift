//
//  ContactSelectionView.swift
//  Cora App
//
//  Created by Mohammed Alsayed on 08/02/2025.
//

import SwiftUI

struct ManageContacts: View {
    @Binding var selectedContact: String
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToUserLink: Bool = false
    @State private var selectedToDelete: Contact? = nil
    @State private var selectedContactForSheet: Contact? = nil
    @State private var navigateToFastTransaction = false
    @State private var contacts: [Contact] = []
    @State private var showAddSheet = false
    @State private var showDuplicateAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Text("Select Contact")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        showAddSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color("Bur"))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 40)
                .padding(.bottom, 20)
                
                ScrollView(showsIndicators: false) {
                    if contacts.isEmpty {
                        emptyState
                    } else {
                        VStack(spacing: 12) {
                            ForEach(contacts) { contact in
                                Button(action: {
                                    selectedContactForSheet = contact
                                    selectedToDelete = selectedToDelete == contact ? nil : contact
                                    navigateToUserLink = true
                                }) {
                                    HStack {
                                        Image("cora-logo")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(contact.name)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Text(contact.iban)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        if selectedToDelete == contact {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(Color("Bur"))
                                        }
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.05))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .onAppear {
                fetchContacts()
            }
            .navigationDestination(isPresented: $navigateToUserLink) {
                if let contact = selectedContactForSheet {
                    UserLinkView(
                        contacts: $contacts, contact: contact,
                        onOpen: {
                            selectedContact = contact.name
                            navigateToUserLink = false
                            presentationMode.wrappedValue.dismiss()
                        },
                        onDelete: {
                            deleteBeneficiary(contact)
                            navigateToUserLink = false
                        },
                        onFastTransfer: {
                            selectedContact = contact.name
                            navigateToUserLink = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                navigateToFastTransaction = true
                            }
                        }
                    )
                }
            }

            
            .navigationDestination(isPresented: $navigateToFastTransaction) {
                FastTransactionView(
                    showSuccess: .constant(false),
                    contacts: $contacts
                )
            }
            
            .sheet(isPresented: $showAddSheet) {
                AddContactSheet { newContact in
                    if !contacts.contains(where: { $0.iban == newContact.iban || $0.name == newContact.name }) {
                        contacts.append(newContact)
                    } else {
                        showDuplicateAlert = true
                    }
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            
            .alert("Contact Already Exists", isPresented: $showDuplicateAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("This contact is already in your list.")
            }

        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image("empty")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .opacity(0.7)
            
            Text("Add your first beneficiary to send payments")
                .customFont(size: 12, weight: "Rubik-Regular")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func fetchContacts() {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/endUser/beneficiaries/list-my-beneficiaries?page_index=0&page_size=10") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error:", error)
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
                struct Response: Decodable {
                    let beneficiaries_count: Int
                    let my_beneficiaries: [Contact]
                }
                let decoded = try JSONDecoder().decode(Response.self, from: data)
                
                DispatchQueue.main.async {
                    self.contacts = decoded.my_beneficiaries
                    print("✅ Loaded \(decoded.beneficiaries_count) contacts")
                }
            } catch {
                print("❌ Decoding error:", error)
            }
        }.resume()
    }
    
    private func deleteBeneficiary(_ contact: Contact) {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/endUser/beneficiaries/delete-beneficiary") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body = ["beneficiary_id": contact.beneficiary_id]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request error:", error)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status code:", httpResponse.statusCode)
            }

            guard let data = data,
                  let responseString = String(data: data, encoding: .utf8),
                  responseString.trimmingCharacters(in: .whitespacesAndNewlines) == contact.beneficiary_id else {
                print("❌ Failed to delete beneficiary or invalid response")
                return
            }

            DispatchQueue.main.async {
                contacts.removeAll { $0.id == contact.id }
                print("✅ Beneficiary deleted:", contact.name)
            }
        }.resume()
    }
}



#Preview {
    ManageContacts(selectedContact: .constant("Select Contact"))
}
