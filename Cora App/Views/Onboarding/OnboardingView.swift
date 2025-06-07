import SwiftUI

struct OnboardingView: View {
    @State private var navigateToLogin = false
    @State private var currentPage = 0
    
    let onboardingData = [
        ("threeO", "OnboardingTitle3", "OnboardingDescription3"),
        ("twoO", "OnboardingTitle2", "OnboardingDescription2"),
        ("one", "OnboardingTitle1", "OnboardingDescription1")
    ]
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 10) {
                    
                    // Onboarding pages
                    TabView(selection: $currentPage) {
                        ForEach(0..<onboardingData.count, id: \.self) { index in
                            VStack {
                                Image(onboardingData[index].0)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: geometry.size.height * 0.4)
                                    .padding(.horizontal, 20)
                                
                                VStack(spacing: 10) {
                                    Text(onboardingData[index].1.localized)
                                        .customFont(size: 24, weight: "Rubik-Bold")
                                        .foregroundColor(Color("Prime"))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 40)
                                    
                                    Text(onboardingData[index].2.localized)
                                        .customFont(size: 14, weight: "Rubik-Light")
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 40)
                                }
                                .padding(.top, 20)
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())

                    
                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(0..<onboardingData.count, id: \.self) { index in
                            Circle()
                                .frame(width: 8, height: 8)
                                .foregroundColor(currentPage == index ? Color("Bur") : Color.gray.opacity(0.4))
                        }
                    }
                    .padding(.top, -10)
                    
                    Spacer()
                    
                    // Login button
                    Button(action: {
                        navigateToLogin = true
                    }) {
                        Text("Login".localized)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("Bur"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 100 : 40)
                            .customFont(size: 18, weight: "Rubik-Bold")
                    }
                    .navigationDestination(isPresented: $navigateToLogin) {
                        LoginView()
                            .navigationBarBackButtonHidden(true)
                    }
                    
                    Spacer()
                }
                .padding(.top)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .navigationBarBackButtonHidden(true)
                .background(Color.white.ignoresSafeArea())
            }
        }
    }
}

#Preview {
    OnboardingView()
}
