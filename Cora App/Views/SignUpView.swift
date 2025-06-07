import SwiftUI

struct SignUpView: View {
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var passkey: String = ""
    @State private var otpCode: String = ""
    @State private var showOTP: Bool = false
    @State private var navigateToMain: Bool = false
    @State private var navigateToLogin: Bool = false
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var pendingUser: User?
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
                    
                    Text("Sign-Up".localized)
                        .customFont(size: 34, weight: "Rubik-Bold")
                    
                    TextField("Full Name", text: $name)
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                        .multilineTextAlignment(.trailing)
                        .customFont(size: 14, weight: "Rubik-Medium")
                    
                    TextField("05", text: $phone)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                        .multilineTextAlignment(.trailing)
                        .customFont(size: 14, weight: "Rubik-Medium")
                        .onChange(of: phone) { oldValue, newValue in
                            phone = filterPhoneNumber(newValue)
                        }
                    
                    SecureField("Passkey", text: $passkey)
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                        .multilineTextAlignment(.trailing)
                        .customFont(size: 14, weight: "Rubik-Medium")
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(Color("Rede"))
                            .customFont(size: 14, weight: "Rubik-Medium")
                            .multilineTextAlignment(.center)
                            .padding(.top, 5)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: -4) {
                        Button(action: {
                            checkPhoneNumberBeforeOTP()
                        }) {
                            if isLoading {
                                ProgressView()
                            } else {
                                Text("Sign-Up".localized)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("Bur"))
                                    .foregroundColor(.white)
                                    .customFont(size: 18, weight: "Rubik-Bold")
                                    .cornerRadius(12)
                            }
                        }
                        .disabled(isLoading)
                        .navigationDestination(isPresented: $navigateToLogin) {
                            LoginView()
                                .navigationBarBackButtonHidden(true)
                        }
                        .alert(isPresented: $showSuccessAlert) {
                            Alert(
                                title: Text("🎉 تم إنشاء الحساب!"),
                                message: Text("يرجى تسجيل الدخول للوصول إلى حسابك."),
                                dismissButton: .default(Text("تسجيل الدخول"), action: {
                                    navigateToLogin = true
                                })
                            )
                        }
                        
                        Button(action: {
                            navigateToLogin = true
                        }) {
                            Text("Already have an account? Log In")
                                .foregroundColor(Color("Prime").opacity(0.5))
                                .customFont(size: 14, weight: "Rubik-Regular")
                        }
                        .padding(.top)
                        .navigationDestination(isPresented: $navigateToLogin) {
                            LoginView()
                                .navigationBarBackButtonHidden(true)
                        }
                    }
                }
                .padding()
                .navigationBarBackButtonHidden(true)
                .onTapGesture {
                    isFieldFocused = false
                }
                
                InAppBannerNotification(
                    title: "تم إنشاء الحساب",
                    message: "مرحبا بك في كورا، تم إنشاء حسابك بنجاح!",
                    icon: Image("cora-logo"),
                    duration: 2.5,
                    isVisible: $showBanner
                )
            }
            .sheet(isPresented: $showOTP) {
                OTPVerificationView(
                    isVerified: $navigateToMain,
                    otpCode: $otpCode,
                    phoneNumber: phone,
                    registerUser: {
                        if let user = pendingUser {
                            registerUser(user: user)
                        }
                    },
                    onOTPEntered: { enteredOTP in
                        otpCode = enteredOTP
                        if let user = pendingUser {
                            registerUser(user: user)
                        }
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .cornerRadius(12)
            }
        }
    }
    
    func checkPhoneNumberBeforeOTP() {
        isLoading = true
        errorMessage = nil
        
        AuthService.shared.verifyPhoneNumber(phone: phone) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    pendingUser = User(name: name, phone: phone, passkey: passkey, otpCode: "")
                    handleSendOTP()
                case .failure(_):
                    self.errorMessage = "رقم الهاتف مسجل مسبقًا! يرجى تسجيل الدخول."
                }
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
    
    func validateInputs() -> Bool {
        if name.isEmpty || phone.isEmpty || passkey.isEmpty {
            errorMessage = "يرجى ملء جميع الحقول المطلوبة."
            return false
        }
        if phone.count != 10 || !phone.hasPrefix("05") {
            errorMessage = "يرجى إدخال رقم هاتف سعودي صحيح."
            return false
        }
        if passkey.count < 6 {
            errorMessage = "كلمة المرور يجب أن تكون على الأقل 6 أحرف."
            return false
        }
        return true
    }
    
    func handleSendOTP() {
        guard validateInputs() else { return }
        isLoading = true
        errorMessage = nil
        
        AuthService.shared.sendOTP(phone: phone, otpType: "USER_REGISTRATION") { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    self.showOTP = true
                case .failure(let error):
                    self.errorMessage = "⚠️ حدث خطأ أثناء إرسال OTP: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func registerUser(user: User) {
        var userWithOTP = user
        userWithOTP.otpCode = otpCode
        
        AuthService.shared.registerUser(user: userWithOTP) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    UserDefaults.standard.set(userWithOTP.phone, forKey: "phone_number")
                    UserDefaults.standard.set(userWithOTP.name, forKey: "\(userWithOTP.phone)_full_name")
                    
                    NotificationManager.shared.addNotification(
                        title: "تم إنشاء الحساب",
                        message: "مرحبا بك في كورا، تم إنشاء حسابك بنجاح!"
                    )
                    
                    showBanner = true
                    navigateToLogin = true
                case .failure(_):
                    errorMessage = "حدث خطأ أثناء التسجيل. حاول مرة أخرى."
                }
            }
        }
    }
}

#Preview {
    SignUpView()
}
