//
//  ConfettiView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/17/24.
//

import SwiftUI

struct ConfettiView: View {
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
    var confettiCount: Int = 100
    var animate: Bool 

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<confettiCount, id: \.self) { index in
                    Circle()
                        .foregroundColor(colors[index % colors.count])
                        .frame(width: 6, height: 6)
                        .scaleEffect(animate ? 1 : 0)
                        .position(x: CGFloat.random(in: 0...geometry.size.width), y: animate ? geometry.size.height + 100 : -100)
                        .animation(Animation.linear(duration: 2)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(index) * 0.05), value: animate)
                }
            }
        }
    }
}

