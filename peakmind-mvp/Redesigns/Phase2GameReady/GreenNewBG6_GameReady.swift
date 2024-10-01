//
//  GreenNewBG6.swift
//  peakmind-mvp
//
//  Created by ZA on 9/18/24.
//

import SwiftUI

struct P2_6_1: View {
    var closeAction: (String) -> Void
    @State private var goalText: String = ""
    @State private var showGoalInput = false
    @State private var visibleText: String = ""
    @State private var currentCharIndex = 0
    @State private var typingComplete = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var navigateToNextView = false // State to trigger navigation
    
    // Intro text that types itself out
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
                        
                        // Typing text animation starting from the top left
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
                        // Goal Input Box
                        ZStack(alignment: .topLeading) {
                            // Placeholder text for the input box
                            if goalText.isEmpty {
                                Text("Type your goal here...")
                                    .foregroundColor(Color.gray.opacity(0.5))
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                    .zIndex(1)
                            }
                            
                            TextEditor(text: $goalText)
                                .font(.custom("SFProText-Medium", size: 16))
                                .foregroundColor(Color("GreenTextColor"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(height: 150)
                                .background(Color.clear)
                                .scrollContentBackground(.hidden)
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
    
    // Typing animation function
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
    
    // Action for continue button
    func submitGoal() {
        print("Goal submitted: \(goalText)")
        closeAction("")
    }
    
    // Keyboard notification handlers
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
