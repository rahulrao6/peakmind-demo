//
//  NewPPContentView.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 7/24/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct PPAnswer: Identifiable {
    let id = UUID()
    let questionId: String
    let type: String
    var answer: Int
    var followUpAnswer: String
}

struct PPQuestion: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    let text: String
    let type: String
    let options: [String]
    let followUp: String
}

//let ppQuestions: [PPQuestion] = [
//    PPQuestion(id: "1", text: "How much does being preoccupied by negative thoughts impact your daily life?",
//               options: ["Not at all", "A little", "Moderately", "Quite a bit", "Extremely"],
//               followUp: "Can you share a recent time when these negative thoughts really got in the way?"),
//    PPQuestion(id: "2", text: "How much does restlessness affect your daily routine?",
//               options: ["Not at all", "Slightly", "Moderately", "Quite a bit", "Extremely"],
//               followUp: "Can you tell me about a specific day when restlessness really impacted what you were doing?"),
//    PPQuestion(id: "3", text: "How would you describe your level of fatigue?",
//               options: ["Negligible", "Mild", "Moderate", "Considerable", "Extreme"],
//               followUp: "Can you recall a recent time when your fatigue really affected your day?"),
//    PPQuestion(id: "4", text: "How would you describe your difficulty in concentrating?",
//               options: ["Never", "Rarely", "Sometimes", "Often", "Always"],
//               followUp: "Can you provide a specific instance within the last week or month where your difficulty in concentration significantly impacted your day-to-day activities?"),
//    PPQuestion(id: "5", text: "How would you describe your level of irritability?",
//               options: ["Completely calm", "Somewhat calm", "Neutral", "Somewhat irritable", "Very irritable"],
//               followUp: "Could you share a specific instance in the last week or month where your level of irritability was particularly noticeable or impactful?"),
//    PPQuestion(id: "6", text: "How would you describe your experience with muscle tension?",
//               options: ["Almost Never", "Rarely", "Sometimes", "Often", "Constantly"],
//               followUp: "Could you share a specific example from the past week or month where you experienced notable muscle tension in certain areas? How did it impact your daily activities?"),
//    PPQuestion(id: "7", text: "How often do you experience panic attacks?",
//               options: ["Rarely", "Occasionally", "Frequently", "Very Often", "Always"],
//               followUp: "Panic Attacks are scary. Could you share a specific time when you experienced a panic attack? What were you doing at that moment?"),
//]

struct PPQuestionnaireView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var currentIndex: Int = 0
    @State private var showResults = false

    var body: some View {
        VStack {
            if !authViewModel.questions.isEmpty && !authViewModel.answers.isEmpty && currentIndex < authViewModel.questions.count * 2 {
                let index = currentIndex / 2
                let isFollowUp = currentIndex % 2 == 1

                if isFollowUp {
                    PPFUQuestionView(
                        index: index,
                        question: authViewModel.questions[index],
                        followUpAnswer: $authViewModel.answers[index].followUpAnswer,
                        nextAction: {
                            currentIndex += 1
                        }
                    )
                } else {
                    PPQuestionView(
                        index: index,
                        question: authViewModel.questions[index],
                        answer: $authViewModel.answers[index].answer,
                        nextAction: {
                            if authViewModel.answers[index].answer >= 3 {
                                currentIndex += 1
                            } else {
                                currentIndex += 1
                                if currentIndex < authViewModel.questions.count * 2, currentIndex % 2 == 1 {
                                    currentIndex += 1
                                }
                            }
                        }
                    )
                }
            } else if !authViewModel.questions.isEmpty {
                PPResultsView(answers: authViewModel.answers)
                    .onAppear {
                        print(authViewModel.answers)
                        authViewModel.saveAnswers(answers: authViewModel.answers)
                    }
            } else {
                Text("Loading...")
            }
        }
        .onAppear {
            if authViewModel.questions.isEmpty {
                authViewModel.fetchQuestions()
            }
        }
        .background(Color("SentMessage").edgesIgnoringSafeArea(.all))
    }
}






// Question View
struct PPQuestionView: View {
    let index: Int
    let question: PPQuestion
    @Binding var answer: Int
    let nextAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Question \(index + 1):")
                .font(.title2)
                .foregroundColor(.white)

            Text(question.text)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .topLeading)

            VStack {
                ForEach(1...5, id: \.self) { value in
                    Button(action: {
                        answer = value
                    }) {
                        Text(question.options[value - 1])
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(answer == value ? Color.green : Color.white)
                            .foregroundColor(answer == value ? .white : .black)
                            .cornerRadius(10)
                    }
                }
            }

            Button(action: nextAction) {
                Text("Next")
                    .foregroundColor(.white)
                    .padding()
                    .background(answer == 0 ? Color.gray : Color("Medium Blue"))
                    .cornerRadius(10)
            }
            .disabled(answer == 0)
        }
        .padding()
        .background(Color("SentMessage"))
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(maxHeight: .infinity)
    }
}

struct PPFUQuestionView: View {
    let index: Int
    let question: PPQuestion
    @Binding var followUpAnswer: String
    let nextAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Question \(index + 1) Follow-up:")
                .font(.headline)
                .foregroundColor(.white)

            Text(question.followUp)
                .font(.title2)
                .foregroundColor(.white)

            TextEditor(text: $followUpAnswer)
                .frame(minHeight: 100, maxHeight: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.bottom, 20)

            Button(action: nextAction) {
                Text("Next")
                    .foregroundColor(.white)
                    .padding()
                    .background(followUpAnswer.count < 10 ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(followUpAnswer.count < 10)
        }
        .padding()
        .background(Color("SentMessage"))
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(maxHeight: .infinity)
        .background(Color("SentMessage").edgesIgnoringSafeArea(.all))
    }
}


// Results View
struct PPResultsView: View {
    let answers: [PPAnswer]

    var body: some View {
        VStack {
            Text("Your Top Concerns")
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(ppTopConcerns) { concern in
                VStack(alignment: .leading, spacing: 10) {
                    Text(concern.title)
                        .font(.headline)
                        .foregroundColor(.black)

                    Text(concern.description)
                        .font(.body)
                        .foregroundColor(.black)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.vertical, 5)
            }

            NavigationLink(destination: PPPlansView(answers: answers)) {
                Text("Next")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("Medium Blue"))
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("SentMessage"))
        .edgesIgnoringSafeArea(.all)
    }
}


// Plans View
struct PPPlansView: View {
    @State private var selectedPlan: PPPlan? = nil
    let answers: [PPAnswer]
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Select a Plan")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)


            if authViewModel.ppPlans.isEmpty {
                Text("Loading plans...")
                    .foregroundColor(.white)
            } else {
                ForEach(authViewModel.ppPlans) { plan in
                    Button(action: {
                        selectedPlan = plan
                    }) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(plan.title)
                                .font(.headline)
                                .foregroundColor(selectedPlan == plan ? .white : .black)
                            
                            Text(plan.description)
                                .font(.body)
                                .foregroundColor(selectedPlan == plan ? .white : .black)
                        }
                        .padding()
                        .background(selectedPlan == plan ? Color.green : Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                    .padding(.vertical, 5)
                }
                
                NavigationLink(destination: PPFinalView(selectedPlan: selectedPlan ?? authViewModel.ppPlans.first!, answers: answers).environmentObject(authViewModel)) {
                    Text("Submit")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedPlan != nil ? Color.green : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(selectedPlan == nil)
                .padding(.top, 20)
                .onTapGesture {
//                    if let selectedPlan = selectedPlan {
//                        authViewModel.savePersonalizedPlan(plan: selectedPlan, answers: answers)
//                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("SentMessage"))
        .edgesIgnoringSafeArea(.all)
        .navigationBarTitle("Personalized Plans", displayMode: .inline)
        .onAppear {
            authViewModel.fetchPlans { result in
                switch result {
                case .success:
                    //isLoading = false
                    print("yes")
                case .failure(let error):
                    //isLoading = false
                    errorMessage = error.localizedDescription
                }
            }//Use the actual user ID
        }
    }
}


struct PPFinalView: View {
    let selectedPlan: PPPlan
    let answers: [PPAnswer]
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ScrollView{
            VStack(spacing: 20) {
                Text(selectedPlan.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(selectedPlan.description)
                    .font(.body)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                
                ForEach(selectedPlan.tasks) { task in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(task.name)
                            .font(.body)
                            .foregroundColor(.black)
                        
                        Text("Rank: \(task.rank)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        if task.isCompleted {
                            Text("Completed at: \(task.timeCompleted)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.vertical, 5)
                }
            }
            .padding()
            .background(Color("SentMessage").edgesIgnoringSafeArea(.all))
            .cornerRadius(10)
            .shadow(radius: 5)
            .navigationBarTitle("Your Plan", displayMode: .inline)
            .onAppear{
                authViewModel.savePersonalizedPlan(plan: selectedPlan, answers: answers)
            }
        }
    }
}


//struct PPOverView: View {
//    @EnvironmentObject var authViewModel: AuthViewModel
//    @State private var plan: PPPlan?
//    @State private var errorMessage: String?
//    @State private var isLoading: Bool = true
//
//    var body: some View {
//        VStack {
//            if isLoading {
//                Text("Loading plan...")
//            } else if let errorMessage = errorMessage {
//                Text("Error: \(errorMessage)")
//                    .foregroundColor(.red)
//            } else if let plan = plan {
//                Text(plan.title)
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .padding()
//
//                Text(plan.description)
//                    .font(.body)
//                    .padding()
//
//                List(plan.tasks) { task in
//                    VStack(alignment: .leading) {
//                        Text(task.name)
//                            .font(.headline)
//                        Text("Rank: \(task.rank)")
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//                        if task.isCompleted {
//                            Text("Completed at: \(task.timeCompleted)")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                        }
//                    }
//                    .padding()
//                }
//            } else {
//                Text("No plan available.")
//            }
//        }
//        .onAppear {
//            fetchPlan()
//        }
//        .navigationBarTitle("Personalized Plan", displayMode: .inline)
//        .padding()
//    }
//
//    private func fetchPlan() {
//        authViewModel.fetchPersonalizedPlan { result in
//            switch result {
//            case .success(let fetchedPlan):
//                self.plan = fetchedPlan
//                self.isLoading = false
//            case .failure(let error):
//                self.errorMessage = error.localizedDescription
//                self.isLoading = false
//            }
//        }
//    }
//}
struct PersonalizedPlanView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var plan: PPPlan?
    @State private var errorMessage: String?
    @State private var isLoading: Bool = true

    var body: some View {
        VStack {
            if isLoading {
                Text("Loading plan...")
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else if let plan = plan {
                Text(plan.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()

                Text(plan.description)
                    .font(.body)
                    .padding()

                List(plan.tasks) { task in
                    VStack(alignment: .leading) {
                        Text(task.name)
                            .font(.headline)
                        Text("Rank: \(task.rank)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        if task.isCompleted {
                            Text("Completed at: \(task.timeCompleted)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                }
            } else {
                Text("No plan available.")
            }
        }
        .onAppear {
            fetchPlan()
        }
        .navigationBarTitle("Personalized Plan", displayMode: .inline)
        .padding()
    }

    private func fetchPlan() {
        authViewModel.fetchPersonalizedPlan { result in
            switch result {
            case .success(let fetchedPlan):
                self.plan = fetchedPlan
                self.isLoading = false
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
