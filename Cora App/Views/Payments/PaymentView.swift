//
//  PaymentView.swift
//  Cora
//
//  Created by Mohammed Alsayed on 15/05/2025.
//

import SwiftUI
import MoyasarSdk

struct PaymentView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: PaymentViewModel
    
    init(amount: Double, transactionId: String) {
        _viewModel = StateObject(wrappedValue: PaymentViewModel(amount: amount, transactionId: transactionId))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                
                if let request = viewModel.paymentRequest {
                    CreditCardView(
                        request: request,
                        callback: viewModel.handleResult
                    )
//                    .frame(height: 400)
                    .padding(.top, 40)
                    .environment(\.layoutDirection, .leftToRight)
                    .environment(\.locale, Locale(identifier: "en"))
                    .onAppear {
                        print("🔍 PaymentRequest:")
                        print("Amount: \(viewModel.paymentRequest?.amount ?? 0)")
                        print("Currency: \(viewModel.paymentRequest?.currency ?? "")")
                        print("Networks: \(viewModel.paymentRequest?.allowedNetworks ?? [])")
                    }
                    
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("إلغاء")
                            .customFont(size: 12, weight: "Rubik-SemiBold")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.gray)
                    }
                    
                } else {
                    ProgressView("...")
                }
                
            }
            .padding(.bottom, 40)
            .padding(.horizontal)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    PaymentView(amount: 150, transactionId: "txn_001_preview")
}
