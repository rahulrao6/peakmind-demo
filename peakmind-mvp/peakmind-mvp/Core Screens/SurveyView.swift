////
////  SurveyView.swift
////  peakmind-mvp
////
////  Created by Mikey Halim on 2/26/24.
////
//
//import SwiftUI
//
//struct SurveyView: View {
//    @State var questions = [
//        Question(id: UUID(), question: "Rank your anxiety.", selectedNumber: 1, descriptors: ["Low", "Mild", "Moderate", "High", "Severe"]),
//        Question(id: UUID(), question: "Rank your current mental state.", selectedNumber: 1, descriptors: ["Calm", "Neutral", "Anxious", "Stressed", "Overwhelmed"]),
//        Question(id: UUID(), question: "Rank your self-care abilities.", selectedNumber: 1, descriptors: ["Neglected", "Minimal", "Average", "Good", "Excellent"]),
//        Question(id: UUID(), question: "Rank your support systems.", selectedNumber: 1, descriptors: ["Weak", "Limited", "Moderate", "Strong", "Very Strong"]),
//        Question(id: UUID(), question: "Rank your stress.", selectedNumber: 1, descriptors: ["Low", "Mild", "Moderate", "High", "Severe"]),
//        Question(id: UUID(), question: "Rank your eating habits.", selectedNumber: 1, descriptors: ["Poor", "Below Average", "Average", "Above Average", "Excellent"])
//    ]
//    
//    @Environment(\.dismiss) private var dismiss
//    @State private var progress: CGFloat = 0
//    @State private var currentIndex: Int = 0
//    
//    var body: some View {
//        VStack(spacing: 15) {
//            ZStack {
//                // Rectangle behind the "Mental Health Quiz" text and progress bar
//                Rectangle()
//                    .fill(Color(hex: "071a4b")!)
//                    .frame(maxWidth: .infinity) // Ensures it stretches the full width
//                    .frame(height: 200) // Adjust height as necessary for the header
//                    .ignoresSafeArea(edges: .top) // Make sure it extends to the top
//                    .padding(.horizontal, -50)
//                
//                VStack(spacing: 10) {
//                    Button {
//                        dismiss()
//                    } label: {
//                        Image(systemName: "xmark")
//                            .font(.custom("SFProText-Bold", size: 20))
//                            .foregroundColor(.white)
//                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.horizontal, 15)
//
//                    Text("Mental Health Quiz")
//                        .font(.custom("SFProText-Heavy", size: 28))
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.leading, 15)
//                        .foregroundColor(.white)
//                        .padding(.top, 20)
//
//                    GeometryReader { geometry in
//                        let size = geometry.size
//                        ZStack(alignment: .leading) {
//                            Rectangle()
//                                .fill(Color.gray.opacity(0.4)) // Lighter color for the empty progress bar
//
//                            Rectangle()
//                                .fill(Color(hex: "b0e8ff")!) // Progress bar color
//                                .frame(width: progress * size.width, alignment: .leading)
//                        }
//                        .clipShape(Capsule())
//                    }
//                    .frame(height: 20)
//                    .padding(.horizontal, 15)
//                    .padding(.top, 5)
//                }
//            }
//            .frame(maxWidth: .infinity)
//            
//
//            
//            // Questions
//            GeometryReader { _ in
//                if currentIndex < questions.count {
//                    QuestionView(question: $questions[currentIndex])
//                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
//                }
//            }
//            .padding(.horizontal, 10)
//            .padding(.vertical, 15)
//            
//            // Back Button - only show if currentIndex > 0
//            // Back and Next buttons side by side
//            HStack {
//                if currentIndex > 0 {
//                    Button(action: {
//                        withAnimation(.easeInOut) {
//                            currentIndex -= 1
//                            progress = CGFloat(currentIndex) / CGFloat(questions.count - 1)
//                        }
//                    }) {
//                        Text("Back")
//                            .font(.custom("SFProText-Bold", size: 18))
//                            .foregroundColor(.white) // Transparent text color
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(Color.clear) // Transparent background
//                            .cornerRadius(10)
//                    }
//                    .padding(.horizontal, 5)
//                }
//
//                // Next or Finish Button
//                CustomButtonView(title: currentIndex == (questions.count - 1) ? "Finish" : "Next Question") {
//                    if currentIndex == (questions.count - 1) {
//                        print(questions)
//                        // Custom logic for finishing survey
//                    } else {
//                        withAnimation(.easeInOut) {
//                            currentIndex += 1
//                            progress = CGFloat(currentIndex) / CGFloat(questions.count - 1)
//                        }
//                    }
//                }
//            }
//            .padding(.bottom, 5)
//
//        }
//        .padding(15)
//        .background {
//            LinearGradient(
//                gradient: Gradient(colors: [Color(hex: "112864")!, Color(hex: "23429a")!]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            ).ignoresSafeArea()
//        }
//        .edgesIgnoringSafeArea(.top) // Extend to the top
//
//    }
//
//
//    
//    @ViewBuilder
//    func QuestionView(question: Binding<Question>) -> some View {
//        VStack(alignment: .leading, spacing: 20) {
//            Text("Question \(currentIndex + 1)/\(questions.count)")
//                .font(.custom("SFProText-Bold", size: 18))
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity, alignment: .topLeading)
//            
//            Text(question.wrappedValue.question)
//                .font(.custom("SFProText-Heavy", size: 40))
//                .foregroundColor(.white)
//            
//            let sliderBinding = Binding<Double>(
//                get: {
//                    Double(question.wrappedValue.selectedNumber)
//                },
//                set: {
//                    question.wrappedValue.selectedNumber = Int($0)
//                }
//            )
//            
//            VStack {
//                CustomSlider(value: sliderBinding, range: 1...5)
//                    .frame(height: 60)
//                
//                // Display the descriptor based on the current selected number
//                Text(question.wrappedValue.descriptors[question.wrappedValue.selectedNumber - 1])
//                    .font(.custom("SFProText-Bold", size: 30))
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .padding(.top, -20)
//            }
//            
//            Spacer()
//        }
//        .padding(15)
//    }
//
//    struct CustomSlider: View {
//        @Binding var value: Double
//        var range: ClosedRange<Double>
//        
//        var body: some View {
//            GeometryReader { geometry in
//                ZStack(alignment: .leading) {
//                    Rectangle()
//                        .fill(Color.gray.opacity(0.3))
//                        .frame(height: 15)
//                        .cornerRadius(7.5)
//                    
//                    Rectangle()
//                        .fill(Color(hex: "b0e8ff")!)
//                        .frame(width: CGFloat(value - range.lowerBound) / CGFloat(range.upperBound - range.lowerBound) * geometry.size.width, height: 15)
//                        .cornerRadius(7.5)
//                    
//                    Circle()
//                        .frame(width: 30, height: 30)
//                        .offset(x: CGFloat(value - range.lowerBound) / CGFloat(range.upperBound - range.lowerBound) * geometry.size.width - 15)
//                        .foregroundColor(Color(hex: "b0e8ff")!)
//                }
//                .gesture(DragGesture(minimumDistance: 0).onChanged { drag in
//                    let sliderWidth = geometry.size.width
//                    let newValue = min(max(Double(drag.location.x / sliderWidth) * (range.upperBound - range.lowerBound) + range.lowerBound, range.lowerBound), range.upperBound)
//                    value = newValue
//                })
//            }
//        }
//    }
//
//    
//    // Custom Button View
//    struct CustomButtonView: View {
//        let title: String
//        let action: () -> Void
//        
//        var body: some View {
//            Button(action: action) {
//                Text(title)
//                    .font(.custom("SFProText-Bold", size: 18))
//                    .foregroundColor(.black)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color(hex: "b0e8ff")!)
//                    .cornerRadius(10)
//            }
//            .padding(.horizontal, 5)
//        }
//    }
//    
//}
//struct SurveyView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Example questions
//        let exampleQuestions = [
//            Question(id: UUID(), question: "I feel energized most of the day.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"]),
//            Question(id: UUID(), question: "I have a lot of stamina.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"]),
//            Question(id: UUID(), question: "I find it easy to get out of bed in the morning.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"]),
//        ]
//        
//        // Initializing SurveyView with example questions
//        SurveyView(questions: exampleQuestions)
//    }
//}
import SwiftUI


// Base SurveyView, used for all quizzes
struct SurveyView: View {
    @State var questions: [Question]
    @Environment(\.dismiss) private var dismiss
    @State private var progress: CGFloat = 0
    @State private var currentIndex: Int = 0
    @EnvironmentObject var viewModel: AuthViewModel
    let quizType: String  // Specify the quiz type to distinguish saving

    var body: some View {
        VStack(spacing: 15) {
            // Header and Progress bar
            ZStack {
                Rectangle()
                    .fill(Color(hex: "071a4b")!)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .ignoresSafeArea(edges: .top)
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

                    Text("\(quizType) Quiz")
                        .font(.custom("SFProText-Heavy", size: 28))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 15)
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    GeometryReader { geometry in
                        let size = geometry.size
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.4))

                            Rectangle()
                                .fill(Color(hex: "b0e8ff")!)
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

            // Navigation buttons
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
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.clear)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 5)
                }

                CustomButtonView(title: currentIndex == (questions.count - 1) ? "Finish" : "Next Question") {
                    if currentIndex == (questions.count - 1) {
                        Task {
                            await saveToFirebase()
                        }
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
        .edgesIgnoringSafeArea(.top)
    }

    @ViewBuilder
    func QuestionView(question: Binding<Question>) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Question \(currentIndex + 1)/\(questions.count)")
                .font(.custom("SFProText-Bold", size: 18))
                .foregroundColor(.white)

            Text(question.wrappedValue.question)
                .font(.custom("SFProText-Heavy", size: 40))
                .foregroundColor(.white)

            let sliderBinding = Binding<Double>(
                get: { Double(question.wrappedValue.selectedNumber) },
                set: { question.wrappedValue.selectedNumber = Int($0) }
            )

            VStack {
                CustomSlider(value: sliderBinding, range: 1...5)
                    .frame(height: 60)

                Text(question.wrappedValue.descriptors[question.wrappedValue.selectedNumber - 1])
                    .font(.custom("SFProText-Bold", size: 30))
                    .foregroundColor(.white)
                    .padding(.top, -20)
            }
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

    // Save answers to Firebase
    func saveToFirebase() async {
        let totalScore = questions.map { $0.selectedNumber }.reduce(0, +)
        do {
            try await viewModel.saveQuizResults(quizType: quizType, totalScore: totalScore, answers: questions.map { $0.selectedNumber })
        } catch {
            print("Failed to save quiz: \(error.localizedDescription)")
        }
    }
}
import Firebase


// Example of Firebase saving extension
extension AuthViewModel {
    func saveQuizResults(quizType: String, totalScore: Int, answers: [Int]) async throws {
        guard let userId = currentUser?.id else { return }
        
        let db = Firestore.firestore()
        let quizData: [String: Any] = [
            "score": totalScore,
            "answers": answers,
            "date": Timestamp(date: Date())
        ]
        
        db.collection("users").document(userId).collection("profiles").document(quizType).setData(quizData) { error in
            if let error = error {
                print("Error saving \(quizType) data: \(error)")
            }
        }
    }
}

// Usage example for a GAD-7 quiz
struct GAD7QuizView: View {
    
    var body: some View {
        SurveyView(
            questions: [
                    Question(id: UUID(), question: "Feeling nervous, anxious, or on edge?", selectedNumber: 1, descriptors: ["Not at all", "Several days", "More than half the days", "Nearly every day"]),
                    Question(id: UUID(), question: "Not being able to stop or control worrying?", selectedNumber: 1, descriptors: ["Not at all", "Several days", "More than half the days", "Nearly every day"]),
                    Question(id: UUID(), question: "Worrying too much about different things?", selectedNumber: 1, descriptors: ["Not at all", "Several days", "More than half the days", "Nearly every day"]),
                    Question(id: UUID(), question: "Trouble relaxing?", selectedNumber: 1, descriptors: ["Not at all", "Several days", "More than half the days", "Nearly every day"]),
                    Question(id: UUID(), question: "Being so restless that it is hard to sit still?", selectedNumber: 1, descriptors: ["Not at all", "Several days", "More than half the days", "Nearly every day"]),
                    Question(id: UUID(), question: "Becoming easily annoyed or irritable?", selectedNumber: 1, descriptors: ["Not at all", "Several days", "More than half the days", "Nearly every day"]),
                    Question(id: UUID(), question: "Feeling afraid as if something awful might happen?", selectedNumber: 1, descriptors: ["Not at all", "Several days", "More than half the days", "Nearly every day"])
            ],
            quizType: "GAD7"
        )
    }
}


struct PHQ9QuizView: View {
    
    var body: some View {
        SurveyView(
            questions: [
                Question(id: UUID(), question: "Little interest or pleasure in doing things?", selectedNumber: 1, descriptors: ["Not at all", "Several days", "More than half the days", "Nearly every day"]),
                    Question(id: UUID(), question: "Feeling down, depressed, or hopeless?", selectedNumber: 1, descriptors: ["Not at all", "Several days", "More than half the days", "Nearly every day"]),
                    Question(id: UUID(), question: "Trouble falling or staying asleep, or sleeping too much?", selectedNumber: 1, descriptors: ["Not at all", "Several days", "More than half the days", "Nearly every day"]),
                    Question(id: UUID(), question: "Feeling tired or having little energy?", selectedNumber: 1, descriptors: ["Not at all", "Several days", "More than half the days", "Nearly every day"]),
                    Question(id: UUID(), question: "Poor appetite or overeating?", selectedNumber: 1, descriptors: ["Not at all", "Several days", "More than half the days", "Nearly every day"]),
                    Question(id: UUID(), question: "Feeling bad about yourself — or that you are a failure or have let yourself or your family down?", selectedNumber: 1, descriptors: ["Not at all", "Several days", "More than half the days", "Nearly every day"]),
                    Question(id: UUID(), question: "Trouble concentrating on things, such as reading the newspaper or watching television?", selectedNumber: 1, descriptors: ["Not at all", "Several days", "More than half the days", "Nearly every day"]),
                    Question(id: UUID(), question: "Moving or speaking so slowly that other people could have noticed? Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual?", selectedNumber: 1, descriptors: ["Not at all", "Several days", "More than half the days", "Nearly every day"]),
                    Question(id: UUID(), question: "Thoughts that you would be better off dead or of hurting yourself in some way?", selectedNumber: 1, descriptors: ["Not at all", "Several days", "More than half the days", "Nearly every day"])
                
            ],
            quizType: "PHQ9"
        )
    }
}



struct PSSQuizView: View {
    
    var body: some View {
        SurveyView(
            questions: [
                Question(id: UUID(), question: "In the last month, how often have you been upset because of something that happened unexpectedly?", selectedNumber: 1, descriptors: ["Never", "Almost Never", "Sometimes", "Fairly Often", "Very Often"]),
                    Question(id: UUID(), question: "In the last month, how often have you felt that you were unable to control the important things in your life?", selectedNumber: 1, descriptors: ["Never", "Almost Never", "Sometimes", "Fairly Often", "Very Often"]),
                    Question(id: UUID(), question: "In the last month, how often have you felt nervous and stressed?", selectedNumber: 1, descriptors: ["Never", "Almost Never", "Sometimes", "Fairly Often", "Very Often"]),
                    Question(id: UUID(), question: "In the last month, how often have you felt confident about your ability to handle your personal problems?", selectedNumber: 1, descriptors: ["Never", "Almost Never", "Sometimes", "Fairly Often", "Very Often"]),
                    Question(id: UUID(), question: "In the last month, how often have you felt that things were going your way?", selectedNumber: 1, descriptors: ["Never", "Almost Never", "Sometimes", "Fairly Often", "Very Often"]),
                    Question(id: UUID(), question: "In the last month, how often have you found that you could not cope with all the things that you had to do?", selectedNumber: 1, descriptors: ["Never", "Almost Never", "Sometimes", "Fairly Often", "Very Often"]),
                    Question(id: UUID(), question: "In the last month, how often have you been able to control irritations in your life?", selectedNumber: 1, descriptors: ["Never", "Almost Never", "Sometimes", "Fairly Often", "Very Often"]),
                    Question(id: UUID(), question: "In the last month, how often have you felt that you were on top of things?", selectedNumber: 1, descriptors: ["Never", "Almost Never", "Sometimes", "Fairly Often", "Very Often"]),
                    Question(id: UUID(), question: "In the last month, how often have you been angered because of things that happened that were outside of your control?", selectedNumber: 1, descriptors: ["Never", "Almost Never", "Sometimes", "Fairly Often", "Very Often"]),
                    Question(id: UUID(), question: "In the last month, how often have you felt difficulties were piling up so high that you could not overcome them?", selectedNumber: 1, descriptors: ["Never", "Almost Never", "Sometimes", "Fairly Often", "Very Often"])
                
            ],
            quizType: "PSS"
        )
    }
}


struct NMRQQuizView: View {
    
    var body: some View {
        SurveyView(
            questions: [
                Question(id: UUID(), question: "In a difficult spot, I turn at once to what can be done to put things right.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Somewhat Disagree", "Neutral", "Somewhat Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I influence where I can, rather than worrying about what I can’t influence.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Somewhat Disagree", "Neutral", "Somewhat Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I don’t take criticism personally.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Somewhat Disagree", "Neutral", "Somewhat Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I generally manage to keep things in perspective.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Somewhat Disagree", "Neutral", "Somewhat Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I am calm in a crisis.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Somewhat Disagree", "Neutral", "Somewhat Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I’m good at finding solutions to problems.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Somewhat Disagree", "Neutral", "Somewhat Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I wouldn’t describe myself as an anxious person.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Somewhat Disagree", "Neutral", "Somewhat Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I don’t tend to avoid conflict.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Somewhat Disagree", "Neutral", "Somewhat Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I try to control events rather than being a victim of circumstances.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Somewhat Disagree", "Neutral", "Somewhat Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I trust my intuition.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Somewhat Disagree", "Neutral", "Somewhat Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I manage my stress levels well.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Somewhat Disagree", "Neutral", "Somewhat Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I feel confident and secure in my position.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Somewhat Disagree", "Neutral", "Somewhat Agree", "Strongly Agree"])
                
            ],
            quizType: "NMRQ"
        )
    }
}

struct ISIQuizView: View {
    
    var body: some View {
        SurveyView(
            questions: [
                Question(id: UUID(), question: "Difficulty falling asleep", selectedNumber: 1, descriptors: ["No difficulty", "Mild difficulty", "Moderate difficulty", "Severe difficulty", "Very severe difficulty"]),
                    Question(id: UUID(), question: "Difficulty staying asleep", selectedNumber: 1, descriptors: ["No difficulty", "Mild difficulty", "Moderate difficulty", "Severe difficulty", "Very severe difficulty"]),
                    Question(id: UUID(), question: "Problems waking up too early", selectedNumber: 1, descriptors: ["No difficulty", "Mild difficulty", "Moderate difficulty", "Severe difficulty", "Very severe difficulty"]),
                    Question(id: UUID(), question: "How satisfied/dissatisfied are you with your current sleep pattern?", selectedNumber: 1, descriptors: ["Very satisfied", "Satisfied", "Neutral", "Dissatisfied", "Very dissatisfied"]),
                    Question(id: UUID(), question: "How noticeable to others do you think your sleep problem is in terms of impairing the quality of your life?", selectedNumber: 1, descriptors: ["Not noticeable", "A little noticeable", "Somewhat noticeable", "Noticeable", "Very noticeable"]),
                    Question(id: UUID(), question: "How worried/distressed are you about your current sleep problem?", selectedNumber: 1, descriptors: ["Not at all", "A little", "Somewhat", "Much", "Very much"]),
                    Question(id: UUID(), question: "To what extent do you consider your sleep problem to interfere with your daily functioning?", selectedNumber: 1, descriptors: ["No interference", "A little", "Somewhat", "Much", "Very much"])
                
            ],
            quizType: "ISI"
        )
    }
}


struct EnergyQuizView: View {
    
    var body: some View {
        SurveyView(
            questions: [
                Question(id: UUID(), question: "I feel energized most of the day.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I have a lot of stamina.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I find it easy to get out of bed in the morning.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I am able to focus and concentrate easily.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I have a lot of mental energy.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I feel physically strong.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I have a lot of physical endurance.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I enjoy physical activity.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I feel motivated to accomplish my goals.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I am able to handle stress well.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I have a positive outlook on life.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I am able to sleep well at night.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I feel rested and refreshed after sleep.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I have a lot of energy for social activities.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"]),
                    Question(id: UUID(), question: "I am able to maintain a healthy diet.", selectedNumber: 1, descriptors: ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"])
                
            ],
            quizType: "Energy"
        )
    }
}
