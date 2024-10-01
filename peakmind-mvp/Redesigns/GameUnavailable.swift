//
//  GameUnavailable.swift
//  peakmind-mvp
//
//  Created by James Wilson on 9/30/24.
//

import SwiftUI

struct GameUnavailable: View {
    var closeAction: (String) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 120)
            
            // Coming Soon Text
            Text("This minigame is coming soon!")
                .font(.custom("SFProText-Bold", size: 30))
                .foregroundColor(Color("QuestionHeaderColor"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
            
            Spacer()
            
            // Next Button
            Button(action: {
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
        }
        .padding(.horizontal)
        .background(
            Image("NewBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
        )
    }
}
