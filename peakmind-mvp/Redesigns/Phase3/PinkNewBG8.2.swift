//
//  PinkNewBG8.2.swift
//  peakmind-mvp
//
//  Created by ZA on 9/24/24.
//

import SwiftUI

struct P3MentalHealthFeatureView3: View {
    @State private var currentIndex: Int = 0
    @State private var isButtonDisabled: Bool = true
    @State private var showGlow: Bool = false
    @State private var navigateToWellnessQuestion = false // state to control navigation
    
    let bulletPoints = [
        "There are many different coping mechanisms to respond to physical and emotional symptoms. Engaging in activities you enjoy, like, swimming, dancing or playing sports, can be a fantastic way to burn off nervous energy and calm your body.",
        "Feeling overwhelmed emotionally? Don't bottle it up! Pair your physical coping mechanisms with activities that target your emotions. Journaling can help you process and release difficult feelings. Positive affirmations can boost your mood and self-confidence.",
        "When experiencing anxiety, we are affected emotionally, psychologically, physically, and spiritually. Each of these areas involve coping in a different style, while some overlap. Finding the right balance between coping mechanisms is essential.The key lies in finding a personalized blend of strategies to manage anxiety effectively.",
        "Emotional: Talking to trusted friends or family, watching calming shows or movies, or engaging in activities you find enjoyable can help soothe your emotions.",
        "Psychological: Immersing yourself in a captivating book, learning a new skill, or tackling a challenging puzzle can distract your mind and boost your sense of control.",
        "Spiritual: Meditation, prayer, spending time in nature, or any activity that connects you with a sense of purpose or something larger than yourself can bring inner peace and clarity.",
        "Physical: Regular exercise, getting enough sleep, and practicing deep breathing exercises can help manage your body's response to anxiety, promoting relaxation and reducing physical tension.",
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("PinkNewBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    Spacer()
                        .frame(height: 80)
                    
                    // Title above the box
                    Text("Managing Anxiety")
                        .font(.custom("SFProText-Bold", size: 30))
                        .foregroundColor(Color("PinkTitleColor"))
                        .padding(.bottom, 10)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    // Larger gradient box with bullet points
                    ZStack {
                        // Gradient background box
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PinkBoxGradientColor1"), Color("PinkBoxGradientColor2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: geometry.size.height * 0.55) // Increased height
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color("PinkBorderColor"), lineWidth: 3.5)
                            )
                        
                        // Scrollable list of bullet points with auto-scroll
                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(0..<currentIndex + 1, id: \.self) { index in
                                        FeatureBulletPoint(text: bulletPoints[index], onTypingComplete: {
                                            isButtonDisabled = false
                                            showGlow = true // Show glow when typing is complete
                                        })
                                        .id(index) // Attach the ID for scrolling
                                    }
                                    // Dummy item to force scroll to bottom
                                    Color.clear.frame(height: 1).id("bottom")
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                            }
                            .defaultScrollAnchor(.bottom)
                        }
                        .frame(height: geometry.size.height * 0.53) // Adjust height to stay within the gradient box
                        .clipShape(RoundedRectangle(cornerRadius: 15)) // Ensure the text is clipped within the box
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Next/continue button
                    Button(action: {
                        if currentIndex < bulletPoints.count - 1 {
                            isButtonDisabled = true
                            showGlow = false // Hide glow when text starts typing
                            currentIndex += 1
                        } else {
                            navigateToWellnessQuestion = true // Trigger navigation
                        }
                    }) {
                        Text(currentIndex < bulletPoints.count - 1 ? "Next" : "Continue")
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
                            .shadow(color: showGlow ? Color.white.opacity(1) : Color.clear, radius: 10, x: 0, y: 0) // Show glow when required
                    }
                    .padding(.bottom, 50)
                    .disabled(isButtonDisabled) // Disable button if typing is not complete
                    
                    // Navigation link to the next screen
                    NavigationLink(destination: P3BodyScan(), isActive: $navigateToWellnessQuestion) {
                        EmptyView()
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            // Start typing the first bullet point when the view appears
            currentIndex = 0
            isButtonDisabled = true
            showGlow = false
        }
    }
}

struct P3FeatureBulletPoint3: View {
    var text: String
    @State private var visibleText: String = ""
    @State private var charIndex: Int = 0
    var onTypingComplete: () -> Void
    
    var body: some View {
        // Feature text with typing animation
        Text(visibleText)
            .font(.custom("SFProText-Medium", size: 16))
            .foregroundColor(Color("PinkTextColor"))
            .multilineTextAlignment(.leading)
            .onAppear {
                typeText()
            }
    }
    
    private func typeText() {
        visibleText = ""
        charIndex = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            if charIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: charIndex)
                visibleText.append(text[index])
                charIndex += 1
            } else {
                timer.invalidate()
                onTypingComplete()
            }
        }
    }
}

struct P3MentalHealthFeatureView3_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            P3MentalHealthFeatureView3()
        }
    }
}
