//
//  PurpleNewBG9.swift
//  peakmind-mvp
//
//  Created by ZA on 8/28/24.
//

import SwiftUI

struct IntroView2: View {
    @State private var showNextScreen = false
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 160)
            
            // intro Text
            Text("Feeling ready for more? Let's dive deeper with another wellness question. These questions are designed to unlock your personal goals and strategies for mental well-being.")
                .font(.custom("SFProText-Bold", size: 30))
                .foregroundColor(Color("PurpleTitleColor"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
            
            Spacer()
            
            // next Button
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
                            gradient: Gradient(colors: [Color("PurpleButtonGradientColor1"), Color("PurpleButtonGradientColor2")]),
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
                    destination: WellnessQuestionViewPurple2(),
                    isActive: $showNextScreen,
                    label: { EmptyView() }
                )
            )
        }
        .padding(.horizontal)
        .background(
            Image("PurpleNewBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
        )
    }
}
