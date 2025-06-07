//
//  ContentView.swift
//  Cora App
//
//  Created by Mohammed Alsayed on 07/01/2025.
//


import SwiftUI

struct ContentView: View {
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        
        SplashScreenView()
            .environment(\.layoutDirection, .leftToRight)
            .environment(\.locale, Locale(identifier: "ar")) 
    }
}

#Preview {
    ContentView()
}
