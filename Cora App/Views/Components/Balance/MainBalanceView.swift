//
//  MainBalanceView.swift
//  Cora
//
//  Created by Mohammed Alsayed on 08/05/2025.
//

import SwiftUI

struct MainBalanceView: View {
    @StateObject var balanceManager = BalanceManager()
    @State private var showPayMethods = false
    @State private var selectedAmount: Double? = nil
    @State private var transactionId: String = ""
    @State private var isLoading = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .trailing, spacing: 4) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    BalanceCardView(balance: $balanceManager.currentBalance)
                    
                    Text("Charge your balance")
                        .customFont(size: 12, weight: "Rubik-Regular")
                        .foregroundColor(Color("Prime"))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.top, 40)
                    
                    chargeButton(amount: 55, message: "Will receive 50 in balance")
                    chargeButton(amount: 105, message: "Will receive 100 in balance")
                    
                    NavigationLink(destination: NewBalanceView()) {
                        ZStack {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(Color("Bur"))
                                    .frame(width: 20, height: 40)
                                Spacer()
                            }
                            
                            HStack(spacing: 6) {
                                Text("Manual entry")
                                    .customFont(size: 18, weight: "Rubik-Medium")
                                    .foregroundColor(Color("Bur"))
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            .padding(.top, 10)
        }
        
        .fullScreenCover(isPresented: $showPayMethods) {
            if let amount = selectedAmount {
                PayMethodView(
                    totalAmount: amount,
                    transactionId: transactionId
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    @ViewBuilder
    func chargeButton(amount: Double, message: String) -> some View {
        Button(action: {
            isLoading = true
            WalletService.setupWalletCharge(amount: Int(amount)) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success(let txnId):
                        self.transactionId = txnId
                        self.selectedAmount = amount
                        self.showPayMethods = true
                    case .failure(let error):
                        print("❌ Error:", error.localizedDescription)
                    }
                }
            }
        }) {
            ZStack {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("Bur"))
                        .frame(width: 20, height: 40)
                    Spacer()
                }
                
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        Image("SAR")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color("Bur"))
                        
                        Text("\(Int(amount))")
                            .customFont(size: 20, weight: "Rubik-Medium")
                            .foregroundColor(Color("Bur"))
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Text(message)
                        .customFont(size: 10, weight: "Rubik-Regular")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
    }
}


#Preview {
    MainBalanceView()
}

