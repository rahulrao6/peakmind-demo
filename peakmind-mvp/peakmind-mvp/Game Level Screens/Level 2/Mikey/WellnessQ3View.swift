//
//  WellnessQ2View.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/25/24.
//

import SwiftUI
import FirebaseFirestore

// screen eleven - level 10 
struct WellnessQ3View: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var userAnswer: String = ""
    @State private var showThankYou = false
    @State var navigateToNext = false

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
                Text("Mt. Anxiety Level Two")
                    .modernTitleStyle()

                Spacer()

                if !showThankYou {
                    // Question Box
                    ReflectiveQuestionBox3(userAnswer: $userAnswer)
                    
                    // Submit Button
                    SubmitButton {
                        Task {
                            try await saveDataToFirebase()
                        }
                        withAnimation {
                            showThankYou.toggle()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                navigateToNext.toggle()
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
                NavigationLink(destination: Level2Complete().navigationBarBackButtonHidden(true).environmentObject(viewModel), isActive: $navigateToNext) {
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
        let userRef = db.collection("anxiety_peak").document(user.id).collection("Level_Two").document("Screen_Eleven")

        let data: [String: Any] = [
            "question": "What is typically the best support for calming your anxiety?",
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

struct ReflectiveQuestionBox3: View {
    @Binding var userAnswer: String

    var body: some View {
        VStack(spacing: 10) {
            // Question Header
            Text("Reflective Question")
                .modernTextStyle()
            
            // Question Text
            Text("What is typically the best support for calming your anxiety?")
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

struct WellnessQ3View_Previews: PreviewProvider {
    static var previews: some View {
        WellnessQ3View().environmentObject(AuthViewModel())
    }
}

