//
//  NewBalanceView.swift
//  Cora
//
//  Created by Mohammed Alsayed on 09/05/2025.
//

import SwiftUI

struct NewBalanceView: View {
    @State private var amountText: String = ""
    @State private var isOverLimit: Bool = false
    @State private var isEmpty: Bool = true
    @State private var showPayMethods = false
    @State private var isBelowMinimum: Bool = false
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) var dismiss
    @StateObject var walletState = WalletState()
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .trailing, spacing: 4) {
                HStack {
                    Text("Enter Amount")
                        .font(.system(size: 22, weight: .bold))
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.forward")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            VStack(alignment: .trailing, spacing: 8) {
                Text("Amount")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    TextField("0", text: $amountText)
                        .keyboardType(.numberPad)
                        .font(.system(size: 24))
                        .bold()
                        .foregroundColor((isOverLimit || isBelowMinimum) ? Color("Rede") : Color("Prime"))
                        .multilineTextAlignment(.leading)
                        .onChange(of: amountText) { newValue in
                            let englishDigits = newValue.compactMap { char -> Character? in
                                let scalars = String(char).unicodeScalars
                                if let value = scalars.first?.value {
                                    if value >= 0x0660 && value <= 0x0669 {
                                        return Character(String(value - 0x0660))
                                    }
                                }
                                return "0123456789".contains(char) ? char : nil
                            }
                            amountText = String(englishDigits)
                            
                            if let value = Int(amountText) {
                                isEmpty = false
                                isBelowMinimum = value < 105
                            } else {
                                isEmpty = true
                                isBelowMinimum = false
                            }
                        }
                    
                    Spacer()
                    
                    Image("SAR")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(Color("Prime"))
                }
                .background(Color.white)
                .cornerRadius(12)
                
                
                HStack {
                    Text("Remaining minimum deposit is 105 SAR")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.top, 10)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            
            Spacer()
            
            Button(action: {
                if let amount = Int(amountText) {
                    WalletService.setupWalletCharge(amount: amount) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let transactionId):
                                walletState.transactionId = transactionId
                                walletState.amount = amount
                                print("✅ Setup success - transactionId: \(transactionId)")
                                showPayMethods = true
                                
                            case .failure(let error):
                                print("❌ Setup failed:", error.localizedDescription)
                            }
                        }
                    }
                }
            }) {
                Text("Next")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background((isEmpty || isOverLimit || isBelowMinimum) ? Color("Bur").opacity(0.5) : Color("Bur"))
                    .cornerRadius(12)
            }
            .disabled(isEmpty || isOverLimit)
            
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            
            .sheet(isPresented: $showPayMethods) {
                if let transactionId = walletState.transactionId,
                   let amount = walletState.amount {
                    PayMethodView(
                        totalAmount: Double(amount),
                        transactionId: transactionId
                    )
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6).ignoresSafeArea())
        .environment(\.layoutDirection, .rightToLeft)
        .navigationBarBackButtonHidden(true)
    }
}

struct NewBalanceView_Previews: PreviewProvider {
    static var previews: some View {
        NewBalanceView()
    }
}
