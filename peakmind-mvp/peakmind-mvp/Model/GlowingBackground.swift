//
//  GlowingBackground.swift
//  peakmind-mvp
//
//  Created by Mingwei Li on 4/22/24.
//

import SwiftUI

struct GlowingBackground: View {
    var body: some View {
        Text("Your Text Here")
            .padding()
            .background(GlowingView(color: "1E4E96", frameWidth: 150, frameHeight: 50, cornerRadius: 10))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

struct GlowingView: View {
    var color: String
    var frameWidth: CGFloat
    var frameHeight: CGFloat
    var cornerRadius: CGFloat

    var body: some View {
        ZStack {
            let baseColor = Color(hex: color) ?? Color.black// Use the base color from hex
                        
            // Inner glow
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.2), baseColor.opacity(1.5)]),
                        center: .center,
                        startRadius: 5,
                        endRadius: 70
                    )
                )
                .blur(radius: 4)
            
            // Outer glow
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(baseColor.opacity(0.3), lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(baseColor.opacity(0.3), lineWidth: 0.5)
                        .blur(radius: 4)
                )
        }
        .frame(width: frameWidth, height: frameHeight)
    }
}


struct GlowingBackground_Previews: PreviewProvider {
    static var previews: some View {
        GlowingBackground()
    }
}
