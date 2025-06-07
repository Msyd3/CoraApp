//
//  CategorySpendingView.swift
//  Cora App
//
//  Created by Mohammed Alsayed on 29/01/2025.
//

import SwiftUI

struct CategorySpendingView: View {
    let mostVisitedCategory: String
    let highestSpentCategory: String
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text("Category Spending")
                .font(.headline)
                .foregroundColor(.gray)
            
            HStack {
                VStack {
                    Text(mostVisitedCategory)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color("Bur"))
                    Text("Most Visited")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                VStack {
                    Text(highestSpentCategory)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color("Bur"))
                    Text("Highest Spent")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

#Preview {
    CategorySpendingView(mostVisitedCategory: "Blu", highestSpentCategory: "Blu")
}
