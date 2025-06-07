//
//  AccountSelectionView.swift
//  Cora App
//
//  Created by Mohammed Alsayed on 08/02/2025.
//

import SwiftUI

struct AccountSelectionView: View {
    @Binding var selectedAccount: String
    @Environment(\.presentationMode) var presentationMode
    
    let accounts = [
        (name: "Bank A", iban: "SA1234XXXX5678", balance: "5,000 SAR"),
        (name: "Bank B", iban: "SA9876XXXX4321", balance: "12,300 SAR"),
        (name: "Bank C", iban: "SA1122XXXX3344", balance: "8,750 SAR")
    ]
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    Text("Select Account")
                        .font(.headline)
                        .padding(.vertical, 8)
                        .padding(.top, 8)
                    
                    ForEach(accounts, id: \.name) { account in
                        Button(action: {
                            selectedAccount = account.name
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image("cora-logo")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(account.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(account.iban)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Text(account.balance)
                                    .font(.headline)
                                    .foregroundColor(.black)
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
        .presentationDetents([.medium])
        .interactiveDismissDisabled(true)
    }
}

#Preview {
    AccountSelectionView(selectedAccount: .constant("Select Account"))
}
