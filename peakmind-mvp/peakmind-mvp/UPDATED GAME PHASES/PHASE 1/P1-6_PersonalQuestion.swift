import SwiftUI
import FirebaseFirestore

// Screen five - level 2
struct P1_6_PersonalQuestion: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var userAnswer: String = ""
    @State private var showThankYou = false
    @State private var showErrorMessage = false
    @State private var errorMessage: String = ""
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
                    
                    // Error Message
                    if showErrorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }

                    // Submit Button
                    SubmitButton {
                        if userAnswer.isEmpty {
                            withAnimation {
                                showErrorMessage = true
                                errorMessage = "Please provide an answer to the question."
                            }
                        } else {
                            Task {
                                do {
                                    try await saveDataToFirebase()
                                    withAnimation {
                                        showThankYou.toggle()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            closeAction()
                                        }
                                    }
                                } catch {
                                    withAnimation {
                                        showErrorMessage = true
                                        errorMessage = "Failed to save data. Please try again."
                                    }
                                }
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
        let userRef = db.collection("anxiety_peak").document(user.id ?? "").collection("Level_Two").document("Screen_Five")

        let data: [String: Any] = [
            "question": "What do you like to do in your free time?",
            "userAnswer": userAnswer,
            "timeCompleted": FieldValue.serverTimestamp()
        ]

        try await userRef.setData(data)
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
            
            // Text Editor
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
