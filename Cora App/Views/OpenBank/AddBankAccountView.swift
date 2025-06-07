//
//  AddBankAccountView.swift
//  Cora
//
//  Created by Mohammed Alsayed on 15/04/2025.
//

import SwiftUI

struct AddBankAccountView: View {
    @Binding var balances: [BankBalance]
    @Binding var showSheet: Bool
    @State private var selectedBank: Bank?
    @State private var showPermission = false
    @StateObject var viewModel = BankListViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .trailing, spacing: 16) {
                Text("إضافة حساب بنكي")
                    .customFont(size: 20, weight: "Rubik-Bold")
                    .foregroundColor(Color("Prime"))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal)
                
                Text("البنوك المدعومة")
                    .customFont(size: 14, weight: "Rubik-Medium")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.banks) { bank in
                            Button(action: {
                                selectedBank = bank
                                showPermission = true
                            }) {
                                HStack {
                                    Image(systemName: "chevron.backward")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(bank.name)
                                        .foregroundColor(Color("Prime"))
                                        .customFont(size: 16, weight: "Rubik-Regular")
                                    Image(bank.logo)
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .padding(.top, 40)
            .background(Color(.systemGroupedBackground))
        }
        .environment(\.layoutDirection, .leftToRight)

        .sheet(isPresented: $showPermission) {
            AccountPermissionView {
                balances.append(
                    BankBalance(
                        name: "New Bank",
                        logo: "default-logo",
                        balance: Double.random(in: 1000...5000)
                    )
                )
                showPermission = false
                showSheet = false
            }
        }
        
    }
}


#Preview {
    PreviewWrapper()
}

struct PreviewWrapper: View {
    @State private var balances: [BankBalance] = []
    @State private var showSheet = true

    var body: some View {
        AddBankAccountView(balances: $balances, showSheet: $showSheet)
    }
}
