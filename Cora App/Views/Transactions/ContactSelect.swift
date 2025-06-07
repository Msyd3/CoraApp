//
//  ContactSelect.swift
//  Cora
//
//  Created by Mohammed Alsayed on 10/05/2025.
//

import SwiftUI

struct ContactSelectView: View {
    @Binding var selectedContact: Contact?
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = ContactListViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    Text("Select Contact")
                        .font(.headline)
                        .padding(.vertical, 8)
                        .padding(.top, 8)
                    
                    ForEach(viewModel.contacts) { contact in
                        Button(action: {
                            selectedContact = contact
                            dismiss()
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
        .onAppear {
            viewModel.loadContacts()
        }
        .presentationDetents([.medium])
        .interactiveDismissDisabled(true)
    }
}


#Preview {
    ContactSelectView(selectedContact: .constant(nil))
}

