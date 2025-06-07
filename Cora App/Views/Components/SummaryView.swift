//
//  SummaryView.swift
//  Cora App
//
//  Created by Mohammed Alsayed on 29/01/2025.
//

import SwiftUI

struct SummaryView: View {
    let receivedAmount: Double
    let spentAmount: Double
    
    var body: some View {
        HStack(spacing: 16) {
            summaryBox(title: "الوارد", value: receivedAmount, color: Color("Greend"))
            summaryBox(title: "الصادر", value: spentAmount, color: Color("Rede"))
        }
    }
    
    func summaryBox(title: String, value: Double, color: Color) -> some View {
        VStack(alignment: .center, spacing: 4) {
            Text(title)
                .customFont(size: 12, weight: "Rubik-Medium")
                .foregroundColor(.gray)
            
            HStack(spacing: 4) {
                Image("SAR")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 16, height: 16)
                    .foregroundColor(color)
                
                Text("\(value, specifier: "%.2f")")
                    .customFont(size: 20, weight: "Rubik-Bold")
                    .foregroundColor(color)
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}


#Preview {
    SummaryView(receivedAmount: 10, spentAmount: 10)
}
