//
//  PinkNewBG1.swift
//  peakmind-mvp
//
//  Created by ZA on 9/23/24.
//

import SwiftUI

struct P3IntroView: View {
    @State private var showNextScreen = false
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 120)
            
            // Intro Text
            Text("Congratulations on reaching a new level in managing anxiety! This phase will help you understand how anxiety impacts you, both physically and emotionally, and guide you through strategies to identify triggers and build resilience. Get ready to take control!")
                .font(.custom("SFProText-Bold", size: 30))
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
            .background(
                NavigationLink(
                    destination: P3MentalHealthFeatureView(),
                    isActive: $showNextScreen,
                    label: { EmptyView() }
                )
            )
        }
        .padding(.horizontal)
        .background(
            Image("PinkNewBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
        )
    }
}

struct P3IntroView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            P3IntroView()
        }
    }
}
