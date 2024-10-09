//
//  NewBG4.5.swift
//  peakmind-mvp
//
//  Created by ZA on 9/24/24.
//

import SwiftUI

// Custom TextView with toolbar and clear background for Done button
struct TextViewToolbar15: UIViewRepresentable {
    @Binding var text: String
    @Binding var isTextEditorFocused: Bool
    var onTap: () -> Void

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextViewToolbar15

        init(_ parent: TextViewToolbar15) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.onTap() // Notify when editing begins
            parent.isTextEditorFocused = true // Set focus state to true
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            parent.isTextEditorFocused = false // Set focus state to false
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
        textView.textColor = UIColor(named: "TextInsideBoxColor")

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.textColor = UIColor(named: "TextInsideBoxColor")
    }
}

struct P4_4_6: View {
    var closeAction: (String) -> Void
    @State private var textInput: String = "" // State to store text for the single text field
    @State private var isButtonEnabled: Bool = false // Control the button's glow and action
    @State private var navigateToNextScreen = false // Navigation state
    @State private var keyboardHeight: CGFloat = 0 // Track keyboard height
    @State private var isTextFieldFocused: Bool = false // Track text field focus

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("NewBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) { // Adjusted spacing for better visibility
                    Spacer().frame(height: isTextFieldFocused ? 10 : 50) // Adjust spacing when keyboard is up
                    
                    // Dynamically resize prompt text when keyboard is up
                    Text("Finally, what is one thing you can taste?")
                        .font(.custom("SFProText-Bold", size: isTextFieldFocused ? 10 : 24)) // Shrinks font size when keyboard is up
                        .foregroundColor(Color("QuestionHeaderColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                        .animation(.easeInOut(duration: 0.3), value: isTextFieldFocused) // Smooth font size transition
                    
                    // Single text field using TextViewToolbar11
                    ZStack(alignment: .leading) {
                        if textInput.isEmpty {
                            Text("1") // Placeholder numbering for one text field
                                .foregroundColor(Color.gray.opacity(0.5))
                                .padding(.leading, 16)
                        }

                        // Custom TextViewToolbar for multi-line input
                        TextViewToolbar15(text: $textInput, isTextEditorFocused: $isTextFieldFocused) {
                            isTextFieldFocused = true
                        }
                        .frame(height: 50) // Static height for the text field
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("BoxGradient1"), Color("BoxGradient2")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .cornerRadius(10)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("BoxStrokeColor"), lineWidth: 3.5)
                        )
                        .onChange(of: textInput) { _ in
                            checkTextField() // Update button state when input changes
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Next button with conditional glow
                    Button(action: {
                        closeAction("")
                    }) {
                        Text("Next")
                            .font(.custom("SFProText-Bold", size: 20))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("ButtonGradient1"), Color("ButtonGradient2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: isButtonEnabled ? Color.white.opacity(1) : Color.clear, radius: 10, x: 0, y: 0) // Conditional glow
                    }
                    .disabled(!isButtonEnabled) // Disable the button until the text field is filled
                    .padding(.bottom, 100)
                }
                .padding(.horizontal)
                .onAppear {
                    setupKeyboardObservers() // Observe keyboard changes
                }
            }
        }
    }
    
    // Function to check if the text field is filled
    private func checkTextField() {
        isButtonEnabled = !textInput.isEmpty
    }
    
    // Setup keyboard observer to detect when the keyboard is shown/hidden
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation {
                    keyboardHeight = keyboardFrame.height
                }
            }
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation {
                keyboardHeight = 0
            }
        }
    }
}
