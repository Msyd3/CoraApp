//
//  FontModifier.swift
//  Cora App
//
//  Created by Mohammed Alsayed on 04/03/2025.
//

import SwiftUI

struct CustomFontModifier: ViewModifier {
    var size: CGFloat
    var weight: String
    
    func body(content: Content) -> some View {
        content.font(.custom(weight, size: size))
    }
}

extension View {
    func customFont(size: CGFloat, weight: String = "Rubik-Regular") -> some View {
        self.modifier(CustomFontModifier(size: size, weight: weight))
    }
}
