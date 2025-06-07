//
//  ActivitySummarySheet.swift
//  Cora App
//
//  Created by Mohammed Alsayed on 30/01/2025.
//

import SwiftUI

struct ActivitySummarySheet: View {
    var body: some View {
        VStack(spacing: 16) {
            // Sheet Handle Bar
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.5))
                .padding(.top, 8)
            
            Text("Summary")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 8)
            
            // Received and Spent Summary
            SummaryView(receivedAmount: 5000, spentAmount: 200)
            
            // Weekly, Monthly, Yearly Spending + Daily Average
            SpendingSummaryView(
                weeklySpent: 300,
                monthlySpent: 120,
                yearlySpent: 150,
                avgDailySpent: 40
            )
            
            // Category Spending Summary
            CategorySpendingView(
                mostVisitedCategory: "Supermarket",
                highestSpentCategory: "Restaurants"
            )
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .ignoresSafeArea(edges: .bottom) 
    }
}

#Preview {
    ActivitySummarySheet()
}
