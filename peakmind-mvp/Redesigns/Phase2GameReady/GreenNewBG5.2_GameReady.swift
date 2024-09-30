//
//  GreenNewBG5.2.swift
//  peakmind-mvp
//
//  Created by ZA on 9/18/24.
//

import SwiftUI

struct P2_5_2: View {
    var closeAction: () -> Void
    @State private var selectedOptions: Set<String> = []
    @State private var navigateToGoalView = false // State to control navigation
    
    // Quiz Question
    let question = "Which of these have you experienced?"
    
    // Answer options
    let options = [
        "Pessimism",
        "Worry",
        "Catastrophizing",
        "Perfectionism",
        "Guilt and Shame",
        "Excessive Thinking"
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
                    
                    // Quiz title
                    Text("Stress Management")
                        .font(.custom("SFProText-Bold", size: 28))
                        .foregroundColor(Color("GreenTitleColor"))
                        .padding(.bottom, 10)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    // Quiz question
                    Text(question)
                        .font(.custom("SFProText-Medium", size: 18))
                        .foregroundColor(Color("GreenTextColor"))
                        .multilineTextAlignment(.center) // Center text alignment
                        .lineLimit(nil) // Allow multiple lines
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                    
                    // Answer options (scrollable if needed)
                    ScrollView {
                        VStack(spacing: 12) {
                            Spacer() // Adds space before the first option
                                .frame(height: 10)
                            ForEach(options, id: \.self) { option in
                                AnswerBox(text: option, isSelected: selectedOptions.contains(option)) {
                                    toggleSelection(for: option)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(height: geometry.size.height * 0.5) // Increased height from 0.4 to 0.5
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.top, 10) // Extra padding to add space between the title/question and the first option
                    
                    Spacer()
                    
                    // Submit button with conditional glow
                    Button(action: {
                        submitAnswers()
                        closeAction()
                    }) {
                        Text("Submit")
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
                            .shadow(color: selectedOptions.isEmpty ? Color.clear : Color.white.opacity(1), radius: 10, x: 0, y: 0) // Conditional glow
                    }
                    .padding(.bottom, 50)
                    .background(
                        NavigationLink(destination: P2GoalView(), isActive: $navigateToGoalView) {
                            EmptyView()
                        }
                    )
                }
                .padding(.horizontal)
            }
        }
    }
    
    // Toggle the selection of an option
    func toggleSelection(for option: String) {
        if selectedOptions.contains(option) {
            selectedOptions.remove(option)
        } else {
            selectedOptions.insert(option)
        }
    }
    
    // Action when submitting answers
    func submitAnswers() {
        // Navigate to the P2GoalView after submitting the answers
        if !selectedOptions.isEmpty {
            navigateToGoalView = true
        }
    }
}