//
//  SheetDetailsView.swift
//  Cora
//
//  Created by Mohammed Alsayed on 16/04/2025.
//

import SwiftUI

struct SheetDetailsView: View {
    @Binding var showAddSheet: Bool
    @ObservedObject var logManager = ShareLogManager.shared
    @State private var showAddTransaction = false
    
    var totalReceived: Double {
        logManager.logs.filter { $0.type == "receive" }.map { $0.amount }.reduce(0, +)
    }
    
    var totalPaid: Double {
        logManager.logs.filter { $0.type == "pay" }.map { $0.amount }.reduce(0, +)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            
            SummaryView(receivedAmount: totalReceived, spentAmount: totalPaid)
            TransactionListView(logManager: logManager)
            
            Spacer()
            
            Button(action: {
                showAddTransaction = true
            }) {
                Text("Add Transaction")
                    .customFont(size: 16, weight: "Rubik-Bold")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("Bur"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .environment(\.layoutDirection, .leftToRight)

        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .padding()
        .padding(.top, 40)
    }
}
