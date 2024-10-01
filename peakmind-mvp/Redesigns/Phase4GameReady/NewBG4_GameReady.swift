//
//  NewBG4.swift
//  peakmind-mvp
//
//  Created by ZA on 9/24/24.
//

import SwiftUI

struct P4_4_1: View {
    var closeAction: (String) -> Void
    @State private var showNextScreen = false
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 120)
            
            // Intro Text
            Text("Let’s learn about the 5/4/3/2/1 grounding technique. You’ll point out 5 things you can see, 4 things you can touch, 3 things you can hear, 2 things you can smell, and 1 thing you can taste. This technique is used for grounding yourself during panic, crisis, or high anxiety level situations.")
                .font(.custom("SFProText-Bold", size: 27))
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
            .background(
                NavigationLink(
                    destination: P4_4_2(closeAction: closeAction), // Replace with the actual destination view
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
