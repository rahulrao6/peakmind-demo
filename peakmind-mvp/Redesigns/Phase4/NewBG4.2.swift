//
//  NewBG4.2.swift
//  peakmind-mvp
//
//  Created by ZA on 9/24/24.
//

import SwiftUI

struct CopingMechanism2: View {
    @State private var textInputs: [String] = Array(repeating: "", count: 4) // State to store text for the 4 text fields
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
                    Text("Next, what are four things you can touch around you?")
                        .font(.custom("SFProText-Bold", size: isTextFieldFocused ? 10 : 24)) // Shrinks font size when keyboard is up
                        .foregroundColor(Color("QuestionHeaderColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                        .animation(.easeInOut(duration: 0.3), value: isTextFieldFocused) // Smooth font size transition
                    
                    // Scrollable Text fields
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(0..<4, id: \.self) { index in // Changed to 4 text fields
                                TextEditor(text: $textInputs[index]) // Multiple line input
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
                                            if textInputs[index].isEmpty {
                                                Text("\(index + 1)") // Placeholder with numbering
                                                    .foregroundColor(Color.gray.opacity(0.5))
                                                    .padding(.horizontal, 18)
                                                    .padding(.vertical, 12)
                                                    .frame(maxWidth: .infinity, alignment: .topLeading) // Place the placeholder at the top-left
                                            }
                                        }
                                    )
                                    .onChange(of: textInputs) { _ in
                                        checkTextFields() // Check if all text fields are filled
                                    }
                                    .focused($isTextFieldFocused) // Track focus
                                    .onSubmit {
                                        isTextFieldFocused = false // Dismiss the keyboard on return
                                    }
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
                    .disabled(!isButtonEnabled) // Disable the button until all text fields are filled
                    .padding(.bottom, 100)
                    .background(
                        NavigationLink(destination: CopingMechanism3(), isActive: $navigateToNextScreen) {
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

struct CopingMechanism2_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CopingMechanism2()
        }
    }
}

