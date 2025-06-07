//
//  TabBarView.swift
//  Cora App
//
//  Created by Mohammed Alsayed on 23/01/2025.
//


import SwiftUI

struct TabBarView: View {
    let phone: String
    @State private var selectedTab = 0
    @State private var contacts: [Contact] = []

    init(phone: String) {
        self.phone = phone
        UITabBar.appearance().backgroundColor = UIColor.white
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            Group {
                if phone == "0541009559" {
                    MainView(contacts: $contacts)
                } else {
                    MainOnboardingView(logManager: ShareLogManager())
                }
            }
            .tabItem {
                Image("home")
                    .renderingMode(.template)
                Text("Home")
                    .customFont(size: 16, weight: "Rubik-SemiBold")
            }
            .tag(0)
            
            
            ActivityView()
                .tabItem {
                    Image("activity")
                        .renderingMode(.template)
                    Text("Activity")
                        .customFont(size: 16, weight: "Rubik-SemiBold")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Image("profile")
                        .renderingMode(.template)
                    Text("Profile")
                        .customFont(size: 16, weight: "Rubik-SemiBold")
                }
                .tag(2)
        }
        .accentColor(Color("Bur"))
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(phone: "0541009559")
    }
}
