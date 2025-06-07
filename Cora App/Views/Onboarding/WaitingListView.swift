//
//  WaitingListView.swift
//  Cora App
//
//  Created by Mohammed Alsayed on 04/03/2025.
//

import SwiftUI

struct WaitingListView: View {
    @State private var totalAccountCount: Int = 0
    @State private var accountOrder: Int = 0
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 10) {
            
            Text("waiting_list")
                .customFont(size: 22, weight: "Rubik-Bold")
                .foregroundColor(.gray)
            
            if isLoading {
                ProgressView()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .customFont(size: 18, weight: "Rubik-Medium")
            } else {
                HStack {
                    Text(String(format: "%d", totalAccountCount))
                        .customFont(size: 22, weight: "Rubik-Bold")
                        .foregroundColor(Color("Prime"))
                    
                    Text("queue_position_middle")
                        .customFont(size: 22, weight: "Rubik-Medium")
                        .foregroundColor(Color("Prime"))
                    
                    Text(String(format: "%d", accountOrder))
                        .customFont(size: 22, weight: "Rubik-ExtraBold")
                        .foregroundColor(Color("Bur"))
                    
                    Text("queue_position_start")
                        .customFont(size: 22, weight: "Rubik-Medium")
                        .foregroundColor(Color("Prime"))
                }
            }
        }
     
        .onAppear {
            loadWaitingListData()
        }
    }
    
    func loadWaitingListData() {
        DispatchQueue.main.async {
            if let storedAccountOrder = UserDefaults.standard.value(forKey: "account_order") as? Int,
               let storedTotalAccounts = UserDefaults.standard.value(forKey: "total_account_count") as? Int {
                
                self.accountOrder = storedAccountOrder
                self.totalAccountCount = storedTotalAccounts
                self.isLoading = false
                
            } else {
                self.errorMessage = "⚠️ لا توجد بيانات انتظار محفوظة!"
                self.isLoading = false
            }
        }
    }
    
    
    
}

#Preview {
    WaitingListView()
}
