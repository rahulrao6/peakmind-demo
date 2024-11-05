//
//  PinkNewBG5.2.swift
//  peakmind-mvp
//
//  Created by ZA on 9/23/24.
//

import SwiftUI

struct P3_5_2: View {
    var closeAction: (String) -> Void
    @State private var currentIndex: Int = 0
    @State private var isButtonDisabled: Bool = true
    @State private var showGlow: Bool = false
    @State private var navigateToWellnessQuestion = false // state to control navigation
    
    let bulletPoints = [
        "Anxiety can be a real mood wrecker! It can trigger feelings of dread, panic, and constant worry, shaking your emotional foundation. It’s important to connect what triggers and external factors cause emotional flares in anxiety. If we know what is likely to cause emotional flares, we can directly respond to the triggers.",
        "Feeling like self doubt sometimes? It's normal with anxiety. Remember, anxiety and self-doubt are just visitors, not your permanent residents. Don't let them define you! By taking steps like walks in nature, digital detoxes, and tackling brain puzzles, you'll create more opportunities for mindfulness and emotional well-being. These activities will not only reduce anxiety but also help you rediscover the awesome person you truly are!",
        "Anxiety's emotional grip can be personal! While stress hormones linger for 20 minutes to 2 hours on average, how they affect you can be unique. The good news? Acting fast makes a difference! By choosing the right coping mechanisms and implementing them quickly, you can significantly shorten that window of emotional discomfort."
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
                    Text("Emotional Anxiety")
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
                            closeAction("")
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
                    NavigationLink(destination: WellnessQuestionViewPink2(), isActive: $navigateToWellnessQuestion) {
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
