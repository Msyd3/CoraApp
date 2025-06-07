//
//  Activity.swift
//  Cora App
//
//  Created by Mohammed Alsayed on 28/01/2025.
//

import SwiftUI

struct ActivityView: View {
    @ObservedObject var logManager = ShareLogManager.shared
    @State private var showAddSheet = false
    @State private var fullName: String = "User"
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            TransactionListView(logManager: logManager)
        }
        .padding(.bottom, 100)
        .padding(.horizontal)
    }
}

#Preview {
    ActivityView()
}
