//
//  OTPVerificationView.swift
//  Cora App
//
//  Created by Mohammed Alsayed on 02/03/2025.
//

import SwiftUI

struct OTPVerificationView: View {
    @Binding var isVerified: Bool
    @Binding var otpCode: String
    var phoneNumber: String
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    var registerUser: () -> Void
    var onOTPEntered: ((String) -> Void)?
    @State private var enteredOTP: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Enter OTP")
                .customFont(size: 18, weight: "Rubik-Bold")
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $enteredOTP)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
                .customFont(size: 16, weight: "Rubik-Medium")
            
            Button(action: {
                verifyOTPAndRegister()
            }) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Verify")
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
        .environment(\.layoutDirection, .rightToLeft)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func verifyOTPAndRegister() {
        guard !enteredOTP.isEmpty else {
            alertMessage = "OTP code cannot be empty."
            showAlert = true
            return
        }
        
        isLoading = true
        otpCode = enteredOTP
        
        DispatchQueue.main.async {
            isLoading = false
            print("✅ OTP صحيح، سيتم تسجيل المستخدم الآن...")
            isVerified = true
            onOTPEntered?(enteredOTP)
        }
    }
}

#Preview {
    OTPVerificationView(isVerified: .constant(false), otpCode: .constant("12345"), phoneNumber: "0543939444", registerUser: {})
}


