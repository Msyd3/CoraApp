//
//  OnboardingPage.swift
//  Cora
//
//  Created by Mohammed Alsayed on 21/03/2025.
//

import SwiftUI

struct OnboardingPage: View {
    let image: String
    let titleKey: String
    let descriptionKey: String
    
    var body: some View {
        VStack {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(height: 400)
                .padding(.horizontal, 20)
            
            VStack(spacing: 10) {
                Text(titleKey.localized)
                    .customFont(size: 24, weight: "Rubik-Bold")
                    .foregroundColor(Color("Prime"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Text(descriptionKey.localized)
                    .customFont(size: 14, weight: "Rubik-Light")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.top, 20)
        }
    }
}
