//
//  NewBG1.swift
//  peakmind-mvp
//
//  Created by ZA on 9/24/24.
//

import SwiftUI

struct P4_1_1: View {
    var closeAction: (String) -> Void
    @State private var showNextScreen = false
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 120)
            
            // Intro Text
            Text("Welcome to the next phase of your journey managing anxiety. This phase will teach you about building resilience and establishing a routine in your life. You’ll go through different activities to better your current habits and routines.")
                .font(.custom("SFProText-Bold", size: 30))
                .foregroundColor(Color("QuestionHeaderColor"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
            
            Spacer()
            
            // Next Button
            Button(action: {
                showNextScreen = true
                closeAction("")
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
            .background(
                NavigationLink(
                    destination: P4EmotionalPageView(), // Replace with the actual destination view
                    isActive: $showNextScreen,
                    label: { EmptyView() }
                )
            )
        }
        .padding(.horizontal)
        .background(
            Image("NewBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
        )
    }
}
