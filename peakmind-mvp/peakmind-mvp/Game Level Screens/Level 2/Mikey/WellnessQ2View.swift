//
//  WellnessQ2View.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/25/24.
//

import SwiftUI
import FirebaseFirestore

// Screen five - level 2 
struct WellnessQ2View: View {
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
                    ReflectiveQuestionBox2(userAnswer: $userAnswer)
                    
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
            "question": "What are the main sources of anxiety in your life?",
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

struct ReflectiveQuestionBox2: View {
    @Binding var userAnswer: String

    var body: some View {
        VStack(spacing: 10) {
            // Question Header
            Text("Reflective Question")
                .modernTextStyle()
            
            // Updated Question Text
            Text("What are the main sources of anxiety in your life?")
                .font(.title2)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.vertical, 10)
            
            // Answer TextField
            TextField("Enter text here", text: $userAnswer)
                .padding(.all, 20)
                .frame(height: 150)
                .background(Color.white.opacity(0.8))
                .cornerRadius(15)
                .shadow(radius: 10)
                .padding(.horizontal)
        }
        .background(VisualEffectBlur(blurStyle: .systemMaterialDark))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()

    }
}

// Other struct definitions (SubmitButton, ThankYouMessage, TruthfulPrompt, and Text extensions) remain unchanged...

struct WellnessQ2View_Previews: PreviewProvider {
    static var previews: some View {
        WellnessQ2View().environmentObject(AuthViewModel())
    }
}

