//
//  PurpleNewBG4.2.swift
//  peakmind-mvp
//
//  Created by ZA on 8/27/24.
//

import SwiftUI

struct StressFeatureView: View {
    @State private var currentIndex: Int = 0
    @State private var isButtonDisabled: Bool = true
    @State private var showGlow: Bool = false
    @State private var navigateToWellnessQuestion = false // state to control navigation
    
    let bulletPoints = [
        "Life can be stressful! It's totally normal for our bodies and minds to react to challenges, and everyone experiences stress from time to time. Recognizing what triggers your stress is crucial; common triggers include work or school related pressures, financial strain, and big life changes.",
        "Feeling stressed? It can show up in surprising ways! Headaches, muscle tension, even anxiety can be signs your body and mind are saying slow down! Managing your stress involves mindfulness techniques, regular rest, and acknowledging the emotions you’re feeling.",
        "It's important to customize your stress management to fit your personal lifestyle, increasing its effectiveness! Understanding what triggers your stress and how to prevent those triggers is essential for emotional growth."
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // background image
                Image("PurpleNewBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    Spacer()
                        .frame(height: 80)
                    
                    // title above the box
                    Text("Stress Awareness")
                        .font(.custom("SFProText-Bold", size: 30))
                        .foregroundColor(Color("PurpleTitleColor"))
                        .padding(.bottom, 10)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    // larger Gradient box with bullet points
                    ZStack {
                        // gradient background box
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PurpleBoxGradientColor1"), Color("PurpleBoxGradientColor2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: geometry.size.height * 0.55) // increased height
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color("PurpleBorderColor"), lineWidth: 3.5)
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
                            navigateToWellnessQuestion = true // trigger navigation
                        }
                    }) {
                        Text(currentIndex < bulletPoints.count - 1 ? "Next" : "Continue")
                            .font(.custom("SFProText-Bold", size: 20))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PurpleButtonGradientColor1"), Color("PurpleButtonGradientColor2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: showGlow ? Color.white.opacity(1) : Color.clear, radius: 10, x: 0, y: 0) // show glow when required
                    }
                    .padding(.bottom, 50)
                    .disabled(isButtonDisabled) // disable button if typing is not complete
                    
                    // navigation link to the next screen
                    NavigationLink(destination: TriggerMappingView(), isActive: $navigateToWellnessQuestion) {
                        EmptyView()
                    }
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
