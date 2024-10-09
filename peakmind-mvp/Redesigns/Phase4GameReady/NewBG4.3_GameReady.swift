//
//  NewBG4.3.swift
//  peakmind-mvp
//
//  Created by ZA on 9/24/24.
//

import SwiftUI

// Custom TextView with toolbar and clear background for Done button
struct TextViewToolbar13: UIViewRepresentable {
    @Binding var text: String
    @Binding var isTextEditorFocused: Bool
    var onTap: () -> Void

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextViewToolbar13

        init(_ parent: TextViewToolbar13) {
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

struct P4_4_4: View {
    var closeAction: (String) -> Void
    @State private var textInputs: [String] = Array(repeating: "", count: 3) // State to store text for the 3 text fields
    @State private var isButtonEnabled: Bool = false // Control the button's glow and action
    @State private var navigateToNextScreen = false // Navigation state
    @State private var keyboardHeight: CGFloat = 0 // Track keyboard height
    @State private var focusedFieldStates: [Bool] = Array(repeating: false, count: 3) // Track focus for each field

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("NewBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) { // Adjusted spacing for better visibility
                    Spacer().frame(height: focusedFieldStates.contains(true) ? 10 : 50) // Adjust spacing when keyboard is up
                    
                    // Dynamically resize prompt text when keyboard is up
                    Text("Now, what are three things you can hear?")
                        .font(.custom("SFProText-Bold", size: focusedFieldStates.contains(true) ? 10 : 24)) // Shrinks font size when keyboard is up
                        .foregroundColor(Color("QuestionHeaderColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                        .animation(.easeInOut(duration: 0.3), value: focusedFieldStates) // Smooth font size transition
                    
                    // Non-scrollable Text Fields using TextViewToolbar11
                    VStack(spacing: 12) {
                        ForEach(0..<3, id: \.self) { index in // Changed to 3 text fields
                            ZStack(alignment: .leading) {
                                if textInputs[index].isEmpty {
                                    Text("\(index + 1)") // Placeholder with numbering
                                        .foregroundColor(Color.gray.opacity(0.5))
                                        .padding(.leading, 16)
                                }

                                // Custom TextViewToolbar for multi-line input
                                TextViewToolbar13(text: $textInputs[index], isTextEditorFocused: $focusedFieldStates[index]) {
                                    focusedFieldStates[index] = true
                                }
                                .frame(height: 50) // Static height for the text fields
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
                                .onChange(of: textInputs[index]) { _ in
                                    checkTextFields() // Update button state when input changes
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Next button with conditional glow
                    Button(action: {
                        navigateToNextScreen = true // Action when the button is pressed
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
                    .disabled(!isButtonEnabled) // Disable the button until all text fields are filled
                    .padding(.bottom, 100)
                    .fullScreenCover(isPresented: $navigateToNextScreen) {
                        P4_4_5(closeAction: closeAction)
                    }
                }
                .padding(.horizontal)
                .onAppear {
                    setupKeyboardObservers() // Observe keyboard changes
                }
            }
        }
    }
    
    // Function to check if all text fields are filled
    private func checkTextFields() {
        isButtonEnabled = textInputs.allSatisfy { !$0.isEmpty }
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
