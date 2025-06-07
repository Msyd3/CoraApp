

import SwiftUI

struct ProfileView: View {
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var email: String = ""
    @State private var navigateToOnboarding = false
    @State private var showSavedAlert = false
    @State private var originalName = ""
    @State private var originalEmail = ""
    @State private var showBankSheet = false
    @State private var showContactSheet = false
    @State private var showCopiedAlert = false
    
    @StateObject private var viewModel = CustomLinkViewModel()
    @State private var linkName = ""
    @State private var isLinkConfirmed = false
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Image("cora-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                    
                    profileField(title: "Name", text: $name)
                    profileField(title: "Email", text: $email)
                    
                    HStack {
                        Text(phone)
                            .foregroundColor(.gray)
                            .customFont(size: 16, weight: "Rubik-Regular")
                        Spacer()
                        Text("Phone Number")
                            .customFont(size: 16, weight: "Rubik-Medium")
                            .foregroundColor(Color("Prime"))
                    }
                    .padding(16)
                    .background(Color("LightGreen"))
                    .cornerRadius(12)
                    
            
                    if isLinkConfirmed {
                        Button(action: {
                            UIPasteboard.general.string = "https://cora.sa/\(viewModel.userDomain)"
                            showCopiedAlert = true
                        }) {
                            HStack {
                                Text("Cora.sa/\(viewModel.userDomain)")
                                    .customFont(size: 16, weight: "Rubik-Regular")
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Text("Link")
                                    .customFont(size: 16, weight: "Rubik-Medium")
                                    .foregroundColor(Color("Prime"))
                                    .bold()
                            }
                            .padding(16)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                        }
                        .alert("تم نسخ الرابط", isPresented: $showCopiedAlert) {
                            Button("موافق", role: .cancel) { }
                        }
                    } else {
                        VStack(alignment: .trailing, spacing: 10) {
                            Text("Choose-Your-Custom-Link")
                                .customFont(size: 18, weight: "Rubik-Bold")
                                .foregroundColor(.black)
                            
                            Text("Pick-a-unique-username-to-generate-your-personal-link")
                                .customFont(size: 12, weight: "Rubik-Medium")
                                .foregroundColor(.gray)
                            
                            HStack {
                                Button(action: {
                                    viewModel.checkAndReserveDomain(linkName: linkName, isLinkConfirmed: $isLinkConfirmed)
                                }) {
                                    if viewModel.isLoading {
                                        ProgressView()
                                    } else {
                                        Text(viewModel.buttonText)
                                    }
                                }
                                .padding()
                                .background(viewModel.buttonColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .customFont(size: 12, weight: "Rubik-Medium")
                                .disabled(linkName.isEmpty || isLinkConfirmed)
                                
                                TextField("Enter-your-link-name", text: $linkName)
                                    .padding()
                                    .background(Color.gray.opacity(0.05))
                                    .cornerRadius(12)
                                    .disabled(isLinkConfirmed)
                                    .customFont(size: 12, weight: "Rubik-Medium")
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 0.5)
                    }
                    
                    section(title: "Bank Accounts") {
                        showBankSheet = true
                    }
                    
                    section(title: "Contacts") {
                        showContactSheet = true
                    }
                    
                    Button(action: saveProfile) {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background((name != originalName || email != originalEmail) ? Color("Bur") : Color.white)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .customFont(size: 16, weight: "Rubik-SemiBold")
                    }
                    .disabled(name == originalName && email == originalEmail)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Button(action: logoutUser) {
                    Text("logout".localized)
                        .customFont(size: 16, weight: "Rubik-SemiBold")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("LightRed"))
                        .foregroundColor(Color("Rede"))
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                }
                
                Text("V 1.0.0")
                    .font(.footnote)
                    .foregroundColor(.gray)
                
                HStack(spacing: 16) {
                    footerLink("Privacy Policy", url: "https://cora.sa/PrivacyPolicy")
                    footerLink("F&Q", url: "https://cora.sa/FAQ")
                    footerLink("Contact Us", url: "https://cora.sa/Contact")
                }
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            if let phoneKey = UserDefaults.standard.string(forKey: "phone_number") {
                name = UserDefaults.standard.string(forKey: "\(phoneKey)_full_name") ?? ""
                email = UserDefaults.standard.string(forKey: "\(phoneKey)_user_email") ?? ""
                phone = phoneKey
                originalName = name
                originalEmail = email
            }
            
            viewModel.fetchUserDomain(isLinkConfirmed: $isLinkConfirmed)
        }
        .sheet(isPresented: $showBankSheet) {
            BankAccountsView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showContactSheet) {
            NavigationView {
                ManageContacts(selectedContact: .constant("Select Contact"))
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .navigationDestination(isPresented: $navigateToOnboarding) {
            OnboardingView().navigationBarBackButtonHidden(true)
        }
    }
    
    // MARK: - Components
    
    func profileField(title: String, text: Binding<String>) -> some View {
        HStack {
            TextField(title, text: text)
                .multilineTextAlignment(.leading)
                .foregroundColor(.gray)
                .customFont(size: 16, weight: "Rubik-Regular")
            
            Spacer()
            
            Text(title)
                .customFont(size: 16, weight: "Rubik-Medium")
                .foregroundColor(Color("Prime"))
        }
        .padding(16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    func section(title: String, action: @escaping () -> Void) -> some View {
        HStack {
            Button(action: action) {
                Text("Manage")
                    .customFont(size: 16, weight: "Rubik-Medium")
                    .foregroundColor(Color("Bur"))
            }
            
            Spacer()
            
            Text(title)
                .customFont(size: 16, weight: "Rubik-Medium")
                .foregroundColor(Color("Prime"))
                .bold()
        }
        .padding(16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    func footerLink(_ title: String, url: String) -> some View {
        Button(action: {
            if let link = URL(string: url) {
                UIApplication.shared.open(link)
            }
        }) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
    
    func saveProfile() {
        if let phoneKey = UserDefaults.standard.string(forKey: "phone_number") {
            UserDefaults.standard.set(name, forKey: "\(phoneKey)_full_name")
            UserDefaults.standard.set(email, forKey: "\(phoneKey)_user_email")
        }
        originalName = name
        originalEmail = email
        showSavedAlert = true
    }
    
    func logoutUser() {
        UserDefaults.standard.removeObject(forKey: "auth_token")
        UserDefaults.standard.removeObject(forKey: "phone_number")
        UserDefaults.standard.removeObject(forKey: "passkey")
        UserDefaults.standard.synchronize()
        navigateToOnboarding = true
    }
}




#Preview {
    ProfileView()
}
