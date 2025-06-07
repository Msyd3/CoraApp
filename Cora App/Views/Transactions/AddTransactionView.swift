//
//  AddTransactionView.swift
//  Cora
//
//  Created by Mohammed Alsayed on 11/04/2025.
//

import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var place = ""
    @State private var amount = ""
    @State private var type = "pay"
    let types = ["receive", "pay"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("المكان أو الجهة", text: $place)
                    .padding()
                    .customFont(size: 14, weight: "Rubik-Medium")
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                
                TextField("المبلغ", text: $amount)
                    .keyboardType(.decimalPad)
                    .customFont(size: 14, weight: "Rubik-Medium")
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                
                HStack(spacing: 16) {
                    ForEach(types, id: \.self) { option in
                        Button(action: {
                            type = option
                        }) {
                            Text(option == "receive" ? "استلام" : "دفع")
                                .customFont(size: 14, weight: "Rubik-Medium")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .foregroundColor(type == option ? Color(option == "receive" ? "Greend" : "Rede") : Color.gray)
                                .cornerRadius(12)
                        }
                    }
                }
                
                Button(action: {
                    saveTransaction()
                    dismiss()
                }) {
                    Text("حفظ العملية")
                        .customFont(size: 16, weight: "Rubik-Bold")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Bur"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(place.isEmpty || amount.isEmpty)
                .padding(.top, 40)
            }
            .padding()
            .navigationTitle("عملية جديدة")
            .customFont(size: 16, weight: "Rubik-Bold")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إلغاء") {
                        dismiss()
                    }
                    .foregroundColor(Color("Bur"))
                }
            }
        }
    }
    
    func saveTransaction() {
        guard let amountValue = Double(amount), !place.isEmpty else { return }
        
        let log = ShareLog(
            tran_date_time: ISO8601DateFormatter().string(from: Date()),
            is_charge: type == "pay",
            amount: amountValue,
            is_liked: false,
            comments: []
        )
        
        ShareLogManager.shared.add(log: log)
    }
}

#Preview {
    AddTransactionView()
}
