//Toolbar added
import SwiftUI
import UIKit
// Custom TextView with toolbar and clear background for Done button
struct TextViewWithToolbar2: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    @FocusState var isTextEditorFocused: Bool
    var onTap: () -> Void
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextViewWithToolbar2
        init(_ parent: TextViewWithToolbar2) {
            self.parent = parent
        }
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == parent.placeholder {
                textView.text = ""
                textView.textColor = UIColor(named: "TextInsideBoxColor")
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
        textView.textColor = text.isEmpty ? UIColor.gray.withAlphaComponent(0.5) : UIColor(named: "TextInsideBoxColor")
        if text.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.gray.withAlphaComponent(0.5)
        } else {
            textView.text = text
            textView.textColor = UIColor(named: "TextInsideBoxColor")
        }
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 12, bottom: 12, right: 16) // Adjust padding inside the box
        textView.textContainer.lineBreakMode = .byWordWrapping // Ensure text wraps within the box
        return textView
    }
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.textColor = text.isEmpty ? UIColor.gray.withAlphaComponent(0.5) : UIColor(named: "TextInsideBoxColor")
    }
}
// Updated P9_2 view with Done toolbar and gradient background added to TextEditor
struct P9_2: View {
    var closeAction: (String) -> Void
    @State private var userInput: String = ""
    @FocusState private var isTextEditorFocused: Bool
    @State private var isTyping: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var navigateToBreathingExercise: Bool = false
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // background image
                Image("PurpleNewBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 8) {
                    Spacer()
                        .frame(height: (isTextEditorFocused || isTyping) ? 100 : 10)
                    // question header
                    Text("Wellness Question")
                        .font(.custom("SFProText-Bold", size: (isTextEditorFocused || isTyping) ? 12 : 18))
                        .foregroundColor(Color("PurpleTitleColor"))
                        .padding(.top, (isTextEditorFocused || isTyping) ? -44 : 10)
                        .animation(.easeInOut(duration: 0.3), value: isTyping)
                        .animation(.easeInOut(duration: 0.3), value: isTextEditorFocused)
                    // question text
                    Text("Choose one area of your life—like sleep, exercise, or social connections. What's one small change you could make this week? How might it positively impact you?")
                        .font(.custom("SFProText-Heavy", size: (isTextEditorFocused || isTyping) ? 8 : 24))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("PurpleQuestionColor"))
                        .lineLimit(nil)
                        .padding(.top, (isTextEditorFocused || isTyping) ? -30 : 0)
                        .padding(.horizontal, 20)
                        .shadow(color: Color.white.opacity(0.3), radius: 10, x: 0, y: 0) // light glow around the text
                        .animation(.easeInOut(duration: 0.5), value: isTyping)
                        .animation(.easeInOut(duration: 0.5), value: isTextEditorFocused)
                    // input box
                    ZStack(alignment: .topLeading) {
                        // placeholder text
                        if userInput.isEmpty {
                            Text("Start typing here...")
                                .foregroundColor(Color.gray.opacity(0.5))
                                .padding(.vertical, 14)
                                .padding(.horizontal, 16)
                                .zIndex(1) // ensure it stays on top
                        }
                        // Custom TextViewWithToolbar for user input with gradient background
                        TextViewWithToolbar2(text: $userInput, placeholder: "Start typing here...", isTextEditorFocused: _isTextEditorFocused) {
                            isTextEditorFocused = true
                        }
                        .frame(height: 200)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("PurpleBoxGradientColor1"), Color("PurpleBoxGradientColor2")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .cornerRadius(10)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("PurpleBorderColor"), lineWidth: 3.5)
                        )
                        // character counter inside the text box
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text("\(userInput.count)/250")
                                    .font(.custom("SFProText-Bold", size: 12))
                                    .foregroundColor(Color("TextInsideBoxColor"))
                                    .padding(8)
                                    .background(Color.black.opacity(0.2))
                                    .cornerRadius(8)
                                    .padding(8)
                            }
                        }
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                    Spacer()
                        .frame(height: (isTextEditorFocused || isTyping) ? (keyboardHeight - geometry.safeAreaInsets.bottom) / 2 : 20)
                    // submit button
                    Button(action: {
                        isTextEditorFocused = false
                        closeAction("Choose one area of your life—like sleep, exercise, or social connections. What's one small change you could make this week? How might it positively impact you? " + userInput)
                    }) {
                        Text("Submit")
                            .font(.custom("SFProText-Bold", size: 20))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PurpleButtonGradientColor1"), Color("PurpleButtonGradientColor2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: userInput.isEmpty ? Color.clear : Color.white.opacity(1), radius: 10, x: 0, y: 0) // Conditional glow around the button
                    }
                    .padding(.bottom, 50)
                    .disabled(userInput.isEmpty) // Disable button if no text
                    .opacity(userInput.isEmpty ? 1.0 : 1.0) // Change opacity when disabled
                }
                .padding(.horizontal)
                .onTapGesture {
                    isTextEditorFocused = false
                }
                .onAppear {
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                            withAnimation {
                                keyboardHeight = keyboardFrame.height
                                isTyping = true
                            }
                        }
                    }
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                        withAnimation {
                            isTyping = false
                            keyboardHeight = 0
                        }
                    }
                }
            }
        }
    }
}
struct WellnessQuestionViewPurple_Previews2: PreviewProvider {
    static var previews: some View {
        P9_2(closeAction: { _ in })
    }
}
