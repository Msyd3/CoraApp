import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            OnboardingView()
        } else {
            ZStack {
         
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    Image("cora-w")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                    
                    Spacer()
                    
                    Text("V 1.0.0")
                        .font(.callout)
                        .foregroundColor(.white)
                        .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    isActive = true
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
