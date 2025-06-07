//
//  SpendingSummaryView.swift
//  Cora App
//
//  Created by Mohammed Alsayed on 29/01/2025.
//

import SwiftUI

enum SpendingType: String, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}

struct SpendingSummaryView: View {
    let weeklySpent: Double
    let monthlySpent: Double
    let yearlySpent: Double
    let avgDailySpent: Double
    
    @State private var selectedType: SpendingType = .weekly
    
    var selectedAmount: Double {
        switch selectedType {
        case .weekly: return weeklySpent
        case .monthly: return monthlySpent
        case .yearly: return yearlySpent
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            
            // Buttons
            HStack {
                Spacer()
                ForEach(SpendingType.allCases, id: \.self) { type in
                    Button(action: {
                        selectedType = type
                    }) {
                        Text(type.rawValue)
                            .customFont(size: 12, weight: "Rubik-Medium")
                            .foregroundColor(selectedType == type ? .white : .gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedType == type ? Color("Bur") : Color.gray.opacity(0.05))
                            .cornerRadius(10)
                    }
                }
            }
            
            // Selected Amount
            HStack(spacing: 4) {
                Image("SAR")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 46, height: 46)
                    .foregroundColor(Color("Prime"))
                
                Text("\(selectedAmount, specifier: "%.2f")")
                    .customFont(size: 60, weight: "Rubik-Bold")
                    .foregroundColor(Color("Prime"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5) 
            }
            .frame(maxWidth: .infinity)
            
            // Avg. Daily
            VStack(spacing: 4) {
                Text("\(avgDailySpent, specifier: "%.2f")")
                    .customFont(size: 16, weight: "Rubik-Regular")
                    .foregroundColor(Color("Prime"))
                Text("Avg. Daily Spent")
                    .customFont(size: 12, weight: "Rubik-Regular")
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
    }
    
    func spendingBox(title: String, amount: Double) -> some View {
        VStack(spacing: 8) {
            Button(action: {
            
            }) {
                Text(title)
                    .customFont(size: 12, weight: "Rubik-Medium")
                    .foregroundColor(.gray)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            
            VStack(spacing: 4) {
                Text("\(amount, specifier: "%.2f")")
                    .customFont(size: 22, weight: "Rubik-Bold")
                    .foregroundColor(Color("Bur"))
                
                Image("SAR")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 16, height: 16)
                    .foregroundColor(Color("Bur"))
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SpendingSummaryView(weeklySpent: 10, monthlySpent: 20, yearlySpent: 30, avgDailySpent: 5)
}

