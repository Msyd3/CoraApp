//
//  FastTransactionView.swift
//  Cora App
//
//  Created by Mohammed Alsayed on 08/02/2025.
//

import SwiftUI

struct FastTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var showSuccess: Bool
    @Binding var contacts: [Contact]
    
    @State private var showContactSheet = false
    @State private var amountText: String = ""
    @State private var isOverLimit: Bool = false
    @State private var note: String = ""
    @State private var selectedContact: Contact? = nil
    @State private var navigateToSummary = false
    @StateObject var balanceManager = BalanceManager()
    
    @State private var otpCode: String = ""
    @State private var isOTPVerified = false
    @State private var phoneNumber = UserDefaults.standard.string(forKey: "phone_number") ?? ""
    
    var sendIsValid: Bool {
        guard let value = Double(amountText), selectedContact != nil else { return false }
        return value > 0 && value <= 5000 && !isOverLimit
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                ScrollView {
                    BalanceCardView(balance: $balanceManager.currentBalance)
                        .padding(.horizontal)
                    
                    VStack(spacing: 20) {
                        amountField
                        selectContact
                        commentField
                        sendButton
                    }
                }
                .padding(.top, 40)
                .navigationDestination(isPresented: $navigateToSummary) {
                    SummaryTransView(
                        toContact: selectedContact?.name ?? "",
                        fromUserName: "mohamed",
                        amount: Double(amountText) ?? 0,
                        vat: 0,
                        totalFee: 0,
                        comments: note.isEmpty ? [] : [note],
                        otpCode: $otpCode,
                        isVerified: $isOTPVerified,
                        phoneNumber: phoneNumber,
                        beneficiaryID: selectedContact?.beneficiary_id ?? ""
                    )
                }
            }
        }
    }
    
    private var amountField: some View {
        VStack(alignment: .trailing) {
            Text("Amount")
                .customFont(size: 14, weight: "Rubik-Regular")
                .foregroundColor(.gray)
            HStack {
                Image("SAR").resizable().frame(width: 24, height: 24)
                Spacer()
                TextField("0.0", text: $amountText)
                    .keyboardType(.numberPad)
                    .font(.system(size: 44))
                    .bold()
                    .foregroundColor(isOverLimit ? Color("Rede") : Color("Bur"))
                    .multilineTextAlignment(.trailing)
                    .onChange(of: amountText) { newValue in
                        amountText = newValue.filter("0123456789.".contains)
                        if let value = Double(amountText) {
                            isOverLimit = value > balanceManager.currentBalance
                        } else {
                            isOverLimit = false
                        }
                    }
            }
        }
        .padding(.top, 40)
        .padding(.horizontal)
    }
    
    private var selectContact: some View {
        Button(action: { showContactSheet.toggle() }) {
            SelectionRow(title: "To", value: selectedContact?.name ?? "Select Contact")
        }
        .sheet(isPresented: $showContactSheet) {
            ContactSelectView(selectedContact: $selectedContact)
        }
        .padding(.top, 40)
    }
    
    private var commentField: some View {
        VStack(alignment: .trailing) {
            Text("Comment")
                .customFont(size: 14, weight: "Rubik-Regular")
                .foregroundColor(.gray)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.05))

                if note.isEmpty {
                    Text("")
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.top, 12)
                        .padding(.horizontal, 16)
                }

                TextEditor(text: $note)
                    .padding(12)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                    .customFont(size: 16, weight: "Rubik-Medium")
                    .cornerRadius(12)
                    .onChange(of: note) { newValue in
                        if newValue.count > 250 {
                            note = String(newValue.prefix(250))
                        }
                    }
            }
            .frame(height: 120)
        }
        .padding(.top, 20)
        .padding(.horizontal)
    }

    
    private var sendButton: some View {
        Button(action: {
            sendOTP()
        }) {
            Text("Send")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(sendIsValid ? Color("Bur") : Color("Bur").opacity(0.5))
                .cornerRadius(12)
        }
        .disabled(!sendIsValid)
        .padding(.horizontal)
        .padding(.top, 40)
    }
    
    private func sendOTP() {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/authentication/send-otp") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "phoneNumber": phoneNumber,
            "otpType": "TRANSFER",
            "amount": Double(amountText) ?? 0
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("❌ OTP Error:", error)
                return
            }
            DispatchQueue.main.async {
                navigateToSummary = true
            }
        }.resume()
    }
}



#Preview {
    FastTransactionView(
        showSuccess: .constant(false),
        contacts: .constant([])
    )
}



