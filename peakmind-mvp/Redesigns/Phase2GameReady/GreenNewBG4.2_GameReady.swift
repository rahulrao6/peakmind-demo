//
//  GreenNewBG4.2.swift
//  peakmind-mvp
//
//  Created by ZA on 9/17/24.
//

import SwiftUI

struct P2_4_2: View {
    var closeAction: (String) -> Void
    @State private var currentIndex: Int = 0
    @State private var isButtonDisabled: Bool = true
    @State private var showGlow: Bool = false
    @State private var navigateToWellnessQuestion = false // state to control navigation
    
    let bulletPoints = [
        "Not all thoughts are created equal! Some thought patterns are like fire starters, quickly igniting anxious feelings. Let's explore some of the most common culprits. First up, we have pessimism. This is the tendency to see dark clouds forming even on the brightest days, always expecting the worst to happen.",
        "Next on our list is catastrophizing. This is when our minds take a tiny misstep and blow it up into a full-blown disaster movie! We start with a small problem, like maybe forgetting a line in a presentation, and suddenly we're convinced it's the end of the world. And let's not forget the guilt and shame twins! These two can really fuel the anxiety fire. They whisper in our ears that we've messed up big time and everyone must think terribly of us.",
        "Worry is like a bad habit - the more you do it, the harder it is to break. It's that constant mental chatter about all the things that could go wrong, even if they're highly unlikely. Similar to worry, obsessive thinking gets stuck on repeat. It's like a mental record player playing the same negative thought over and over, fueling anxiety",
        "Perfectionism involves setting unrealistic expectations and believing that mistakes are unacceptable. Recognizing these various anxiety triggers within yourself is crucial for understanding and managing your experiences."
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // background image
                Image("GreenNewBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    Spacer()
                        .frame(height: 80)
                    
                    // title above the box
                    Text("Stress Awareness")
                        .font(.custom("SFProText-Bold", size: 30))
                        .foregroundColor(Color("GreenTitleColor"))
                        .padding(.bottom, 10)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    // larger Gradient box with bullet points
                    ZStack {
                        // gradient background box
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("GreenBoxGradientColor1"), Color("GreenBoxGradientColor2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: geometry.size.height * 0.55) // increased height
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color("GreenBorderColor"), lineWidth: 3.5)
                            )
                        
                        // scrollable list of bullet points with auto-scroll
                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(0..<currentIndex + 1, id: \.self) { index in
                                        FeatureBulletPoint(text: bulletPoints[index], onTypingComplete: {
                                            isButtonDisabled = false
                                            showGlow = true // show glow when typing is complete
                                        })
                                        .id(index) // attach the ID for scrolling
                                    }
                                    // dummy item to force scroll to bottom
                                    Color.clear.frame(height: 1).id("bottom")
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                            }
                            .onChange(of: currentIndex) { _ in
                                withAnimation {
                                    proxy.scrollTo(currentIndex, anchor: .bottom)
                                }
                            }
                        }
                        .frame(height: geometry.size.height * 0.53) // adjust height to stay within the gradient box
                        .clipShape(RoundedRectangle(cornerRadius: 15)) // ensure the text is clipped within the box
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Next/Continue Button
                    Button(action: {
                        if currentIndex < bulletPoints.count - 1 {
                            isButtonDisabled = true
                            showGlow = false // hide glow when text starts typing
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
                                    gradient: Gradient(colors: [Color("GreenButtonGradientColor1"), Color("GreenButtonGradientColor2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: showGlow ? Color.white.opacity(1) : Color.clear, radius: 10, x: 0, y: 0) // show glow when required
                    }
                    .padding(.bottom, 50)
                    .disabled(isButtonDisabled) // disable button if typing is not complete
                    
                    
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            // start typing the first bullet point when the view appears
            currentIndex = 0
            isButtonDisabled = true
            showGlow = false
        }
    }
}
