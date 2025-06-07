//
//  TransactionListView.swift
//  Cora
//
//  Created by Mohammed Alsayed on 15/04/2025.
//

import SwiftUI

struct TransactionListView: View {
    @ObservedObject var logManager: ShareLogManager
    @State private var interactions: [TransactionInteraction] = []
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                Text("العمليات")
                    .customFont(size: 16, weight: "Rubik-Regular")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.gray)
                    .padding(.top, 40)
                    .environment(\.layoutDirection, .rightToLeft)
                
                if interactions.isEmpty {
                    Text("لا توجد عمليات حتى الآن")
                        .customFont(size: 16, weight: "Rubik-Regular")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(interactions) { interaction in
                        TransactionCardView(interaction: binding(for: interaction))
                    }
                }
            }
            .onAppear {
                loadInteractions()
            }
        }
    }
    
//    private func loadInteractions() {
//        interactions = logManager.logs.reversed().map {
//            TransactionInteraction(log: $0, likes: $0.is_liked ? 1 : 0, comments: $0.comments)
//        }
//    }
    
    private func loadInteractions() {
      
        interactions = [
            TransactionInteraction(
                log: ShareLog(
                    tran_date_time: ISO8601DateFormatter().string(from: Date()),
                    is_charge: true,
                    amount: 150.00,
                    is_liked: false,
                    comments: ["محمد شكراً", "وصلني المبلغ"]
                ),
                likes: 0,
                comments: ["محمد شكراً", "وصلني المبلغ"]
            ),
            TransactionInteraction(
                log: ShareLog(
                    tran_date_time: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600 * 24)),
                    is_charge: false, 
                    amount: 300.00,
                    is_liked: true,
                    comments: ["ممتاز", "استلام تم"]
                ),
                likes: 1,
                comments: ["ممتاز", "استلام تم"]
            )
        ]
    }

    
    private func binding(for interaction: TransactionInteraction) -> Binding<TransactionInteraction> {
        guard let index = interactions.firstIndex(where: { $0.id == interaction.id }) else {
            return .constant(interaction)
        }
        return $interactions[index]
    }
}



func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "d MMMM yyyy, h:mm a"
    return formatter.string(from: date)
}


#Preview {
    TransactionListView(logManager: ShareLogManager.shared)
}
