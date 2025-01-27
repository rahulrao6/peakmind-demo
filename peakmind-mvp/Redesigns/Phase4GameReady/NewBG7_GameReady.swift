//
//  NewBG7.swift
//  peakmind-mvp
//
//  Created by ZA on 9/24/24.
//

import SwiftUI

struct P4_7_1: View {
    var closeAction: (String) -> Void
    @State private var showNextScreen = false
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 120)
            
            // Intro Text
            Text("Creating a consistent routine can be a powerful tool for managing anxiety. This module will guide you through steps to establish healthy habits that promote calm and balance.")
                .font(.custom("SFProText-Bold", size: 30))
                .foregroundColor(Color("QuestionHeaderColor"))
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
                            gradient: Gradient(colors: [Color("ButtonGradient1"), Color("ButtonGradient2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(15)
                    .shadow(color: Color.white.opacity(1), radius: 10, x: 0, y: 0)
            }
            .padding(.bottom, 50)

            .fullScreenCover(isPresented: $showNextScreen) {
                P4_7_2(closeAction: closeAction)
            }
        }
        .padding(.horizontal)
        .background(
            Image("NewBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
        )
    }
}
