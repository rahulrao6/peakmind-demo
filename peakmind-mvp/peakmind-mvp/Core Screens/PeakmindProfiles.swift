//
//  PeakmindProfiles.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 8/17/24.
//

import Foundation

import SwiftUI

struct GAD7QuizView: View {
    @State private var answers = Array(repeating: 0, count: 7)
    @State private var isSubmitted = false
    @EnvironmentObject var viewModel : AuthViewModel

    let questions = [
        "Feeling nervous, anxious, or on edge?",
        "Not being able to stop or control worrying?",
        "Worrying too much about different things?",
        "Trouble relaxing?",
        "Being so restless that it is hard to sit still?",
        "Becoming easily annoyed or irritable?",
        "Feeling afraid as if something awful might happen?"
    ]
    
    var totalScore: Int {
        answers.reduce(0, +)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    ForEach(0..<questions.count, id: \.self) { index in
                        Section(header: Text(questions[index])) {
                            Picker("Select your answer", selection: $answers[index]) {
                                Text("Not at all").tag(1)
                                Text("Several days").tag(2)
                                Text("More than half the days").tag(3)
                                Text("Nearly every day").tag(4)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                }
                Button(action: {
                    Task{
                        saveToFirebase()
                    }
                }) {
                    Text("Submit")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationBarTitle("GAD-7 Quiz")
            .alert(isPresented: $isSubmitted) {
                Alert(
                    title: Text("Submitted"),
                    message: Text("Your GAD-7 score is \(totalScore)"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    func saveToFirebase() {
        Task {
            do {
                try await viewModel.saveToGAD7(totalScore: totalScore, answers: answers)
            } catch {
                print("Failed to save routine: \(error.localizedDescription)")
            }
        }    }

}


import Foundation
import SwiftUI

struct PHQ9QuizView: View {
    @State private var answers = Array(repeating: 0, count: 9)
    @State private var isSubmitted = false
    @EnvironmentObject var viewModel : AuthViewModel

    let questions = [
        "Little interest or pleasure in doing things?",
        "Feeling down, depressed, or hopeless?",
        "Trouble falling or staying asleep, or sleeping too much?",
        "Feeling tired or having little energy?",
        "Poor appetite or overeating?",
        "Feeling bad about yourself — or that you are a failure or have let yourself or your family down?",
        "Trouble concentrating on things, such as reading the newspaper or watching television?",
        "Moving or speaking so slowly that other people could have noticed? Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual?",
        "Thoughts that you would be better off dead or of hurting yourself in some way?"
    ]
    
    var totalScore: Int {
        answers.reduce(0, +)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    ForEach(0..<questions.count, id: \.self) { index in
                        Section(header: Text(questions[index])) {
                            Picker("Select your answer", selection: $answers[index]) {
                                Text("Not at all").tag(1)
                                Text("Several days").tag(2)
                                Text("More than half the days").tag(3)
                                Text("Nearly every day").tag(4)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                }
                Button(action: {
                    Task {
                        saveToFirebase()
                    }
                }) {
                    Text("Submit")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationBarTitle("PHQ-9 Quiz")
            .alert(isPresented: $isSubmitted) {
                Alert(
                    title: Text("Submitted"),
                    message: Text("Your PHQ-9 score is \(totalScore)"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    func saveToFirebase() {
        Task {
            do {
                try await viewModel.saveToPHQ9(totalScore: totalScore, answers: answers)
            } catch {
                print("Failed to save routine: \(error.localizedDescription)")
            }
        }
    }
}

import Foundation
import SwiftUI
import Foundation
import SwiftUI

struct PSSQuizView: View {
    @State private var answers = Array(repeating: 0, count: 10) // Adjusted to 10 questions
    @State private var isSubmitted = false
    @EnvironmentObject var viewModel: AuthViewModel

    let questions = [
        "In the last month, how often have you been upset because of something that happened unexpectedly?",
        "In the last month, how often have you felt that you were unable to control the important things in your life?",
        "In the last month, how often have you felt nervous and stressed?",
        "In the last month, how often have you felt confident about your ability to handle your personal problems?", // Reverse this
        "In the last month, how often have you felt that things were going your way?", // Reverse this
        "In the last month, how often have you found that you could not cope with all the things that you had to do?",
        "In the last month, how often have you been able to control irritations in your life?", // Reverse this
        "In the last month, how often have you felt that you were on top of things?", // Reverse this
        "In the last month, how often have you been angered because of things that happened that were outside of your control?",
        "In the last month, how often have you felt difficulties were piling up so high that you could not overcome them?"
    ]
    
    var totalScore: Int {
        // Reversing scores for specific questions
        let reversedIndexes = [3, 4, 6, 7]
        var score = 0
        
        for (index, answer) in answers.enumerated() {
            if reversedIndexes.contains(index) {
                // Reverse the score: 0 = 4, 1 = 3, 2 = 2, 3 = 1, 4 = 0
                score += 4 - answer
            } else {
                score += answer
            }
        }
        return score
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    ForEach(0..<questions.count, id: \.self) { index in
                        Section(header: Text(questions[index])) {
                            Picker("Select your answer", selection: $answers[index]) {
                                Text("Never").tag(0)
                                Text("Almost Never").tag(1)
                                Text("Sometimes").tag(2)
                                Text("Fairly Often").tag(3)
                                Text("Very Often").tag(4)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                }
                Button(action: {
                    Task {
                        saveToFirebase()
                    }
                }) {
                    Text("Submit")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationBarTitle("PSS Quiz")
            .alert(isPresented: $isSubmitted) {
                Alert(
                    title: Text("Submitted"),
                    message: Text("Your PSS score is \(totalScore)"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    func saveToFirebase() {
        Task {
            do {
                try await viewModel.saveToPSS(totalScore: totalScore, answers: answers)
                isSubmitted = true
            } catch {
                print("Failed to save routine: \(error.localizedDescription)")
            }
        }
    }
}



import Foundation
import SwiftUI
import Foundation
import SwiftUI

struct NMRQQuizView: View {
    @State private var answers = Array(repeating: 1, count: 12) // Default to 1 (Strongly Disagree)
    @State private var isSubmitted = false
    @EnvironmentObject var viewModel: AuthViewModel

    let questions = [
        "In a difficult spot, I turn at once to what can be done to put things right.",
        "I influence where I can, rather than worrying about what I can’t influence.",
        "I don’t take criticism personally.",
        "I generally manage to keep things in perspective.",
        "I am calm in a crisis.",
        "I’m good at finding solutions to problems.",
        "I wouldn’t describe myself as an anxious person.",
        "I don’t tend to avoid conflict.",
        "I try to control events rather than being a victim of circumstances.",
        "I trust my intuition.",
        "I manage my stress levels well.",
        "I feel confident and secure in my position."
    ]
    
    var totalScore: Int {
        answers.reduce(0, +)
    }
    
    var feedbackText: String {
        switch totalScore {
        case 0...37:
            return "A developing level of resilience. Your score indicates that, although you may not always feel at the mercy of events, you would benefit significantly from developing aspects of your behavior."
        case 38...43:
            return "An established level of resilience. Your score indicates that you may occasionally have tough days when you can’t quite make things go your way, but you rarely feel ready to give up."
        case 44...48:
            return "A strong level of resilience. Your above-average score indicates that you are pretty good at rolling with the punches and you have an impressive track record of turning setbacks into opportunities."
        case 49...60:
            return "An exceptional level of resilience. Your score indicates that you are very resilient most of the time and rarely fail to bounce back – whatever life throws at you. You believe in making your own luck."
        default:
            return ""
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    ForEach(0..<questions.count, id: \.self) { index in
                        Section(header: Text(questions[index])) {
                            Picker("Select your answer", selection: $answers[index]) {
                                Text("Strongly Disagree").tag(1)
                                Text("Somewhat Disagree").tag(2)
                                Text("Neutral").tag(3)
                                Text("Somewhat Agree").tag(4)
                                Text("Strongly Agree").tag(5)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                }
                Button(action: {
                    Task {
                        saveToFirebase()
                        isSubmitted = true
                    }
                }) {
                    Text("Submit")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationBarTitle("NMRQ Quiz")
            .alert(isPresented: $isSubmitted) {
                Alert(
                    title: Text("Submitted"),
                    message: Text("Your NMRQ score is \(totalScore).\n\n\(feedbackText)"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    func saveToFirebase() {
        Task {
            do {
                try await viewModel.saveToNMRQ(totalScore: totalScore, answers: answers)
            } catch {
                print("Failed to save routine: \(error.localizedDescription)")
            }
        }
    }
}