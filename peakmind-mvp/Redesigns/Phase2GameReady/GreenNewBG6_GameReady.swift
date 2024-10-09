//toolbar
import SwiftUI
import UIKit
// Custom TextView with toolbar and clear background for Done button
struct TextViewToolbar: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var onTap: () -> Void
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextViewToolbar
        init(_ parent: TextViewToolbar) {
            self.parent = parent
        }
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == parent.placeholder {
                textView.text = ""
                textView.textColor = UIColor(named: "GreenTextColor")
            }
            parent.onTap() // Notify when editing begins to set the focused field
        }
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = UIColor.gray.withAlphaComponent(0.5)
            }
        }
        @objc func doneButtonTapped() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        // Add the toolbar with Done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: context.coordinator, action: #selector(Coordinator.doneButtonTapped))
        toolbar.items = [flexibleSpace, doneButton]
        textView.inputAccessoryView = toolbar
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .clear // Make the background clear
        textView.textColor = text.isEmpty ? UIColor.gray.withAlphaComponent(0.5) : UIColor(named: "GreenTextColor")
        if text.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.gray.withAlphaComponent(0.5)
        } else {
            textView.text = text
            textView.textColor = UIColor(named: "GreenTextColor")
        }
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16) // Adjust padding inside the box
        textView.textContainer.lineBreakMode = .byWordWrapping // Ensure text wraps within the box
        return textView
    }
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.textColor = text.isEmpty ? UIColor.gray.withAlphaComponent(0.5) : UIColor(named: "GreenTextColor")
    }
}
// Updated P2_6_1 view with Done toolbar added to goal input
struct P2_6_1: View {
    var closeAction: (String) -> Void
    @State private var goalText: String = ""
    @State private var showGoalInput = false
    @State private var visibleText: String = ""
    @State private var currentCharIndex = 0
    @State private var typingComplete = false
    @State private var keyboardHeight: CGFloat = 0
    let introText = """
    Let’s set our first goal to help you stay on track and meet your mental health expectations.
    Setting personal goals for long-term anxiety management is excellent for maintaining accountability and building discipline. Let's create a goal that is both achievable and measurable.
    """
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("GreenNewBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 16) {
                    Spacer()
                        .frame(height: 40)
                    // Title Text
                    Text("Set Your First Goal")
                        .font(.custom("SFProText-Bold", size: 30))
                        .foregroundColor(Color("GreenTitleColor"))
                        .padding(.bottom, 10)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    // Intro Text with typing animation inside a gradient box
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("GreenBoxGradientColor1"), Color("GreenBoxGradientColor2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: geometry.size.height * 0.3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color("GreenBorderColor"), lineWidth: 2.5)
                            )
                        ScrollView {
                            Text(visibleText)
                                .font(.custom("SFProText-Medium", size: 16))
                                .foregroundColor(Color("GreenTextColor"))
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 20)
                                .onAppear {
                                    startTyping()
                                }
                        }
                        .frame(height: geometry.size.height * 0.3)
                        .clipped()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    // Show the goal input and button after typing is complete
                    if typingComplete {
                        // Goal Input Box with Done button toolbar
                        ZStack(alignment: .topLeading) {
                            if goalText.isEmpty {
                                Text("Type your goal here...")
                                    .foregroundColor(Color.gray.opacity(0.5))
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                    .zIndex(1)
                            }
                            TextViewToolbar(text: $goalText, placeholder: "Type your goal here...") {
                                // When user taps to edit goal
                            }
                            .frame(height: 150)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color("GreenBoxGradientColor1"), Color("GreenBoxGradientColor2")]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color("GreenBorderColor"), lineWidth: 2.5)
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, keyboardHeight == 0 ? 20 : keyboardHeight)
                        Spacer()
                        Button(action: {
                            submitGoal()
                        }) {
                            Text("Set Goal")
                                .font(.custom("SFProText-Bold", size: 20))
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color("GreenButtonGradientColor1"), Color("GreenButtonGradientColor2")]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(15)
                                .shadow(color: goalText.isEmpty ? Color.clear : Color.white.opacity(1), radius: 10, x: 0, y: 0)
                        }
                        .disabled(goalText.isEmpty)
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            registerForKeyboardNotifications()
        }
        .onDisappear {
            unregisterForKeyboardNotifications()
        }
    }
    func startTyping() {
        visibleText = ""
        currentCharIndex = 0
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            if currentCharIndex < introText.count {
                let index = introText.index(introText.startIndex, offsetBy: currentCharIndex)
                visibleText.append(introText[index])
                currentCharIndex += 1
            } else {
                timer.invalidate()
                typingComplete = true
            }
        }
    }
    func submitGoal() {
        print("Goal submitted: \(goalText)")
        closeAction("")
    }
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height - 40
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardHeight = 0
        }
    }
    func unregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
struct P2_6_1_Previews: PreviewProvider {
    static var previews: some View {
        P2_6_1(closeAction: { _ in })
    }
}
