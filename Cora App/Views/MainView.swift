//
//  MainView.swift
//  Cora App
//
//  Created by Mohammed Alsayed on 23/01/2025.
//

import SwiftUI

struct MainView: View {
    @State private var navigateToPaymentLink = false
    @State private var navigateToTransaction = false
    @State private var showAddBank = false
    @State private var showSuccess = false
    @State private var showNotifications = false
    @State private var balances: [BankBalance] = []
    @AppStorage("shareCount") var shareCount: Int = 0
    @State private var fullName: String = "User"
    @ObservedObject var logManager = ShareLogManager()
    @StateObject var balanceManager = BalanceManager()
    @Binding var contacts: [Contact]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack {
                    Image("cora-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                    
                    HStack {
                        //                        Button(action: {
                        //                            showNotifications = true
                        //                        }) {
                        //                            Image(systemName: "bell.fill")
                        //                                .font(.title2)
                        //                                .foregroundColor(Color("Prime"))
                        //                        }
                        //
                        Spacer()
                        
                        Text("👋🏻")
                            .customFont(size: 30)
                        
                        Text("Hello".localized)
                            .customFont(size: 30, weight: "Rubik-Bold")
                            .foregroundColor(Color("Prime"))
                    }
                    .padding(.bottom)
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        BalanceCardView(balance: $balanceManager.currentBalance)
                        
                        HStack(spacing: 12) {
                            NavigationLink(destination: MainBalanceView()) {
                                Text("Deposit")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("Prime"))
                                    .foregroundColor(.white)
                                    .customFont(size: 16, weight: "Rubik-SemiBold")
                                    .cornerRadius(12)
                            }
                            
                            NavigationLink(
                                destination: FastTransactionView(
                                    showSuccess: $showSuccess,
                                    contacts: $contacts
                                )
                            ) {
                                Text("Fast Transaction")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("Bur"))
                                    .foregroundColor(.white)
                                    .customFont(size: 16, weight: "Rubik-SemiBold")
                                    .cornerRadius(12)
                            }
                        }
                        
                        // Transaction List
                        VStack(alignment: .trailing, spacing: 8) {
                            TransactionListView(logManager: logManager)
                        }
                        .padding(.bottom, 100)
                        
                    }
                }
            }
            .background(Color.white.ignoresSafeArea())
            .ignoresSafeArea(edges: .bottom)
            .padding(.horizontal)
            
            // Sheets
            .sheet(isPresented: $showAddBank) {
                AddBankAccountView(balances: $balances, showSheet: $showAddBank)
            }
            
            .sheet(isPresented: $showNotifications) {
                NotificationView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            
            .alert("تم التحويل بنجاح", isPresented: $showSuccess) {
                Button("تم", role: .cancel) { }
            }
        }
    }
}

#Preview {
    StatefulPreviewWrapper(false) { showSuccessBinding in
        StatefulPreviewWrapper([Contact(
            beneficiary_id: "1",
            name: "Test User",
            iban: "SA1234567890123456789012"
        )]) { contactsBinding in
            FastTransactionView(
                showSuccess: showSuccessBinding,
                contacts: contactsBinding
            )
        }
    }
}



