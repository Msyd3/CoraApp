//
//  LoginView.swift
//  Cora App
//
//  Created by Mohammed Alsayed on 02/03/2025.
//

import SwiftUI

struct LoginView: View {
    @State private var phone: String = ""
    @State private var passkey: String = ""
    @State private var navigateToMain: Bool = false
    @State private var navigateToSignUp: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showBanner = false 
    @FocusState private var isFieldFocused: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .trailing, spacing: 20) {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(Color("Bur"))
                        }
                        Spacer()
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                    VStack {
                        Image("cora-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                    }
                    
                    Text("Login".localized)
                        .customFont(size: 34, weight: "Rubik-Bold")
                    
                    TextField("05", text: $phone)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                        .multilineTextAlignment(.trailing)
                        .customFont(size: 14, weight: "Rubik-Medium")
                        .onChange(of: phone) { oldValue, newValue in
                            phone = filterPhoneNumber(newValue)
                        }
                    
                    SecureField("Passkey".localized, text: $passkey)
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                        .multilineTextAlignment(.trailing)
                        .customFont(size: 14, weight: "Rubik-Medium")
                    
                    Spacer()
                    
                    VStack(spacing: -4) {
                        Button(action: signInUser) {
                            Text("Login".localized)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("Bur"))
                                .foregroundColor(.white)
                                .customFont(size: 18, weight: "Rubik-Bold")
                                .cornerRadius(12)
                        }
                        
                        .navigationDestination(isPresented: $navigateToMain) {
                            TabBarView(phone: phone)
                                .navigationBarBackButtonHidden(true)
                        }
                        
                        Button(action: {
                            navigateToSignUp = true
                        }) {
                            Text("Don't have an account? Sign Up".localized)
                                .foregroundColor(Color("Prime").opacity(0.5))
                                .customFont(size: 14, weight: "Rubik-Regular")
                        }
                        .padding(.top)
                        .navigationDestination(isPresented: $navigateToSignUp) {
                            SignUpView()
                                .navigationBarBackButtonHidden(true)
                        }
                    }
                }
                .padding()
                .navigationBarBackButtonHidden(true)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                .onTapGesture {
                    isFieldFocused = false
                }
                
                
                InAppBannerNotification(
                    title: "تسجيل دخول",
                    message: "تم تسجيل دخولك بنجاح إلى كورا",
                    icon: Image("cora-logo"),
                    duration: 2.5,
                    isVisible: $showBanner
                )
            }
        }
    }
    
    func filterPhoneNumber(_ input: String) -> String {
        let englishNumbers = input.compactMap { char -> String? in
            if let digit = char.wholeNumberValue {
                return String(digit)
            }
            return nil
        }.joined()
        
        return String(englishNumbers.prefix(10))
    }
    
    func signInUser() {
        guard !phone.isEmpty, !passkey.isEmpty else {
            alertMessage = "Phone number and password cannot be empty."
            showAlert = true
            return
        }
        
        AuthService.shared.signInUser(phone: phone, passkey: passkey) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    NotificationManager.shared.addNotification(
                        title: "تسجيل دخول",
                        message: "تم تسجيل دخولك بنجاح إلى تطبيق كورا 👋"
                    )
                    
                    showBanner = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if phone == "0541009559" {
                            navigateToMain = true
                        } else {
                            UserDefaults.standard.set(phone, forKey: "phone_number")
                            UserDefaults.standard.set(passkey, forKey: "passkey")
                            navigateToMain = true
                        }
                    }
                    
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
    
}


#Preview {
    LoginView()
}

