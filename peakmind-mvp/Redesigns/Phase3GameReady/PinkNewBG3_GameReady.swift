//
//  PinkNewBG3.swift
//  peakmind-mvp
//
//  Created by ZA on 9/23/24.
//

import SwiftUI

struct P3_3_1: View {
    var closeAction: () -> Void
    @State private var currentIndex: Int = 0
    @State private var isTextCompleted: Bool = false
    @State private var currentLitSection: Int = 0
    @State private var isScanning = false
    @State private var bodySections = ["Head", "Shoulders", "Chest", "Abdomen", "Legs", "Feet"]
    @State private var navigateToCandEView = false
    
    let introText = [
        "It’s time for us to do a mindfulness activity. Ready to unwind and recharge anytime, anywhere?",
        "Unwind and Recharge with a Body Scan!",
        "Imagine yourself getting comfortably settled. We'll embark on a gentle journey through your body, bringing awareness to any areas holding tension.",
        "As we focus on each part, picture that tension dissolving, melting away like warm butter on a sunny day.",
        "By the end, you'll feel revitalized and ready to conquer the rest of your day."
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("PinkNewBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    Spacer().frame(height: 50)
                    
                    // Intro Text Animation
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PinkBoxGradientColor1"), Color("PinkBoxGradientColor2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: geometry.size.height * 0.25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color("PinkBorderColor"), lineWidth: 2.5)
                            )
                        
                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(0..<currentIndex, id: \.self) { index in
                                        FeatureBulletPoint3(text: introText[index], onTypingComplete: {
                                            if index == introText.count - 1 {
                                                isTextCompleted = true
                                            }
                                        })
                                        .id(index)
                                    }
                                }
                                .padding(20)
                            }
                            .frame(height: geometry.size.height * 0.25)
                            .onChange(of: currentIndex) { _ in
                                withAnimation {
                                    proxy.scrollTo(currentIndex - 1, anchor: .bottom)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .onAppear {
                        startTyping()
                    }
                    
                    Spacer()
                    
                    // Body Scan visualization (shows after text animation completes)
                    if isTextCompleted {
                        VStack(spacing: 16) {
                            ForEach(0..<bodySections.count, id: \.self) { index in
                                Text(bodySections[index])
                                    .font(.custom("SFProText-Bold", size: 20))
                                    .foregroundColor(currentLitSection == index ? Color("PinkTextColor").opacity(1) : Color("PinkTextColor").opacity(0.3))
                                    .animation(.easeInOut(duration: 2), value: currentLitSection) // Animate lighting
                            }
                        }
                        .onAppear {
                            startBodyScan()
                        }
                    }
                    
                    // Continue button to navigate after the body scan completes
                    if currentLitSection == bodySections.count - 1 {
                        Button(action: {
                            closeAction()
                        }) {
                            Text("Continue")
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
                        .padding(.top, 20)
                        .background(
                            NavigationLink(
                                destination: P3CandEView(), // Navigate to P3CandEView
                                isActive: $navigateToCandEView,
                                label: { EmptyView() }
                            )
                        )
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
    }
    
    // Function to start typing the intro text with a delay for each bullet point
    func startTyping() {
        for index in 0..<introText.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 3) {
                currentIndex += 1
            }
        }
    }
    
    // Function to start the body scan
    private func startBodyScan() {
        isScanning = true
        let sectionDuration = 20.0 / Double(bodySections.count)
        for index in 0..<bodySections.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + (sectionDuration * Double(index))) {
                if isScanning {
                    currentLitSection = index
                }
            }
        }
    }
}
