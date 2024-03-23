import SwiftUI

// Ensure to have a VisualEffectBlur view defined or use a suitable alternative
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

struct Module2View: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var userAnswer: String = ""
    @State private var showThankYou = false

    var body: some View {
        ZStack {
            // Background
            Image("ChatBG2")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            // Content
            VStack {
                // Title
                Text("Mt. Anxiety Level One")
                    .modernTitleStyle()

                Spacer()

                if !showThankYou {
                    // Question Box
                    ReflectiveQuestionBox(userAnswer: $userAnswer)
                    
                    // Submit Button
                    SubmitButton {
                        withAnimation {
                            showThankYou.toggle()
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
        }
    }
}

struct ReflectiveQuestionBox: View {
    @Binding var userAnswer: String

    var body: some View {
        VStack(spacing: 10) {
            // Question Header
            Text("Reflective Question")
                .modernTextStyle()
            
            // Question Text
            Text("What does anxiety feel like for you?")
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

struct SubmitButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Submit")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(15)
                .shadow(radius: 5)
        }
        .padding(.horizontal)
        .transition(.scale)
    }
}

struct ThankYouMessage: View {
    var body: some View {
        Text("Thank You!")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .scaleEffect(1.5)
            .opacity(1.0)
            .transition(.opacity.combined(with: .scale))
    }
}

struct TruthfulPrompt: View {
    var body: some View {
        HStack {
            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(width: 120)
            
            Text("Please answer truthfully.")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue.opacity(0.85))
                .cornerRadius(10)
                .shadow(radius: 5)
        }
    }
}

extension Text {
    func modernTextStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.85))
            .cornerRadius(10)
            .shadow(radius: 5)
    }
    
    func modernTitleStyle() -> some View {
        self
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .shadow(radius: 10)
            .padding()
    }
}

struct Module2View_Previews: PreviewProvider {
    static var previews: some View {
        Module2View().environmentObject(AuthViewModel())
    }
}
