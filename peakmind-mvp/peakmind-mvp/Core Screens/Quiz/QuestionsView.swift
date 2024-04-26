//
//  QuestionsView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 2/26/24.
//

import SwiftUI
import FirebaseFirestore


struct QuestionsView: View {
    @EnvironmentObject var viewModel : AuthViewModel
    @State private var navigateToHome = false

    //@State var questions: [Question]
    //var onFinish: () -> ()
    
    @State var questions = [
        Question(id: UUID(), question: "How often would you say you feel anxious?", selectedNumber: 1, peak_tackled: "Anxiety", descriptors: [
            "Severe anxiety very often",
            "Frequent anxiety difficult to manage",
            "Regular anxiety at a manageable level",
            "Noticeable but non-problematic",
            "Very minimal anxiety, if any"]),
        Question(id: UUID(), question: "How would you describe your current mental health?", selectedNumber: 1, peak_tackled: "Current Mental State", descriptors: [
            "Very negative",
            "Somewhat negative baseline headspace",
            "Neither positive nor negative headspace",
            "Somewhat positive baseline headspace",
            "Very positive"
        ]),
        Question(id: UUID(), question: "How often do you practice self-care activities?", selectedNumber: 1, peak_tackled: "Current Mental State", descriptors: [
            "Poor, rare self care",
            "Occasional self care (once in a while)",
            "Mediocre, sporadic self care",
            "Somewhat regular self care, a few times a week",
            "Excellent, regular self care"
        ]),
        Question(id: UUID(), question: "Do you feel like you have a strong support system?", selectedNumber: 1, peak_tackled: "Support Systems", descriptors: [
            "No, I don't feel like I have a strong support system",
            "Not very effective, but there",
            "Decent, sometimes there as expected",
            "Good, usually there when needed",
            "Yes, I have a strong support system"
        ]),

        Question(id: UUID(), question: "How many days do you feel stressed on a weekly basis?", selectedNumber: 1, peak_tackled: "Stress", descriptors: [
            "One day or less",
            "Two days",
            "Three days",
            "Four days",
            "Over five days"
        ]),

        Question(id: UUID(), question: "How would you describe your eating habits?", selectedNumber: 1, peak_tackled: "Eating", descriptors: [
            "Severe inconsistent eating",
            "Regular struggles at meal times",
            "Inconsistent eating tendencies on a daily basis",
            "Occasional struggles with over/under eating",
            "Perfectly normal"
        ]),
    ]
    
    @Environment(\.dismiss) private var dismiss
    @State private var progress: CGFloat = 0
    @State private var currentIndex: Int = 0
    //@State private var showPersonalizedPlan: Bool = false
    
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
                        .fill(Color("Ice Blue"))
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
                    //onFinish()
                    sendToFirebase()
                    callModel()
                    navigateToHome = true
                    //showPersonalizedPlan = true
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
            Color("SentMessage").ignoresSafeArea()
        }
        
        .background(
            NavigationLink(destination: SelfCareHome().environmentObject(viewModel), isActive: $navigateToHome) {
                EmptyView()
            }
            .hidden()
            .navigationBarBackButtonHidden(true) // Hide back button

        )
        //.sheet(isPresented: $showPersonalizedPlan) {
        //    PersonalizedPlanView()
        //}
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
                .accentColor(Color("Ice Blue"))
            
            Text(question.wrappedValue.descriptors[question.wrappedValue.selectedNumber - 1]) // Modified line
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
    
    
    func sendToModel() {
        var questionnaireAnswers = [String: Int]()
        for question in questions {
            questionnaireAnswers[question.peak_tackled] = question.selectedNumber
        }
        
        
    }
    
    func callModel() {
        guard let currentUserID = viewModel.currentUser?.id else {
            print("User ID not found.")
            return
        }
        
        guard let url = URL(string: "http://35.188.88.124/api/tasks") else {
            print("Invalid URL.")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "user_id": currentUserID
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error calling model: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                print("Model called successfully.")
            } else {
                print("Error calling model: \(response?.description ?? "Unknown error")")
            }
        }.resume()
        
        
    }
    
    
    func sendToFirebase() {
        guard let currentUserID = viewModel.currentUser?.id else {
            print("User ID not found.")
            return
        }
        
        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(currentUserID)
        let questionnaireAnswersDocRef = db.collection("questionnaire_answers").document(currentUserID)
        
        var questionnaireAnswers = [String: Int]()
        for question in questions {
            questionnaireAnswers[question.peak_tackled] = question.selectedNumber
        }
            // Save questionnaire answers
        questionnaireAnswersDocRef.setData(questionnaireAnswers) { error in
            if let error = error {
                print("Error saving questionnaire answers: \(error.localizedDescription)")
            } //else {
                //print("Questionnaire answers saved successfully.")
           // }
        }
        
        
        // Update hasCompletedInitialQuiz field
        userDocRef.updateData(["hasCompletedInitialQuiz": true]) { error in
            if let error = error {
                print("Error updating hasCompletedInitialQuiz: \(error.localizedDescription)")
            } else {
                print("hasCompletedInitialQuiz updated successfully.")
            }
        }
        Task {
            await viewModel.fetchUser()
        }
        
        //callModel()
        
    }
}

struct QuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        // Example questions
        let exampleQuestions = [
            Question(id: UUID(), question: "How often would you say you feel anxious?", selectedNumber: 1, peak_tackled: "Anxiety", descriptors: [
                "Severe anxiety very often",
                "Frequent anxiety difficult to manage",
                "Regular anxiety at a manageable level",
                "Noticeable but non problematic",
                "Very minimal anxiety, if any"]),
            Question(id: UUID(), question: "How would you describe your current mental health?", selectedNumber: 1, peak_tackled: "Current Mental State", descriptors: [
                "Very negative",
                "Somewhat negative baseline headspace",
                "Neither positive nor negative headspace",
                "Somewhat positive baseline headspace",
                "Very positive"
            ]),
            Question(id: UUID(), question: "How often do you practice self-care activities?", selectedNumber: 1, peak_tackled: "Current Mental State", descriptors: [
                "Poor, rare self care",
                "Occasional self care (once in a while)",
                "Mediocre, sporadic self care",
                "Somewhat regular self care, a few times a weeke",
                "Excellent, regular self care"
            ]),
            Question(id: UUID(), question: "Do you feel like you have a strong support system?", selectedNumber: 1, peak_tackled: "Support Systems", descriptors: [
                "No, I don't feel like I have a strong support system",
                "Not very effective, but there",
                "Decent, sometimes there as expected",
                "Good, usually there when needed",
                "Yes, I have a strong support system"
            ]),

            Question(id: UUID(), question: "How many days do you feel stressed on a weekly basis?", selectedNumber: 1, peak_tackled: "Stress", descriptors: [
                "One Day or Less",
                "Two Days",
                "Three Days",
                "Four Days",
                "Five+ Days"
            ]),

            Question(id: UUID(), question: "How would you describe your eating habits?", selectedNumber: 1, peak_tackled: "Eating", descriptors: [
                "Severe Inconsistent Eating",
                "Regular struggles at meal times",
                "Inconsistent eating tendencies on a daily basis",
                "Occasional struggles with over/under eating",
                "Perfectly Normal"
            ]),
        ]
        
        // Initializing QuestionsView with example questions and a dummy onFinish function
        QuestionsView(questions: exampleQuestions)
    }
}
