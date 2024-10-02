//
//  LightPurpleNewBG8.swift
//  peakmind-mvp
//
//  Created by ZA on 10/1/24.
//

import SwiftUI

struct P5_8_1: View {
    var closeAction: (String) -> Void
    @State private var selectedOption: String? = nil
    @State private var showExplanation: Bool = false
    @State private var explanationText: String = ""
    @State private var navigateToNextView = false // State for navigation
    
    // Quiz Question
    let question = "Which of the following is NOT a positive action to do when reaching out to your support system?"
    
    // Answer options and their explanations
    let options = [
        "Set boundaries" : "It’s important to establish personal boundaries in any relationship, including with your support system, to ensure that you feel comfortable and respected.",
        "Be clear about what you need" : "Communicating your needs clearly helps your support system understand how to best support you, making the interaction more effective.",
        "Ignore their responses" : "Great Job! Let them speak – Allowing your support system to express their thoughts and feelings fosters open communication, which is essential for a healthy relationship.",
        "Let them ask questions" : "Allowing your support system to express their thoughts and feelings fosters open communication, which is essential for a healthy relationship."
    ]
    
    let correctAnswers: Set<String> = ["Ignore their responses"]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("LightPurpleNewBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    Spacer().frame(height: 20) // Adjusted to make the quiz start higher
                    
                    // Quiz title
                    Text("Support System")
                        .font(.custom("SFProText-Bold", size: 28))
                        .foregroundColor(Color("LightPurpleTitleColor"))
                        .padding(.bottom, 10)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    // Scrollable Quiz question and options
                    ScrollView {
                        VStack(spacing: 16) {
                            // Quiz question
                            Text(question)
                                .font(.custom("SFProText-Medium", size: 18))
                                .foregroundColor(Color("LightPurpleTextColor"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 10)
                                .padding(.bottom, 10)
                            
                            // Answer options
                            VStack(spacing: 12) {
                                ForEach(options.keys.sorted(), id: \.self) { option in
                                    AnswerBoxP5(
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
                                    .foregroundColor(Color("LightPurpleTextColor"))
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
                                .foregroundColor(Color("LightPurpleTextColor"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                        }
                    }
                    
                    // Submit button (if correct choices are selected)
                    if correctAnswers.contains(selectedOption ?? "") {
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
                                        gradient: Gradient(colors: [Color("LightPurpleButtonGradientColor1"), Color("LightPurpleButtonGradientColor2")]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(15)
                                .shadow(color: Color.white.opacity(1), radius: 10, x: 0, y: 0)
                        }
                        .padding(.bottom, 20) // Adjusted padding at the bottom

                        // NavigationLink to WellnessQuestionView3
                        NavigationLink(destination: P5CommunityView2(), isActive: $navigateToNextView) {
                            EmptyView()
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
