//
//  GreenNewBG8.swift
//  peakmind-mvp
//
//  Created by ZA on 9/18/24.
//

import SwiftUI

struct P2_8_1: View {
    var closeAction: (String) -> Void
    @State private var selectedStrategy: String? = nil
    @State private var isSpinning = false
    @State private var spinAngle: Double = 0
    @State private var strategies = ["📦😮‍💨", "💪🧘", "4️⃣/7️⃣/8️⃣"] // Emojis for Box Breathing, Progressive Muscle Relaxation, and 4/7/8 Breathing
    @State private var showResult = false
    @State private var showContinueButton = false
    @State private var glowingSegmentIndex: Int? = nil // Track which segment should glow

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("GreenNewBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 16) {
                    Spacer().frame(height: 40)

                    // Title Text
                    Text("Mindfulness Strategies")
                        .font(.custom("SFProText-Bold", size: 30))
                        .foregroundColor(Color("GreenTitleColor"))
                        .padding(.bottom, 10)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)

                    // "Spin the Wheel" Text
                    Text("One of the best ways to manage anxiety is through mindfulness. Spin the wheel to participate in an exercise you’ve learned.")
                        .font(.custom("SFProText-Bold", size: 22))
                        .foregroundColor(Color("GreenTextColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30) // Center the text with horizontal padding
                        .padding(.bottom, 20)

                    // Wheel for coping strategies
                    ZStack {
                        // Wheel sections (like a color wheel)
                        ForEach(0..<strategies.count) { index in
                            WheelSegment(geometry: geometry, index: index, totalSegments: strategies.count)
                                .fill(index % 2 == 0 ? Color("GreenTextColor") : Color("GreenTitleColor"))
                                .frame(width: geometry.size.width * 0.7, height: geometry.size.width * 0.7)
                                .rotationEffect(Angle(degrees: Double(index) * 360.0 / Double(strategies.count)))
                                .shadow(color: glowingSegmentIndex == index ? Color.white.opacity(1) : Color.clear, radius: 15, x: 0, y: 0) // Glow effect for the selected segment
                        }

                        // Emojis for each strategy within its segment
                        ForEach(0..<strategies.count) { index in
                            VStack {
                                Text(strategies[index])
                                    .font(.system(size: 20)) // Emoji size
                                    .foregroundColor(.black)
                                    .rotationEffect(Angle(degrees: -Double(index) * 360.0 / Double(strategies.count))) // Correct the text rotation
                                    .frame(width: geometry.size.width * 0.25) // Ensure emoji fits within the segment
                            }
                            .offset(x: index == 0 ? 39 : (index == 1 ? 33 : 37), // Adjust horizontal offset for each emoji
                                    y: index == 0 ? -geometry.size.width * 0.16 : (index == 1 ? -geometry.size.width * 0.15 : -geometry.size.width * 0.16)) // Adjust vertical offset for each emoji
                            .rotationEffect(Angle(degrees: Double(index) * 360.0 / Double(strategies.count))) // Rotate the emoji per segment
                        }

                        // Center pin for the wheel
                        Circle()
                            .fill(Color("GreenButtonGradientColor1"))
                            .frame(width: 30, height: 30)
                    }
                    .rotationEffect(Angle(degrees: spinAngle)) // Spin the wheel

                    Spacer()

                    // Spin button
                    if !isSpinning {
                        Button(action: {
                            spinWheel()
                        }) {
                            Text("Spin")
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
                        .padding(.bottom, 20)
                    }

                    // Continue button (shown after spinning)
                    if showContinueButton {
                        NavigationLink(destination: P2_WR(selectedStrategy: selectedStrategy ?? "")) {
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
                    }

                    Spacer()
                }
            }
        }
    }

    // Function to spin the wheel
    private func spinWheel() {
        let randomDegree = Double.random(in: 720...1440) // Random number for spin (at least 2 full rotations)
        let totalSegments = strategies.count
        let segmentAngle = 360.0 / Double(totalSegments) // Angle per segment

        // Calculate the final angle after spin
        withAnimation(.easeOut(duration: 3)) {
            spinAngle += randomDegree
        }

        // After the wheel stops, calculate the chosen index
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            // Adjust the spinAngle to ensure it's positive and within the 0-360 range
            let finalAngle = (spinAngle.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)

            // Determine which segment it landed on
            let chosenIndex = Int(finalAngle / segmentAngle) % totalSegments

            selectedStrategy = strategies[chosenIndex]
            glowingSegmentIndex = chosenIndex // Glow the correct segment
            showContinueButton = true // Show Continue button after spin is done
            isSpinning = false
        }

        isSpinning = true
        glowingSegmentIndex = nil // Reset glow before spinning
    }
}

struct P2_WR: View {
    var selectedStrategy: String

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
            }
        }
    }
}
