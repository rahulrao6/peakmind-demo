//
//  NewBG2.swift
//  peakmind-mvp
//
//  Created by ZA on 9/24/24.
//

import SwiftUI

struct P4EmotionalPageView: View {
    @State private var selectedOptions: Set<String> = []
    @State private var navigateToNextView = false // State to control navigation
    
    // Quiz Question
    let question = "Which of the following self-care activities do you currently engage in?"
    
    // Answer options
    let options = [
        "Spending time in nature",
        "Unplugging from devices",
        "Creating a tidy space",
        "Expressing gratitude regularly",
        "Practicing self-forgiveness",
        "Maintaining a balanced diet",
        "Prioritizing restful sleep",
        "Regular physical activity"
        
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("NewBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 10) {
                    Spacer()
                        .frame(height: 80)
                    
                    // Quiz title
                    Text("Resilience Checklist")
                        .font(.custom("SFProText-Bold", size: 28))
                        .foregroundColor(Color("QuestionHeaderColor"))
                        .padding(.bottom, 10)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    // Quiz question
                    Text(question)
                        .font(.custom("SFProText-Medium", size: 18))
                        .foregroundColor(Color("QuestionColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                    
                    // Answer options (scrollable if needed)
                    ScrollView {
                        VStack(spacing: 12) {
                            Spacer() // Adds space before the first option
                                .frame(height: 10)
                            ForEach(options, id: \.self) { option in
                                AnswerBox4(text: option, isSelected: selectedOptions.contains(option)) {
                                    toggleSelection(for: option)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(height: geometry.size.height * 0.5)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Submit button with conditional glow
                    Button(action: {
                        submitAnswers()
                    }) {
                        Text("Submit")
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
                            .shadow(color: selectedOptions.isEmpty ? Color.clear : Color.white.opacity(1), radius: 10, x: 0, y: 0)
                    }
                    .padding(.bottom, 50)
                    .background(
                        NavigationLink(destination: P4MentalHealthFeatureView(), isActive: $navigateToNextView) {
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
        // Navigate to the next view after submitting the answers
        if !selectedOptions.isEmpty {
            navigateToNextView = true
        }
    }
}

// Answer Box View (Single Option)
struct AnswerBox4: View {
    var text: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            HStack {
                Text(text)
                    .font(.custom("SFProText-Medium", size: 18))
                    .foregroundColor(Color("TextInsideBoxColor"))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color("TextInsideBoxColor"))
                        .padding(.trailing, 10)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(Color("TextInsideBoxColor"))
                        .padding(.trailing, 10)
                }
            }
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color("BoxGradient2"), Color("BoxGradient1")]), // Swapped gradient colors
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color("BoxStrokeColor"), lineWidth: 2)
            )
            .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
        }
    }
}

struct P4EmotionalPageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            P4EmotionalPageView()
        }
    }
}
