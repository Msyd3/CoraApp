//
//  MainOnboardingView.swift
//  Cora App
//
//  Created by Mohammed Alsayed on 03/03/2025.
//


import SwiftUI

struct MainOnboardingView: View {
    @State private var linkName: String = ""
    @State private var isLinkConfirmed: Bool = false
    @State private var navigateToOnboarding = false
    @State private var showNotifications = false
    @State private var showChat = false
    @ObservedObject var logManager: ShareLogManager
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    
                    Image("cora-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                    
                    HStack {
                        Button(action: {
                            showNotifications = true
                        }) {
                            Image(systemName: "bell.fill")
                                .font(.title2)
                                .foregroundColor(Color("Prime"))
                        }
                        
                        Spacer()
                        
                        Text("👋🏻")
                            .customFont(size: 30)
                        
                        Text("Hello".localized)
                            .customFont(size: 30, weight: "Rubik-Bold")
                            .foregroundColor(Color("Prime"))
                    }
                    .padding(.bottom,20)
                    
                    
                    WaitingListView()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(24)
                        .padding(.bottom, 40)
                    
                    VStack{
                        
                        CustomLinkView()
                        
                        TryAppView()
                            .padding(.top, 40)
                        
                        ShareButtonView(logManager: logManager)
                    }
                    .padding()
                    .background(Color("Bur"))
                    .cornerRadius(24)
                    
                    
                    .padding(.vertical)
                    
                }
                .sheet(isPresented: $showNotifications) {
                    NotificationView()
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
                .padding(.horizontal, 20)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    func logoutUser() {
        UserDefaults.standard.removeObject(forKey: "auth_token")
        UserDefaults.standard.removeObject(forKey: "phone_number")
        UserDefaults.standard.removeObject(forKey: "passkey")
        UserDefaults.standard.synchronize()
        
        DispatchQueue.main.async {
            navigateToOnboarding = true
        }
    }
}

#Preview {
    MainOnboardingView(logManager: ShareLogManager())
}
