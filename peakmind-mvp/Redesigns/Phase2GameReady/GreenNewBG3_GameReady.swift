//
//  GreenNewBG3.swift
//  peakmind-mvp
//
//  Created by ZA on 9/17/24.
//

import SwiftUI

struct P2_3_1: View {
    var closeAction: () -> Void
    @State private var showNextScreen = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("GreenNewBG")
                    .resizable()
                    .clipped() // Ensures the image fills the screen without distortion
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    Spacer()
                        .frame(height: 120)
                    
                    // Intro Text
                    Text("Let's take a moment to center ourselves with a breathing exercise. This technique will help clear your mind and wash away any built-up stress. Deep breaths are a powerful tool for relaxation")
                        .font(.custom("SFProText-Bold", size: 30))
                        .foregroundColor(Color("GreenTitleColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    Spacer()
                    
                    // Next Button
                    Button(action: {
                        showNextScreen = true
                    }) {
                        Text("Next")
                            .font(.custom("SFProText-Bold", size: 20))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("GreenButtonGradientColor1"), Color("GreenButtonGradientColor2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: Color.white.opacity(1), radius: 10, x: 0, y: 0)
                    }
                    .padding(.bottom, 50)
                    .background(
                        NavigationLink(
                            destination: P2_3_2(closeAction: closeAction),
                            isActive: $showNextScreen,
                            label: { EmptyView() }
                        )
                    )
                }
                .padding(.horizontal)
            }
        }
    }
}