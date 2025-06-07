//
//  SelectionRow.swift
//  Cora App
//
//  Created by Mohammed Alsayed on 08/02/2025.
//

import SwiftUI


struct SelectionRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(value)
                .foregroundColor(.gray)
            Spacer()
            Text(title)
                .font(.body)
                .foregroundColor(Color("Prime"))
                .bold()
        }
        .padding(16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}
