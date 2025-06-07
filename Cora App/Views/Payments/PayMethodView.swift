//
//  PayMethodView.swift
//  Cora
//
//  Created by Mohammed Alsayed on 09/05/2025.
//

import SwiftUI

struct PayMethodView: View {
    
    var totalAmount: Double
    var transactionId: String
    @Environment(\.dismiss) var dismiss
    @State private var navigateToPayment = false
    @StateObject private var applePayHandler = ApplePayHandler()
    
    var netAmount: Double {
        if totalAmount == 55 {
            return 50
        } else if totalAmount == 105 {
            return 100
        } else {
            let fee = min(totalAmount * 0.025, 250)
            return totalAmount - fee
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
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
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Summary")
                                .customFont(size: 16, weight: "Rubik-Bold")
                                .foregroundColor(Color("Prime"))
                            Spacer()
                        }
                        .padding()
                        
                        Divider()
                        
                        HStack {
                            Text("Total")
                                .customFont(size: 14, weight: "Rubik-Medium")
                                .foregroundColor(Color("Prime"))
                            Spacer()
                            HStack(spacing: 4) {
                                Text("\(totalAmount, specifier: "%.2f")")
                                    .customFont(size: 14, weight: "Rubik-Medium")
                                    .foregroundColor(Color("Prime"))
                                Image("SAR")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(Color("Prime"))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        Divider()
                        
                        HStack {
                            Text("The amount \(netAmount, specifier: "%.2f") will be deposited into your balance")
                                .customFont(size: 12, weight: "Rubik-Regular")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 40)
                    

                    VStack(spacing: 12) {
                        MethodItemView(
                            title: "بطاقة مدى",
                            subtitle: "أودع في حسابك بإضافة بيانات بطاقتك",
                            action: {
                                navigateToPayment = true
                            }
                        )
                        
                        MethodItemView(
                            title: "Apple Pay",
                            subtitle: "أودع في حسابك باستخدام Apple Pay",
                            action: {
                                applePayHandler.present(amount: totalAmount, transactionId: transactionId)
                            }
                        )
                    }
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .environment(\.layoutDirection, .rightToLeft)
                
                .navigationDestination(isPresented: $navigateToPayment) {
                    PaymentView(amount: totalAmount, transactionId: transactionId)
                }
                
            }
        }
        .navigationBarBackButtonHidden(true)

    }
}


struct MethodItemView: View {
    var title: String
    var subtitle: String
    var icon: Image?
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .customFont(size: 16, weight: "Rubik-Medium")
                        .foregroundColor(Color("Prime"))
                    
                    Text(subtitle)
                        .customFont(size: 10, weight: "Rubik-Regular")
                        .foregroundColor(.gray)
                }
                Spacer()
                
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray)
                
            }
            .padding(.vertical, 24)
            .padding(.horizontal)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
    }
}


#Preview {
    PayMethodView(totalAmount: 150.0, transactionId: "test_txn_001")
}

