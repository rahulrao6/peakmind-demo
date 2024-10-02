//
//  LightPurpleNewBG3.swift
//  peakmind-mvp
//
//  Created by ZA on 10/1/24.
//

import SwiftUI

struct P5_3_1: View {
    var closeAction: (String) -> Void
    @State private var showNextScreen = false
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 160)
            
            // Intro Text
            Text("Let's take a moment to answer a wellness question. This will help us understand when a support system is most essential for you.")
                .font(.custom("SFProText-Bold", size: 30))
                .foregroundColor(Color("LightPurpleTitleColor"))
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
                            gradient: Gradient(colors: [Color("LightPurpleButtonGradientColor1"), Color("LightPurpleButtonGradientColor2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(15)
                    .shadow(color: Color.white.opacity(1), radius: 10, x: 0, y: 0)
            }
            .padding(.bottom, 50)
            .fullScreenCover(isPresented: $showNextScreen) {
                P5_3_2(closeAction: closeAction)
            }
        }
        .padding(.horizontal)
        .background(
            Image("LightPurpleNewBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
        )
    }
}
