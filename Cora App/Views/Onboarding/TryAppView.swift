//
//  TryAppView.swift
//  Cora App
//
//  Created by Mohammed Alsayed on 04/03/2025.
//

//
//  TryAppView.swift
//  Cora App
//

import SwiftUI

struct TryAppView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("try_app_first".localized)
                .customFont(size: 20, weight: "Rubik-Bold")
                .foregroundColor(.white)
            
            Text("move_up_list".localized)
                .customFont(size: 12, weight: "Rubik-Medium")
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
}

#Preview {
    TryAppView()
}
