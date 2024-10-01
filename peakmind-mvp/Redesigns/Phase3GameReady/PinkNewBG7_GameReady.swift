//
//  PinkNewBG7.swift
//  peakmind-mvp
//
//  Created by ZA on 9/23/24.
//

import SwiftUI

struct P3_7_1: View {
    var closeAction: (String) -> Void
    @State private var showNextScreen = false
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 120)
            
            // Intro Text
            Text("Level up your anxiety response! Let's dive into a real-life scenario and practice using your coping mechanisms.")
                .font(.custom("SFProText-Bold", size: 36))
                .foregroundColor(Color("PinkTitleColor"))
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
                            gradient: Gradient(colors: [Color("PinkButtonGradientColor1"), Color("PinkButtonGradientColor2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(15)
                    .shadow(color: Color.white.opacity(1), radius: 10, x: 0, y: 0)
            }
            .padding(.bottom, 50)

            .fullScreenCover(isPresented: $showNextScreen) {
                P3_7_2(closeAction: closeAction)
            }
        }
        .padding(.horizontal)
        .background(
            Image("PinkNewBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
        )
    }
}
