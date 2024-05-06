import SwiftUI

struct FeedbackFormView: View {
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
                Text("PeakMind")
                    .modernTitleStyle()

                Spacer()

                if !showThankYou {
                    // Feedback Form Box
                    FeedbackBox(userAnswer: $userAnswer)
                    
                    // Submit Button
                    SubmitButton {
                        Task {

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
                NavigationLink(destination: L2SherpaChatView().navigationBarBackButtonHidden(true), isActive: $navigateToNext) {
                    EmptyView()
                })
        }
    }
}

struct FeedbackBox: View {
    @Binding var userAnswer: String

    var body: some View {
        VStack(spacing: 10) {
            // Question Header
            Text("Feedback Form")
                .modernTextStyle()
            
            // Feedback Question
            Text("Please enter any feedback you have for our app below!")
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

struct FeedbackFormView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackFormView()
    }
}

struct SubmitButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
