//
//  GenOTP.swift
//  Cora
//
//  Created by Mohammed Alsayed on 02/06/2025.
//

import SwiftUI

struct GenOTPView: View {
    var title: String = "Enter Verification Code"
    var confirmButtonText: String = "Confirm"
    var phoneNumber: String
    @Binding var isVerified: Bool
    @Binding var otpCode: String
    var onOTPConfirmed: ((String) -> Void)? = nil
    
    @State private var enteredOTP: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .customFont(size: 18, weight: "Rubik-Bold")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Enter OTP", text: $enteredOTP)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
                .customFont(size: 16, weight: "Rubik-Medium")
            
            Button(action: {
                confirmOTP()
            }) {
                if isLoading {
                    ProgressView()
                } else {
                    Text(confirmButtonText)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Bur"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .customFont(size: 18, weight: "Rubik-Bold")
                }
            }
            .disabled(isLoading || enteredOTP.isEmpty)
        }
        .padding()
        .environment(\.layoutDirection, .leftToRight)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func confirmOTP() {
        guard !enteredOTP.isEmpty else {
            alertMessage = "OTP cannot be empty."
            showAlert = true
            return
        }
        isLoading = true
        otpCode = enteredOTP
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isVerified = true
            isLoading = false
            onOTPConfirmed?(enteredOTP)
        }
    }
}


#Preview {
    GenOTPView(
        phoneNumber: "0500000000",
        isVerified: .constant(false),
        otpCode: .constant(""),
        onOTPConfirmed: { code in
            print("OTP confirmed: \(code)")
        }
    )
}
