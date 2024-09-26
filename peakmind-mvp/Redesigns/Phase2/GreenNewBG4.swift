//
//  GreenNewBG4.swift
//  peakmind-mvp
//
//  Created by ZA on 9/17/24.
//

import SwiftUI

struct P2StressIntroView: View {
    @State private var showNextScreen = false
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 120)
            
            // Intro Text
            Text("Feeling anxious is normal, but certain thought patterns can fuel it. In this module, we'll explore these patterns and learn how to manage them in anxiety-provoking situations.")
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
                    destination: P2StressFeatureView(),
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

struct P2StressIntroView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            P2StressIntroView()
        }
    }
}
