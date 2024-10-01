//
//  PurpleNewBG3.swift
//  peakmind-mvp
//
//  Created by ZA on 8/26/24.
//

import SwiftUI

struct P3_1: View {
    var closeAction: (String) -> Void
    @State private var showNextScreen = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // background image
                Image("PurpleNewBG")
                    .resizable()
                    .clipped() // ensures the image fills the screen without distortion
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    Spacer()
                        .frame(height: 160)
                    
                    // Intro Text
                    Text("Let’s try our first coping mechanism! This is a breathing exercise to assist with calming different emotions.")
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
                            destination: P3_2(closeAction: closeAction),
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
