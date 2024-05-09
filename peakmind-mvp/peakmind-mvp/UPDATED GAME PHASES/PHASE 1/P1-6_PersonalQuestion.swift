//
//  P1-6_PersonalQuestion.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 4/21/24.
//

import SwiftUI
import FirebaseFirestore

// Screen five - level 2
struct P1_6_PersonalQuestion: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var userAnswer: String = ""
    @State private var showThankYou = false
    @State var navigateToNext = false
    var closeAction: () -> Void

    var body: some View {
        ZStack {
            // Background
            Image("MainBG")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            // Content
            VStack {
                // Title
                Text("Mt. Anxiety: Phase One")
                    .modernTitleStyle()

                Spacer()

                if !showThankYou {
                    // Question Box
                    ReflectiveQuestionBox4(userAnswer: $userAnswer)
                    
                    // Submit Button
                    SubmitButton {
                        Task {
                            try await saveDataToFirebase()
                        }
                        withAnimation {
                            showThankYou.toggle()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                //navigateToNext.toggle()
                                closeAction()
                             }
                        }
                    }
                } else {
                    // Thank You Message
                    ThankYouMessage()
                }

                Spacer()

                // Sherpa Image and Prompt
                TruthfulPrompt()
            }
            .padding()
            .background(
                NavigationLink(destination: L2SherpaChatView().navigationBarBackButtonHidden(true).environmentObject(viewModel), isActive: $navigateToNext) {
                    EmptyView()
                })
        }
    }
    
    func saveDataToFirebase() async throws {
        guard let user = viewModel.currentUser else {
            print("No authenticated user found.")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("anxiety_peak").document(user.id).collection("Level_Two").document("Screen_Five")

        let data: [String: Any] = [
            "question": "What do you like to do in your free time?",
            "userAnswer": userAnswer,
            "timeCompleted": FieldValue.serverTimestamp()
        ]

        userRef.setData(data) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
            }
        }
    }
}

struct ReflectiveQuestionBox4: View {
    @Binding var userAnswer: String

    var body: some View {
        VStack(spacing: 10) {
            // Question Header
            Text("Wellness Question")
                .modernTextStyle()
            
            // Question Text
            Text("What do you like to do in your free time?")
                .font(.title3)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                        TextEditor(text: $userAnswer)
                .padding(10)
                .frame(height: 180)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 10)
                .padding(.horizontal, 20)
                .padding(.bottom, 25)

        }
        .background(Color("SentMessage"))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
}

//
//struct P1_6_PersonalQuestion_Preview: PreviewProvider {
//    static var previews: some View {
//        P1_6_PersonalQuestion().environmentObject(AuthViewModel())
//    }
//}

