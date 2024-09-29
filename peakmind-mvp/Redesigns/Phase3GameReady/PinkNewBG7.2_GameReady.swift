//
//  PinkNewBG7.2.swift
//  peakmind-mvp
//
//  Created by ZA on 9/23/24.
//

import SwiftUI

struct P3_7_2: View {
    var closeAction: () -> Void
    @State private var selectedOption: String? = nil
    @State private var showExplanation: Bool = false
    @State private var explanationText: String = ""
    
    // Quiz Question
    let question = "Johnny just dragged himself home after a brutal day at work. He's on edge, his muscles are tight, and the thought of facing tomorrow feels overwhelming. What can Johnny do to unwind and manage his anxiety?"
    
    // Answer options and their explanations
    let options = [
        "Drinking Alcohol": "This might seem tempting to take the edge off, but it can actually disrupt sleep and worsen anxiety in the long run.",
        "Progressive Muscle Relaxation": "This technique involves tensing and releasing different muscle groups, helping to release physical tension and promote relaxation.",
        "Ignore the Anxiety": "While avoiding the problem might feel good in the moment, it won't address the root cause of Johnny's anxiety.",
        "Box Breathing": "This simple breathing technique can quickly calm the nervous system and help Johnny feel more centered."
    ]
    
    let correctAnswers: Set<String> = ["Box Breathing", "Progressive Muscle Relaxation"]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // background image
                Image("PinkNewBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    Spacer().frame(height: 20) // Adjusted to make the quiz start higher
                    
                    // Quiz title
                    Text("Anxiety Management")
                        .font(.custom("SFProText-Bold", size: 28))
                        .foregroundColor(Color("PinkTitleColor"))
                        .padding(.bottom, 10)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    // Scrollable Quiz question and options
                    ScrollView {
                        VStack(spacing: 16) {
                            // Quiz question
                            Text(question)
                                .font(.custom("SFProText-Medium", size: 18))
                                .foregroundColor(Color("PinkTextColor"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 10)
                                .padding(.bottom, 10)
                            
                            // Answer options
                            VStack(spacing: 12) {
                                ForEach(options.keys.sorted(), id: \.self) { option in
                                    AnswerBox2(
                                        text: option,
                                        isSelected: selectedOption == option,
                                        action: {
                                            selectedOption = option
                                            showExplanation = true
                                            explanationText = options[option]!
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .frame(height: geometry.size.height * 0.45) // Increased height for scrollable window
                    
                    // Explanation Box
                    VStack(spacing: 12) {
                        if showExplanation {
                            Text(correctAnswers.contains(selectedOption ?? "") ? "Correct!" : "Try Again")
                                .font(.custom("SFProText-Bold", size: 20))
                                .foregroundColor(correctAnswers.contains(selectedOption ?? "") ? .green : .red)
                                .padding(.top, 10)
                            
                            // Explanation text with increased height allowance
                            ScrollView {
                                Text(explanationText)
                                    .font(.custom("SFProText-Medium", size: 16))
                                    .foregroundColor(Color("PinkTextColor"))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 20)
                            }
                            .frame(height: geometry.size.height * 0.2) // Height for explanation text
                            .transition(.opacity)
                        } else {
                            // Placeholder message before any selection is made
                            Text("Please select a choice from above")
                                .font(.custom("SFProText-Medium", size: 16))
                                .foregroundColor(Color("PinkTextColor"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                        }
                    }
                    
                    // Submit button (if correct choices are selected)
                    if correctAnswers.contains(selectedOption ?? "") {
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
                        .padding(.bottom, 20) // Adjusted padding at the bottom
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

