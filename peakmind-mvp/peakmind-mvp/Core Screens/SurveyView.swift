//
//  SurveyView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 2/26/24.
//

import SwiftUI

struct SurveyView: View {
    @State var questions = [
        Question(id: UUID(), question: "Rank your anxiety.", selectedNumber: 1, descriptors: ["Low", "Mild", "Moderate", "High", "Severe"]),
        Question(id: UUID(), question: "Rank your current mental state.", selectedNumber: 1, descriptors: ["Calm", "Neutral", "Anxious", "Stressed", "Overwhelmed"]),
        Question(id: UUID(), question: "Rank your self-care abilities.", selectedNumber: 1, descriptors: ["Neglected", "Minimal", "Average", "Good", "Excellent"]),
        Question(id: UUID(), question: "Rank your support systems.", selectedNumber: 1, descriptors: ["Weak", "Limited", "Moderate", "Strong", "Very Strong"]),
        Question(id: UUID(), question: "Rank your stress.", selectedNumber: 1, descriptors: ["Low", "Mild", "Moderate", "High", "Severe"]),
        Question(id: UUID(), question: "Rank your eating habits.", selectedNumber: 1, descriptors: ["Poor", "Below Average", "Average", "Above Average", "Excellent"])
    ]
    
    @Environment(\.dismiss) private var dismiss
    @State private var progress: CGFloat = 0
    @State private var currentIndex: Int = 0
    
    var body: some View {
        VStack(spacing: 15) {
            ZStack {
                // Rectangle behind the "Mental Health Quiz" text and progress bar
                Rectangle()
                    .fill(Color(hex: "071a4b")!)
                    .frame(maxWidth: .infinity) // Ensures it stretches the full width
                    .frame(height: 200) // Adjust height as necessary for the header
                    .ignoresSafeArea(edges: .top) // Make sure it extends to the top
                    .padding(.horizontal, -50)
                
                VStack(spacing: 10) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.custom("SFProText-Bold", size: 20))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 15)

                    Text("Mental Health Quiz")
                        .font(.custom("SFProText-Heavy", size: 28))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 15)
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    GeometryReader { geometry in
                        let size = geometry.size
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.4)) // Lighter color for the empty progress bar

                            Rectangle()
                                .fill(Color(hex: "b0e8ff")!) // Progress bar color
                                .frame(width: progress * size.width, alignment: .leading)
                        }
                        .clipShape(Capsule())
                    }
                    .frame(height: 20)
                    .padding(.horizontal, 15)
                    .padding(.top, 5)
                }
            }
            .frame(maxWidth: .infinity)
            

            
            // Questions
            GeometryReader { _ in
                if currentIndex < questions.count {
                    QuestionView(question: $questions[currentIndex])
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 15)
            
            // Back Button - only show if currentIndex > 0
            // Back and Next buttons side by side
            HStack {
                if currentIndex > 0 {
                    Button(action: {
                        withAnimation(.easeInOut) {
                            currentIndex -= 1
                            progress = CGFloat(currentIndex) / CGFloat(questions.count - 1)
                        }
                    }) {
                        Text("Back")
                            .font(.custom("SFProText-Bold", size: 18))
                            .foregroundColor(.white) // Transparent text color
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.clear) // Transparent background
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 5)
                }

                // Next or Finish Button
                CustomButtonView(title: currentIndex == (questions.count - 1) ? "Finish" : "Next Question") {
                    if currentIndex == (questions.count - 1) {
                        print(questions)
                        // Custom logic for finishing survey
                    } else {
                        withAnimation(.easeInOut) {
                            currentIndex += 1
                            progress = CGFloat(currentIndex) / CGFloat(questions.count - 1)
                        }
                    }
                }
            }
            .padding(.bottom, 5)

        }
        .padding(15)
        .background {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "112864")!, Color(hex: "23429a")!]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()
        }
        .edgesIgnoringSafeArea(.top) // Extend to the top

    }


    
    @ViewBuilder
    func QuestionView(question: Binding<Question>) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Question \(currentIndex + 1)/\(questions.count)")
                .font(.custom("SFProText-Bold", size: 18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            
            Text(question.wrappedValue.question)
                .font(.custom("SFProText-Heavy", size: 40))
                .foregroundColor(.white)
            
            let sliderBinding = Binding<Double>(
                get: {
                    Double(question.wrappedValue.selectedNumber)
                },
                set: {
                    question.wrappedValue.selectedNumber = Int($0)
                }
            )
            
            VStack {
                CustomSlider(value: sliderBinding, range: 1...5)
                    .frame(height: 60)
                
                // Display the descriptor based on the current selected number
                Text(question.wrappedValue.descriptors[question.wrappedValue.selectedNumber - 1])
                    .font(.custom("SFProText-Bold", size: 30))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, -20)
            }
            
            Spacer()
        }
        .padding(15)
    }

    struct CustomSlider: View {
        @Binding var value: Double
        var range: ClosedRange<Double>
        
        var body: some View {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 15)
                        .cornerRadius(7.5)
                    
                    Rectangle()
                        .fill(Color(hex: "b0e8ff")!)
                        .frame(width: CGFloat(value - range.lowerBound) / CGFloat(range.upperBound - range.lowerBound) * geometry.size.width, height: 15)
                        .cornerRadius(7.5)
                    
                    Circle()
                        .frame(width: 30, height: 30)
                        .offset(x: CGFloat(value - range.lowerBound) / CGFloat(range.upperBound - range.lowerBound) * geometry.size.width - 15)
                        .foregroundColor(Color(hex: "b0e8ff")!)
                }
                .gesture(DragGesture(minimumDistance: 0).onChanged { drag in
                    let sliderWidth = geometry.size.width
                    let newValue = min(max(Double(drag.location.x / sliderWidth) * (range.upperBound - range.lowerBound) + range.lowerBound, range.lowerBound), range.upperBound)
                    value = newValue
                })
            }
        }
    }

    
    // Custom Button View
    struct CustomButtonView: View {
        let title: String
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.custom("SFProText-Bold", size: 18))
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "b0e8ff")!)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 5)
        }
    }
    
}
struct SurveyView_Previews: PreviewProvider {
    static var previews: some View {
        // Example questions
        let exampleQuestions = [
            Question(id: UUID(), question: "I feel energized most of the day.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"]),
            Question(id: UUID(), question: "I have a lot of stamina.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"]),
            Question(id: UUID(), question: "I find it easy to get out of bed in the morning.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"]),
        ]
        
        // Initializing SurveyView with example questions
        SurveyView(questions: exampleQuestions)
    }
}
