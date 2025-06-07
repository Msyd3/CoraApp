//
//  BalanceCardView.swift
//  Cora
//
//  Created by Mohammed Alsayed on 08/05/2025.
//

import SwiftUI

struct BalanceCardView: View {
    @Binding var balance: Double

    var body: some View {
        HStack(alignment: .top) {
            Image("cora-logo")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Current Balance")
                    .customFont(size: 16, weight: "Rubik-Bold")
                
                HStack(spacing: 6) {
                    Image("SAR")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color("Prime"))
                    
                    Text("\(balance, specifier: "%.2f")")
                        .customFont(size: 24, weight: "Rubik-Medium")
                        .foregroundColor(Color("Prime"))
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .navigationBarBackButtonHidden(true)

    }
}

