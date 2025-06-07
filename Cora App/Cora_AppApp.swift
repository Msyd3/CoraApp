//
//  Cora_AppApp.swift
//  Cora App
//
//  Created by Mohammed Alsayed on 07/01/2025.
//

import SwiftUI

@main
struct Cora_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.locale, Locale(identifier: "ar"))
                .preferredColorScheme(.light)
        }
    }
}
