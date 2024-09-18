import SwiftUI

// Main View
struct PPContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            PPIntroView().environmentObject(authViewModel)
        }
    }
}

// Intro Screen
struct PPIntroView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 10) {
            Text("Mental Health Quiz")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white)
                .padding()
                .padding(.vertical, -20)

            Text("This questionnaire will help us understand your concerns and provide a personalized plan for you.")
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)

            NavigationLink(destination: PPQuestionnaireView().environmentObject(authViewModel)) {
                Text("Start")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("Medium Blue"))
                    .cornerRadius(10)
            }
            .padding([.leading, .trailing], 0)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("SentMessage"))
        .edgesIgnoringSafeArea(.all)
    }
}

// Questionnaire View
//struct PPQuestionnaireView: View {
//    @EnvironmentObject var authViewModel: AuthViewModel
//
//    @State private var currentIndex: Int = 0
//    @State private var answers: [Int] = Array(repeating: 0, count: ppQuestions.count)
//    @State private var followUpAnswers: [String] = Array(repeating: "", count: ppQuestions.count)
//    @State private var showResults = false
//
//    var body: some View {
//        VStack {
//            if currentIndex < ppQuestions.count * 2 {
//                let index = currentIndex / 2
//                let isFollowUp = currentIndex % 2 == 1
//
//                if isFollowUp {
//                    PPFUQuestionView(
//                        index: index,
//                        question: ppQuestions[index],
//                        followUpAnswer: $followUpAnswers[index],
//                        nextAction: {
//                            currentIndex += 1
//                        }
//                    )
//                } else {
//                    PPQuestionView(
//                        index: index,
//                        question: ppQuestions[index],
//                        answer: $answers[index],
//                        nextAction: {
//                            if answers[index] >= 3 {
//                                currentIndex += 1
//                            } else {
//                                currentIndex += 1
//                                if currentIndex < ppQuestions.count * 2, currentIndex % 2 == 1 {
//                                    currentIndex += 1
//                                }
//                            }
//                        }
//                    )
//                }
//            } else {
//                PPResultsView()
//                    .onAppear {
//                        print(answers)
//                        print(followUpAnswers)
//                    }
//            }
//        }
//        .background(Color("SentMessage").edgesIgnoringSafeArea(.all))
//    }
//}
//
//// Question View
//struct PPQuestionView: View {
//    let index: Int
//    let question: PPQuestion
//    @Binding var answer: Int
//    let nextAction: () -> Void
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            Text("Question \(index + 1):")
//                .font(.title2)
//                .foregroundColor(.white)
//
//            Text(question.text)
//                .font(.title3)
//                .fontWeight(.bold)
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity, alignment: .topLeading)
//
//            VStack {
//                ForEach(1...5, id: \.self) { value in
//                    Button(action: {
//                        answer = value
//                    }) {
//                        Text(question.options[value - 1])
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(answer == value ? Color.green : Color.white)
//                            .foregroundColor(answer == value ? .white : .black)
//                            .cornerRadius(10)
//                    }
//                }
//            }
//            
//            Button(action: nextAction) {
//                Text("Next")
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(answer == 0 ? Color.gray : Color("Medium Blue"))
//                    .cornerRadius(10)
//            }
//            .disabled(answer == 0)
//        }
//        .padding()
//        .background(Color("SentMessage"))
//        .cornerRadius(10)
//        .shadow(radius: 5)
//        .frame(maxHeight: .infinity)
//    }
//}
//
//struct PPFUQuestionView: View {
//    let index: Int
//    let question: PPQuestion
//    @Binding var followUpAnswer: String
//    let nextAction: () -> Void
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Question \(index + 1) Follow-up:")
//                .font(.headline)
//                .foregroundColor(.white)
//            
//            Text(question.followUp)
//                .font(.title2)
//                .foregroundColor(.white)
//            
//            if question.text.contains("suicidal thought") {
//                VStack {
//                    TextEditor(text: $followUpAnswer)
//                        .frame(minHeight: 100, maxHeight: .infinity)
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(10)
//                        .shadow(radius: 5)
//                        .padding(.bottom, 20)
//                    Button(action: {
//                        if let url = URL(string: "tel://988") {
//                            UIApplication.shared.open(url)
//                        }
//                        nextAction()
//                    }) {
//                        Text("Call 988")
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.red)
//                            .cornerRadius(10)
//                    }
//                }
//            } else {
//                TextEditor(text: $followUpAnswer)
//                    .frame(minHeight: 100, maxHeight: .infinity)
//                    .padding()
//                    .background(Color.white)
//                    .cornerRadius(10)
//                    .shadow(radius: 5)
//                    .padding(.bottom, 20)
//                Button(action: nextAction) {
//                    Text("Next")
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(followUpAnswer.count < 10 ? Color.gray : Color.blue)
//                        .cornerRadius(10)
//                }
//                .disabled(followUpAnswer.count < 10)
//            }
//        }
//        .padding()
//        .background(Color("SentMessage"))
//        .cornerRadius(10)
//        .shadow(radius: 5)
//        .frame(maxHeight: .infinity)
//        .background(Color("SentMessage").edgesIgnoringSafeArea(.all))
//    }
//}
//
//// Results View
//struct PPResultsView: View {
//    var body: some View {
//        VStack {
//            Text("Your Top Concerns")
//                .font(.title)
//                .fontWeight(.bold)
//                .padding()
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity, alignment: .leading)
//
//            ForEach(ppTopConcerns) { concern in
//                VStack(alignment: .leading, spacing: 10) {
//                    Text(concern.title)
//                        .font(.headline)
//                        .foregroundColor(.black)
//                    
//                    Text(concern.description)
//                        .font(.body)
//                        .foregroundColor(.black)
//                }
//                .padding()
//                .background(Color.white)
//                .cornerRadius(10)
//                .shadow(radius: 5)
//                .padding(.vertical, 5)
//            }
//
//            NavigationLink(destination: PPPlansView()) {
//                Text("Next")
//                    .foregroundColor(.white)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color("Medium Blue"))
//                    .cornerRadius(10)
//            }
//            .padding(.top, 20)
//        }
//        .padding()
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color("SentMessage"))
//        .edgesIgnoringSafeArea(.all)
//    }
//}
//
//// Plans View
//struct PPPlansView: View {
//    @State private var selectedPlan: PPPlan? = nil
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Select a Plan")
//                .font(.title)
//                .fontWeight(.bold)
//                .foregroundColor(.white)
//                .padding()
//                .frame(maxWidth: .infinity, alignment: .leading)
//
//            ForEach(ppPlans) { plan in
//                Button(action: {
//                    selectedPlan = plan
//                }) {
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text(plan.title)
//                            .font(.headline)
//                            .foregroundColor(selectedPlan == plan ? .white : .black)
//                        
//                        Text(plan.description)
//                            .font(.body)
//                            .foregroundColor(selectedPlan == plan ? .white : .black)
//                    }
//                    .padding()
//                    .background(selectedPlan == plan ? Color.green : Color.white)
//                    .cornerRadius(10)
//                    .shadow(radius: 5)
//                }
//                .padding(.vertical, 5)
//            }
//
//            NavigationLink(destination: PPFinalView(selectedPlan: selectedPlan ?? ppPlans.first!)) {
//                Text("Submit")
//                    .foregroundColor(.white)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(selectedPlan != nil ? Color.green : Color.gray)
//                    .cornerRadius(10)
//            }
//            .disabled(selectedPlan == nil)
//            .padding(.top, 20)
//        }
//        .padding()
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color("SentMessage"))
//        .edgesIgnoringSafeArea(.all)
//        .navigationBarTitle("Personalized Plans", displayMode: .inline)
//    }
//}
//
//// Final View
//struct PPFinalView: View {
//    let selectedPlan: PPPlan
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text(selectedPlan.title)
//                .font(.headline)
//                .foregroundColor(.white)
//            
//            Text(selectedPlan.description)
//                .font(.body)
//                .padding()
//                .background(Color.white)
//                .cornerRadius(10)
//                .shadow(radius: 5)
//        }
//        .padding()
//        .background(Color("SentMessage").edgesIgnoringSafeArea(.all))
//        .cornerRadius(10)
//        .shadow(radius: 5)
//        .navigationBarTitle("Your Plan", displayMode: .inline)
//    }
//}

//// Data Models and Sample Data
//struct PPQuestion {
//    let text: String
//    let options: [String]
//    let followUp: String
//}
//
//let ppQuestionsold: [PPQuestion] = [
//    PPQuestion(text: "How much does being preoccupied by negative thoughts impact your daily life?",
//               options: ["Not at all", "A little", "Moderately", "Quite a bit", "Extremely"],
//               followUp: "Can you share a recent time when these negative thoughts really got in the way?"),
//    PPQuestion(text: "How much does restlessness affect your daily routine?",
//               options: ["Not at all", "Slightly", "Moderately", "Quite a bit", "Extremely"],
//               followUp: "Can you tell me about a specific day when restlessness really impacted what you were doing?"),
//    PPQuestion(text: "How would you describe your level of fatigue?",
//               options: ["Negligible", "Mild", "Moderate", "Considerable", "Extreme"],
//               followUp: "Can you recall a recent time when your fatigue really affected your day?"),
//    PPQuestion(text: "How would you describe your difficulty in concentrating?",
//               options: ["Never", "Rarely", "Sometimes", "Often", "Always"],
//               followUp: "Can you provide a specific instance within the last week or month where your difficulty in concentration significantly impacted your day-to-day activities?"),
//    PPQuestion(text: "How would you describe your level of irritability?",
//               options: ["Completely calm", "Somewhat calm", "Neutral", "Somewhat irritable", "Very irritable"],
//               followUp: "Could you share a specific instance in the last week or month where your level of irritability was particularly noticeable or impactful?"),
//    PPQuestion(text: "How would you describe your experience with muscle tension?",
//               options: ["Almost Never", "Rarely", "Sometimes", "Often", "Constantly"],
//               followUp: "Could you share a specific example from the past week or month where you experienced notable muscle tension in certain areas? How did it impact your daily activities?"),
//    PPQuestion(text: "How often do you experience panic attacks?",
//               options: ["Rarely", "Occasionally", "Frequently", "Very Often", "Always"],
//               followUp: "Panic Attacks are scary. Could you share a specific time when you experienced a panic attack? What were you doing at that moment?"),
//]

struct PPConcern: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
}

let ppTopConcerns: [PPConcern] = [
    PPConcern(title: "Excessive Worrying", description: "Description for Excessive Worrying"),
    PPConcern(title: "Restlessness", description: "Description for Restlessness"),
    PPConcern(title: "Avoidance", description: "Description for Avoidance")
]

struct PPPlan: Identifiable , Decodable, Equatable{
    static func == (lhs: PPPlan, rhs: PPPlan) -> Bool {
        lhs.id == rhs.id
    }
    let id = UUID()
    let title: String
    let description: String
    let tasks: [TaskFirebase]
}

//ppPlans: [PPPlan] = [
//    PPPlan(title: "Plan 1", description: "Description for Plan 1"),
//    PPPlan(title: "Plan 2", description: "Description for Plan 2"),
//    PPPlan(title: "Plan 3", description: "Description for Plan 3")
//]

struct PPContentView_Previews: PreviewProvider {
    static var previews: some View {
        PPContentView()
    }
}
