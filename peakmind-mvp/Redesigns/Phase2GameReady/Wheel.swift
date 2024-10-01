//
//  Wheel.swift
//  peakmind-mvp
//
//  Created by James Wilson on 10/1/24.
//

import SwiftUI


struct P2_WR: View {
    var selectedStrategy: String
    var closeAction: (String) -> Void

    var body: some View {
        ZStack {
            // Background image
            Image("GreenNewBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer().frame(height: 40)

                // Title Text
                Text("Your Coping Strategy")
                    .font(.custom("SFProText-Bold", size: 30))
                    .foregroundColor(Color("GreenTitleColor"))
                    .padding(.bottom, 10)
                    .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)

                Spacer()

                // Result Text
                Text("You got: \(selectedStrategy)")
                    .font(.custom("SFProText-Medium", size: 24))
                    .foregroundColor(Color("GreenTextColor"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Spacer()

                // Show description based on selectedStrategy
                if selectedStrategy == "📦😮‍💨" {
                    Text("""
                        **Box Breathing**: This is a breathing exercise to assist with calming different emotions. Controlled breathing can cause positive changes in the body such as: lowered blood pressure and heart rate, and reduced levels of stress hormones in the blood. This exercise involves breathing in for four counts, holding for four counts, breathing out for four, and holding again to complete one cycle. Let’s practice by following the guide.
                        """)
                        .padding()
                        .foregroundColor(Color("GreenTextColor"))
                } else if selectedStrategy == "💪🧘" {
                    Text("""
                        **Progressive Muscle Relaxation**: Let’s learn progressive muscle relaxation, a powerful technique easing the physical tension driven by anxiety. Tense and relax each muscle group intensely one by one. Take a few seconds to flex, and a few seconds to release the tension. Let’s start with your right arm!
                        """)
                        .padding()
                        .foregroundColor(Color("GreenTextColor"))
                } else if selectedStrategy == "4️⃣/7️⃣/8️⃣" {
                    Text("""
                        **4/7/8 Breathing**: This technique will help clear your mind and wash away any built-up stress. Deep breaths are a powerful tool for relaxation. Breathe in quietly through your nose for a count of four. Hold your breath for a count of seven. Exhale completely through your mouth, making a whooshing sound, for a count of eight. Repeat this cycle for three to four breaths, or until you feel yourself calming down!
                        """)
                        .padding()
                        .foregroundColor(Color("GreenTextColor"))
                }

                Spacer()
                
                Button(action: {
                            closeAction("")
                        }) {
                            Text("Continue")
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
            }
        }
    }
}
