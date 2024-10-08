//
//  Phase1Summary.swift
//  peakmind-mvp
//
//  Created by ZA on 10/4/24.
//

import SwiftUI

struct P1S: View {
    var closeAction: (String) -> Void
    @State private var currentIndex: Int = 0
    @State private var isButtonDisabled: Bool = true
    @State private var showGlow: Bool = false
    @State private var navigateToWellnessQuestion = false // state to control navigation
    
    let bulletPoints = [
        "In this phase, you learned so much about mental health and how stress impacts your daily life. You explored various coping strategies, like breathing exercises and trigger mapping, to manage stress more effectively. Remember to consistently practice these techniques to stay calm and grounded when you are experiencing stress."
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("PurpleNewBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    Spacer()
                        .frame(height: 80)
                    
                    // Title above the box
                    Text("Summary")
                        .font(.custom("SFProText-Bold", size: 30))
                        .foregroundColor(Color("PurpleTitleColor"))
                        .padding(.bottom, 10)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    // Larger Gradient box with bullet points
                    ZStack {
                        // Gradient background box
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PurpleBoxGradientColor1"), Color("PurpleBoxGradientColor2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: geometry.size.height * 0.55) // Increased height
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color("PurpleBorderColor"), lineWidth: 3.5)
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
                            .onChange(of: currentIndex) { _ in
                                withAnimation {
                                    proxy.scrollTo(currentIndex, anchor: .bottom)
                                }
                            }
                        }
                        .frame(height: geometry.size.height * 0.53) // Adjust height to stay within the gradient box
                        .clipShape(RoundedRectangle(cornerRadius: 15)) // Ensure the text is clipped within the box
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Next/Continue Button
                    Button(action: {
                        if currentIndex < bulletPoints.count - 1 {
                            isButtonDisabled = true
                            showGlow = false // Hide glow when text starts typing
                            currentIndex += 1
                        } else {
                            closeAction("")
                        }
                    }) {
                        Text(currentIndex < bulletPoints.count - 1 ? "Next" : "Done")
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
                            .shadow(color: showGlow ? Color.white.opacity(1) : Color.clear, radius: 10, x: 0, y: 0) // Show glow when required
                    }
                    .padding(.bottom, 50)
                    .disabled(isButtonDisabled) // Disable button if typing is not complete
                    
                    // Navigation link to the next screen
                    NavigationLink(destination: WellnessQuestionViewPurple(), isActive: $navigateToWellnessQuestion) {
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

// Preview for P1Summary
struct P1Summary_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            P1Summary()
        }
    }
}

