//
//  NewBG9.swift
//  peakmind-mvp
//
//  Created by ZA on 9/24/24.
//

import SwiftUI

struct P4_9_1: View {
    var closeAction: () -> Void
    @State private var selectedOption: String? = nil
    @State private var showExplanation: Bool = false
    @State private var explanationText: String = ""
    @State private var navigateToNextView = false // State for navigation
    
    // Quiz Question
    let question = "Anne is experiencing a stressful day and is taking some time for herself in the afternoon. She feels ungrounded and disconnected from reality. Which strategy should she use?"
    
    // Answer options and their explanations
    let options = [
        "5/4/3/2/1 Grounding" : "5/4/3/2/1 grounding helps bring you back to the present moment, which is essential when feeling disconnected from reality.",
        "Go for a run" : "While running can relieve stress, it doesn't necessarily help with feeling disconnected or ungrounded.",
        "Do affirmations" : "Affirmations focus on changing thoughts rather than addressing the feeling of being ungrounded or disconnected.",
        "Box Breathing" : " Box breathing is excellent for managing anxiety but is not as effective as grounding techniques when dealing with a sense of disconnection or ungroundedness."
    ]
    
    let correctAnswers: Set<String> = ["5/4/3/2/1 Grounding"]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("NewBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    Spacer().frame(height: 20) // Adjusted to make the quiz start higher
                    
                    // Quiz title
                    Text("Anxiety Management")
                        .font(.custom("SFProText-Bold", size: 28))
                        .foregroundColor(Color("QuestionHeaderColor"))
                        .padding(.bottom, 10)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    // Scrollable Quiz question and options
                    ScrollView {
                        VStack(spacing: 16) {
                            // Quiz question
                            Text(question)
                                .font(.custom("SFProText-Medium", size: 18))
                                .foregroundColor(Color("TextInsideBoxColor"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 10)
                                .padding(.bottom, 10)
                            
                            // Answer options
                            VStack(spacing: 12) {
                                ForEach(options.keys.sorted(), id: \.self) { option in
                                    AnswerBox5(
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
                                    .foregroundColor(Color("TextInsideBoxColor"))
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
                                .foregroundColor(Color("TextInsideBoxColor"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                        }
                    }
                    
                    // Submit button (if correct choices are selected)
                    if correctAnswers.contains(selectedOption ?? "") {
                        Button(action: {
                            navigateToNextView = true // Trigger navigation
                        }) {
                            Text("Continue")
                                .font(.custom("SFProText-Bold", size: 20))
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color("ButtonGradient1"), Color("ButtonGradient2")]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(15)
                                .shadow(color: Color.white.opacity(1), radius: 10, x: 0, y: 0)
                        }
                        .padding(.bottom, 20) // Adjusted padding at the bottom

                        // NavigationLink to WellnessQuestionView3
                        NavigationLink(destination: P4_WQ3(closeAction: closeAction), isActive: $navigateToNextView) {
                            EmptyView()
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
