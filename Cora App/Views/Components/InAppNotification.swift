//
//  InAppNotification.swift
//  Cora
//
//  Created by Mohammed Alsayed on 08/04/2025.
//



import SwiftUI

struct InAppBannerNotification: View {
    let title: String
    let message: String
    let icon: Image
    let duration: Double
    @Binding var isVisible: Bool
    
    var body: some View {
        if isVisible {
            VStack {
                HStack(alignment: .center, spacing: 12) {
                    icon
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(title.trimmingCharacters(in: .whitespacesAndNewlines))
                            .customFont(size: 16, weight: "Rubik-Bold")
                            .foregroundColor(.black)
                        
                        Text(message.trimmingCharacters(in: .whitespacesAndNewlines))
                            .customFont(size: 12, weight: "Rubik-Regular")
                            .foregroundColor(.black.opacity(0.85))
                    }
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding()
                .background(.ultraThinMaterial)
                .background(Color.gray.opacity(0.005))
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.top, 60)
                
                Spacer()
            }

            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.easeInOut(duration: 0.3), value: isVisible)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation {
                        isVisible = false
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    InAppBannerPreview()
}

struct InAppBannerPreview: View {
    @State private var isVisible = true
    
    var body: some View {
        ZStack {
            Color.white
            
            InAppBannerNotification(
                title: "تم إرسال الطلب",
                message: "شكراً لاستخدامك كورا",
                icon: Image("cora-logo"),
                duration: 3.0,
                isVisible: $isVisible
            )
        }
        .ignoresSafeArea()
    }
}
