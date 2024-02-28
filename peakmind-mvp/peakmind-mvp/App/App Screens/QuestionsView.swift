//
//  QuestionsView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 2/26/24.
//

import SwiftUI

struct QuestionsView: View {
    @State var questions: [Question]
    var onFinish: ()->()
    
    @Environment(\.dismiss) private var dismiss
    @State private var progress: CGFloat = 0
    @State private var currentIndex: Int = 0
    @State private var showPersonalizedPlan: Bool = false
    
    var body: some View {
        VStack(spacing: 15) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Mental Health Quiz")
                .font(.title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white)
            
            GeometryReader { geometry in
                let size = geometry.size
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.black.opacity(0.2))
                    
                    Rectangle()
                        .fill(Color("Progress"))
                        .frame(width: progress * size.width, alignment: .leading)
                }
                .clipShape(Capsule())
            }
            .frame(height: 20)
            .padding(.top, 5)
            
            // Questions
            GeometryReader { _ in
                if currentIndex < questions.count {
                    QuestionView(question: $questions[currentIndex])
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 15)
            
            // Back Button - only show if currentIndex > 0
            if currentIndex > 0 {
                CustomButton(title: "Back") {
                    withAnimation(.easeInOut) {
                        currentIndex -= 1
                        progress = CGFloat(currentIndex) / CGFloat(questions.count - 1)
                    }
                }
                .padding(.bottom, 5)
            }
            
            // Next or Finish Button
            // Finish button needs to save + send info to Firebase when clicked
            CustomButton(title: currentIndex == (questions.count - 1) ? "Finish" : "Next Question") {
                if currentIndex == (questions.count - 1) {
                    showPersonalizedPlan = true
                } else {
                    withAnimation(.easeInOut) {
                        currentIndex += 1
                        progress = CGFloat(currentIndex) / CGFloat(questions.count - 1)
                    }
                }
            }
        }
        .padding(15)
        .background {
            Color("Pink").ignoresSafeArea()
        }
        .sheet(isPresented: $showPersonalizedPlan) {
            PersonalizedPlanView()
        }
    }
    
    @ViewBuilder
    func QuestionView(question: Binding<Question>) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Question \(currentIndex + 1)/\(questions.count)")
                .font(.callout)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            
            Text(question.wrappedValue.question)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            let sliderBinding = Binding<Double>(
                get: {
                    Double(question.wrappedValue.selectedNumber)
                },
                set: {
                    question.wrappedValue.selectedNumber = Int($0)
                }
            )
            
            Slider(value: sliderBinding, in: 1...5, step: 1)
                .accentColor(Color("Progress"))
            
            Text("Selected: \(question.wrappedValue.selectedNumber)")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            Spacer() 
        }
        .padding(30)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white)
        }
    }
}

struct QuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        // Example questions
        let exampleQuestions = [
            Question(id: UUID(), question: "How do you feel today?", selectedNumber: 0),
            Question(id: UUID(), question: "How was your sleep last night?", selectedNumber: 0),
            Question(id: UUID(), question: "How productive were you today?", selectedNumber: 0),
            Question(id: UUID(), question: "Are you anxious?", selectedNumber: 0),
            Question(id: UUID(), question: "What is your biggest stressor right now?", selectedNumber: 0),
        ]
        
        // Initializing QuestionsView with example questions and a dummy onFinish function
        QuestionsView(questions: exampleQuestions, onFinish: {
            print("Finished answering all questions.")
        })
    }
}
