//
//  SummaryTransView.swift
//  Cora
//
//  Created by Mohammed Alsayed on 25/05/2025.
//

import SwiftUI

struct SummaryTransView: View {
    let toContact: String
    let fromUserName: String
    let amount: Double
    let vat: Double
    let totalFee: Double
    let comments: [String]
    @Binding var otpCode: String
    @Binding var isVerified: Bool
    var phoneNumber: String
    var beneficiaryID: String
    
    @State private var showOTP = false
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Summary")
                        .customFont(size: 22, weight: "Rubik-Bold")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 40)
                    
                    summaryCard(title: "To", name: toContact, iban: "SA4005000068204100577000")
                    summaryCard(title: "From", name: fromUserName, iban: "Main account")
                    
                    if !comments.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Comments")
                                .customFont(size: 16, weight: "Rubik-SemiBold")
                            ForEach(comments, id: \.self) { comment in
                                Text(comment)
                                    .customFont(size: 16, weight: "Rubik-Regular")
                                    .padding(10)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Details")
                            .customFont(size: 16, weight: "Rubik-Bold")
                        
                        summaryRow(title: "Amount", value: amount)
                        summaryRow(title: "VAT", value: vat)
                        summaryRow(title: "Fee", value: totalFee)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                }
                .padding()
            }
            
            Button(action: {
                showOTP = true
            }) {
                Text("Confirm")
                    .customFont(size: 18, weight: "Rubik-Medium")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color("Bur"))
                    .cornerRadius(12)
            }
            .padding()
            .sheet(isPresented: $showOTP) {
                GenOTPView(
                    phoneNumber: phoneNumber,
                    isVerified: $isVerified,
                    otpCode: $otpCode,
                    onOTPConfirmed: { _ in
                        performTransfer()
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
    
    func summaryCard(title: String, name: String, iban: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            Text(name).font(.body.bold())
            Text(formatIban(iban)).font(.caption).foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    func summaryRow(title: String, value: Double) -> some View {
        HStack {
            Text(title).customFont(size: 14, weight: "Rubik-Regular")
            Spacer()
            HStack(spacing: 4) {
                Text(String(format: "%.2f", value))
                Image("SAR").resizable().frame(width: 14, height: 14)
            }
        }
    }
    
    func formatIban(_ iban: String) -> String {
        let clean = iban.replacingOccurrences(of: " ", with: "")
        guard clean.count >= 4 else { return iban }
        return "SA** **** **** **** " + clean.suffix(4)
    }
    
    func performTransfer() {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/endUser/wallet-transfers/transfer-amount-to-beneficiary") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let body: [String: Any] = [
            "amount": amount,
            "beneficiary_id": beneficiaryID,
            "comments": comments.first ?? "",
            "otp_code": otpCode
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ Transfer failed:", error)
                return
            }
            DispatchQueue.main.async {
                print("✅ Transfer successful")
            }
        }.resume()
    }
}



#Preview {
    SummaryTransView(
        toContact: "Fahad",
        fromUserName: "Fahad",
        amount: 100,
        vat: 0,
        totalFee: 0,
        comments: ["Monthly rent"],
        otpCode: .constant(""),
        isVerified: .constant(false),
        phoneNumber: "0500000000",
        beneficiaryID: "abc123"
    )
}

