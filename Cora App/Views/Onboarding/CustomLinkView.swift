//
//  CustomLinkView.swift
//  Cora App
//
//  Created by Mohammed Alsayed on 04/03/2025.
//

//
//  CustomLinkView.swift
//  Cora App
//


import SwiftUI

struct CustomLinkView: View {
    @State private var linkName = ""
    @State private var isLinkConfirmed = false
    @StateObject private var viewModel = CustomLinkViewModel()
    
    var body: some View {
        ZStack {
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
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 0.5)
            .onAppear {
                viewModel.fetchUserDomain(isLinkConfirmed: $isLinkConfirmed)
            }
            
            InAppBannerNotification(
                title: "تم حجز الرابط",
                message: "تم اختيار رابطك المخصص بنجاح!",
                icon: Image("cora-logo"),
                duration: 2.5,
                isVisible: $viewModel.showBanner
            )
        }
    }
}

#Preview {
    CustomLinkView()
}
