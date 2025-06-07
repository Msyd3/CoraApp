//
//  TransactionCardView.swift
//  Cora
//
//  Created by Mohammed Alsayed on 02/05/2025.
//

import SwiftUI

struct TransactionCardView: View {
    @Binding var interaction: TransactionInteraction
    
    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 4) {
                        Image("SAR")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 14, height: 14)
                            .foregroundColor(interaction.log.type == "receive" ? Color("Greend") : Color("Rede"))
                        
                        Text("\(interaction.log.amount, specifier: "%.2f")")
                            .customFont(size: 14, weight: "Rubik-Bold")
                            .foregroundColor(interaction.log.type == "receive" ? Color("Greend") : Color("Rede"))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(interaction.log.type == "receive" ? "حوالة واردة" : "حوالة صادرة")
                        .customFont(size: 14, weight: "Rubik-Medium")
                    Text(formattedDate(interaction.log.date))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Image(interaction.log.type == "receive" ? "ArrUp" : "ArrDown")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 60, height: 60)
                    .foregroundColor(interaction.log.type == "receive" ? Color("Greend") : Color("Rede"))
            }
            // Buttons
            HStack {
                Button(action: {
                    interaction.likes = interaction.likes == 0 ? 1 : 0
                }) {
                    Image(systemName: interaction.likes == 0 ? "heart" : "heart.fill")
                        .foregroundColor(interaction.likes == 0 ? .gray : Color("Rede"))
                        .padding(6)
                }
                
                Spacer()
                
                Button(action: {
                    interaction.showComments.toggle()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.right")
                            .foregroundColor(.gray)
                        Text("\(interaction.comments.count)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Comments
            if interaction.showComments {
                VStack(alignment: .leading, spacing: 8) {
                    if !interaction.comments.isEmpty {
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(interaction.comments, id: \.self) { comment in
                                    VStack(alignment: .leading, spacing: 2) {
                                        let components = comment.split(separator: " ", maxSplits: 1)
                                        if components.count == 2 {
                                            Text(components[0])
                                                .customFont(size: 12, weight: "Rubik-Bold")
                                                .foregroundColor(Color("Bur"))
                                            
                                            Text(components[1])
                                                .customFont(size: 12, weight: "Rubik-Regular")
                                                .foregroundColor(Color("Prime"))
                                        } else {
                                            Text(comment)
                                                .customFont(size: 12, weight: "Rubik-Regular")
                                                .foregroundColor(Color("Prime"))
                                        }
                                    }
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                    .environment(\.layoutDirection, .rightToLeft)
                                }
                            }
                        }
                        .frame(maxHeight: 120)
                    }
                    
                    // Input field
                    HStack(spacing: 8) {
                        TextField("أضف تعليقًا", text: $interaction.newComment)
                            .padding(10)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                            .customFont(size: 12, weight: "Rubik-Medium")
                            .multilineTextAlignment(.trailing)
                            .environment(\.layoutDirection, .leftToRight)
                        
                        Button(action: {
                            let trimmed = interaction.newComment.trimmingCharacters(in: .whitespaces)
                            if !trimmed.isEmpty {
                                let userName = "محمد"
                                interaction.comments.append("/\(userName) \(trimmed)")
                                interaction.newComment = ""
                            }
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(Color("Bur"))
                                .padding(10)
                        }
                    }
                }
                .transition(.opacity)
            }
            
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}




private struct TransactionCardPreviewWrapper: View {
    @State var interaction = TransactionInteraction(
        log: ShareLog(
            tran_date_time: "2025-05-15T23:33:44.144Z",
            is_charge: false,
            amount: 250.00,
            is_liked: true,
            comments: ["جميل", "تم الاستلام"]
        ),
        likes: 2,
        comments: ["جميل", "تم الاستلام"]
    )
    
    var body: some View {
        TransactionCardView(interaction: $interaction)
            .padding()
    }
}

#Preview {
    TransactionCardPreviewWrapper()
}


