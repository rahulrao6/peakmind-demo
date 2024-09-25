//
//  NewBG4.5.swift
//  peakmind-mvp
//
//  Created by ZA on 9/24/24.
//

import SwiftUI

struct CopingMechanism5: View {
    @State private var textInput: String = "" // State to store text for the single text field
    @State private var isButtonEnabled: Bool = false // Control the button's glow and action
    @State private var navigateToNextScreen = false // Navigation state
    @State private var keyboardHeight: CGFloat = 0 // Track keyboard height
    @FocusState private var isTextFieldFocused: Bool // Track text field focus

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
                    
                    // Single text field
                    ScrollView {
                        VStack(spacing: 12) {
                            TextEditor(text: $textInput) // Multiple line input for one field
                                .font(.custom("SFProText-Medium", size: 18))
                                .foregroundColor(Color("TextInsideBoxColor"))
                                .frame(height: 50) // Reduced height for the text editor
                                .padding(.horizontal, 12)
                                .scrollContentBackground(.hidden)
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
                                .overlay(
                                    // Placeholder text overlay
                                    Group {
                                        if textInput.isEmpty {
                                            Text("1") // Placeholder numbering for one text field
                                                .foregroundColor(Color.gray.opacity(0.5))
                                                .padding(.horizontal, 18)
                                                .padding(.vertical, 12)
                                                .frame(maxWidth: .infinity, alignment: .topLeading) // Place the placeholder at the top-left
                                        }
                                    }
                                )
                                .onChange(of: textInput) { _ in
                                    checkTextField() // Check if the text field is filled
                                }
                                .focused($isTextFieldFocused) // Track focus
                                .onSubmit {
                                    isTextFieldFocused = false // Dismiss the keyboard on return
                                }
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(height: geometry.size.height * 0.4) // Adjusted height for the scrollable area
                    
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
                    .disabled(!isButtonEnabled) // Disable the button until the text field is filled
                    .padding(.bottom, 100)
                    .background(
                        NavigationLink(destination: WellnessQuestionView2(), isActive: $navigateToNextScreen) {
                            EmptyView()
                        }
                    )
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

struct CopingMechanism5_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CopingMechanism5()
        }
    }
}

