//
//  BankActivity.swift
//  Cora App
//
//  Created by Mohammed Alsayed on 25/01/2025.
//

import SwiftUI

struct BankActivity: View {
    let storeImage: String
    let activityName: String
    let date: String
    let amount: Double
    let isReceived: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            
         
            
            // Amount and Icon
            VStack(alignment: .leading) {
                HStack(spacing: 6) {
                    
                    Image("SAR")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(isReceived ? Color("Greend") : Color("Rede"))
                    
                    Text("\(amount, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(isReceived ? Color("Greend") : Color("Rede"))
                }
            }
            
            Spacer()
            
            // Activity Details
            VStack(alignment: .trailing, spacing: 0) {
                Text(activityName)
                    .font(.headline)
                    .dynamicTypeSize(.medium ... .xxLarge)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                
                
                Text(date)
                    .font(.caption2)
                    .foregroundColor(.gray)
                
            }
            
            // Store Image
            Image(isReceived ? "ArrUp" : "ArrDown")
                .renderingMode(.template)
                .foregroundColor(isReceived ? Color("Greend") : Color("Rede"))
                .scaledToFit()
                .frame(width: 34, height: 40)
                .clipShape(Circle())

        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    BankActivity(
        storeImage: "store-image",
        activityName: "Supermarket Purchase",
        date: "Jan 25, 2025, 2:30 PM",
        amount: 150.75,
        isReceived: false
    )
}
