//
//  StatefulPreviewWrapper.swift
//  Cora
//
//  Created by Mohammed Alsayed on 01/06/2025.
//

import SwiftUI

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    var content: (Binding<Value>) -> Content
    
    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        _value = State(wrappedValue: value)
        self.content = content
    }
    
    var body: some View {
        content($value)
    }
}
