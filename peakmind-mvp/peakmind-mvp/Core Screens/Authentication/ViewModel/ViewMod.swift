//
//  ViewMod.swift
//  peakmind-mvp
//
//  Created by ZA on 7/23/24.
//

import SwiftUI

struct PlaceholderTextFieldModifier: ViewModifier {
    var placeholder: String
    var placeholderColor: Color
    @Binding var text: String

    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(placeholderColor)
                    .padding(.leading, 5)
            }
            content
                .foregroundColor(.black)
                .padding(10)
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2)
                )
        }
    }
}

extension View {
    func placeholderStyle(placeholder: String, placeholderColor: Color, text: Binding<String>) -> some View {
        self.modifier(PlaceholderTextFieldModifier(placeholder: placeholder, placeholderColor: placeholderColor, text: text))
    }
}

