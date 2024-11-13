import SwiftUI
import UIKit
// Custom TextView with toolbar and clear background for Done button
struct TextViewToolbar6: UIViewRepresentable {
    @Binding var text: String
    @FocusState var isTextEditorFocused: Bool
    var onTap: () -> Void
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextViewToolbar6
        init(_ parent: TextViewToolbar6) {
            self.parent = parent
        }
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.onTap() // Notify when editing begins
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
        textView.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 12, right: 16) // Adjust padding inside the box
        textView.textContainer.lineBreakMode = .byWordWrapping // Ensure text wraps within the box
        textView.text = text // Set initial text
        textView.textColor = UIColor(named: "PinkTextColor")
        return textView
    }
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.textColor = UIColor(named: "PinkTextColor")
    }
}
// Updated P3_6_1 view with Done toolbar added to TextEditor
struct P3_6_1: View {
    var closeAction: (String) -> Void
    @State private var userInput: String = ""
    @FocusState private var isTextEditorFocused: Bool
    @State private var isTyping: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var navigateToQuizIntro = false // State for navigation
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // background image
                Image("PinkNewBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 8) {
                    Spacer()
                        .frame(height: (isTextEditorFocused || isTyping) ? 100 : 10)
                    // question header
                    Text("Wellness Question")
                        .font(.custom("SFProText-Bold", size: (isTextEditorFocused || isTyping) ? 12 : 18))
                        .foregroundColor(Color("PinkTitleColor"))
                        .padding(.top, (isTextEditorFocused || isTyping) ? -44 : 10)
                        .animation(.easeInOut(duration: 0.3), value: isTyping)
                        .animation(.easeInOut(duration: 0.3), value: isTextEditorFocused)
                    // question text
                    Text("What emotions usually show up when you're feeling anxious?")
                        .font(.custom("SFProText-Heavy", size: (isTextEditorFocused || isTyping) ? 12 : 27))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("PinkQuestionColor"))
                        .lineLimit(nil)
                        .padding(.top, (isTextEditorFocused || isTyping) ? -30 : 0)
                        .padding(.horizontal, 20)
                        .shadow(color: Color.white.opacity(1), radius: 10, x: 0, y: 0) // light glow around the text
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
                        // textEditor for user input with toolbar
                        TextViewToolbar6(text: $userInput, isTextEditorFocused: _isTextEditorFocused) {
                            isTextEditorFocused = true
                        }
                        .frame(height: 200)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("PinkBoxGradientColor1"), Color("PinkBoxGradientColor2")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .cornerRadius(10)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("PinkBorderColor"), lineWidth: 3.5)
                        )
                        // character counter inside the text box
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text("\(userInput.count)/250")
                                    .font(.custom("SFProText-Bold", size: 12))
                                    .foregroundColor(Color("PinkTextColor"))
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
                        closeAction("")
                    }) {
                        Text("Submit")
                            .font(.custom("SFProText-Bold", size: 20))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PinkButtonGradientColor2"), Color("PinkButtonGradientColor1")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: userInput.isEmpty ? Color.clear : Color.white.opacity(1), radius: 10, x: 0, y: 0) // light glow when input is not empty
                    }
                    .disabled(userInput.isEmpty) // Disable the button when there is no input
                    .padding(.bottom, 50)
                    // Navigation to P3QuizIntroView
                    NavigationLink(destination: P3QuizIntro(), isActive: $navigateToQuizIntro) {
                        EmptyView()
                    }
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
