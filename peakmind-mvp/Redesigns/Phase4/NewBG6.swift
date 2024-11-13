//
//  NewBG6.swift
//  peakmind-mvp
//
//  Created by ZA on 9/24/24.
//

import SwiftUI

struct P4Wheel: View {
    var closeAction: (String) -> Void
    @State private var selectedStrategy: String? = nil
    @State private var isSpinning = false
    @State private var spinAngle: Double = 0
    @State private var strategies = ["📦😮‍💨", "💪🧘", "4️⃣/7️⃣/8️⃣"] // Emojis for Box Breathing, Progressive Muscle Relaxation, and 4/7/8 Breathing
    @State private var showResult = false
    @State private var showContinueButton = false
    @State private var glowingSegmentIndex: Int? = nil // Track which segment should glow

    var body: some View {
     Text("how did oyu get here")
        
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

// Page 2: Shows the selected coping strategy result
struct P4WheelResultView: View {
    var closeAction: (String) -> Void
    var selectedStrategy: String

    var body: some View {
        ZStack {
            // Background image
            Image("NewBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer().frame(height: 40)

                // Title Text
                Text("Your Coping Strategy")
                    .font(.custom("SFProText-Bold", size: 30))
                    .foregroundColor(Color("QuestionHeaderColor"))
                    .padding(.bottom, 10)
                    .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)

                Spacer()

                // Result Text
                Text("You got: \(selectedStrategy)")
                    .font(.custom("SFProText-Medium", size: 24))
                    .foregroundColor(Color("TextInsideBoxColor"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Spacer()

                // Show description based on selectedStrategy
                if selectedStrategy == "📦😮‍💨" {
                    Text("""
                        **Box Breathing**: This is a breathing exercise to assist with calming different emotions. Controlled breathing can cause positive changes in the body such as: lowered blood pressure and heart rate, and reduced levels of stress hormones in the blood. This exercise involves breathing in for four counts, holding for four counts, breathing out for four, and holding again to complete one cycle. Let’s practice by following the guide.
                        """)
                        .padding()
                        .foregroundColor(Color("TextInsideBoxColor"))
                } else if selectedStrategy == "💪🧘" {
                    Text("""
                        **Progressive Muscle Relaxation**: Let’s learn progressive muscle relaxation, a powerful technique easing the physical tension driven by anxiety. Tense and relax each muscle group intensely one by one. Take a few seconds to flex, and a few seconds to release the tension. Let’s start with your right arm!
                        """)
                        .padding()
                        .foregroundColor(Color("TextInsideBoxColor"))
                } else if selectedStrategy == "4️⃣/7️⃣/8️⃣" {
                    Text("""
                        **4/7/8 Breathing**: This technique will help clear your mind and wash away any built-up stress. Deep breaths are a powerful tool for relaxation. Breathe in quietly through your nose for a count of four. Hold your breath for a count of seven. Exhale completely through your mouth, making a whooshing sound, for a count of eight. Repeat this cycle for three to four breaths, or until you feel yourself calming down!
                        """)
                        .padding()
                        .foregroundColor(Color("TextInsideBoxColor"))
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

// Wheel Segment Shape
struct P4WheelSegment: Shape {
    let geometry: GeometryProxy
    let index: Int
    let totalSegments: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = geometry.size.width * 0.35
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let startAngle = Angle(degrees: Double(index) * 360.0 / Double(totalSegments))
        let endAngle = Angle(degrees: Double(index + 1) * 360.0 / Double(totalSegments))

        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()

        return path
    }
}
