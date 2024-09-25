//
//  GreenNewBG1.swift
//  peakmind-mvp
//
//  Created by ZA on 9/17/24.
//

import SwiftUI

struct P2IntroView: View {
    @State private var showNextScreen = false
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 120)
            
            // Intro Text
            Text("Buckle up for a quick and informative session on anxiety. We'll break down the different types and what it all means. By the end, you'll be an anxiety expert (well, almost!) Let's do this!")
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
                    destination: P2MentalHealthFeatureView(),
                    isActive: $showNextScreen,
                    label: { EmptyView() }
                )
            )
        }
        .padding(.horizontal)
        .background(
            Image("GreenNewBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
        )
    }
}

struct P2IntroView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            P2IntroView()
        }
    }
}


