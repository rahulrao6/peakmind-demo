//
//  LightPurpleNewBG7.swift
//  peakmind-mvp
//
//  Created by ZA on 10/1/24.
//

import SwiftUI

struct P5CommunityView: View {
    @State private var firstCause: String = ""
    @State private var firstEffect: String = ""
    @State private var secondCause: String = ""
    @State private var secondEffect: String = ""
    @State private var thirdCause: String = ""
    @State private var thirdEffect: String = ""
    @State private var navigateToNextScreen = false
    @State private var isKeyboardVisible: Bool = false // track keyboard visibility
    @State private var currentIndex: Int = 0
    @State private var visibleText: String = ""
    @State private var isTypingCompleted: Bool = false
    @State private var focusedField: String? = nil // track which field is focused
    
    let introText = """
    Let’s find a community that is right for you!
    
    Write down 3 activities you typically enjoy. Then write three different communities related to those activities for you to get involved with. You’re not alone!
    """
    
    var areAllTextFieldsFilled: Bool {
        return !firstCause.isEmpty && !firstEffect.isEmpty && !secondCause.isEmpty && !secondEffect.isEmpty && !thirdCause.isEmpty && !thirdEffect.isEmpty
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("LightPurpleNewBG")
                    .resizable()
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 24) {
                    Spacer().frame(height: 10)
                    
                    // Title section
                    Text("Communities")
                        .font(.custom("SFProText-Bold", size: 28))
                        .foregroundColor(Color("LightPurpleTitleColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    // Typing intro text inside a box
                    ZStack(alignment: .topLeading) {
                        // Gradient background box
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("LightPurpleBoxGradientColor1"), Color("LightPurpleBoxGradientColor2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color("LightPurpleBorderColor"), lineWidth: 3.5)
                            )
                        
                        // Typing text animation with auto-scroll
                        ScrollViewReader { proxy in
                            ScrollView {
                                Text(visibleText)
                                    .font(.custom("SFProText-Medium", size: 16))
                                    .foregroundColor(Color("LightPurpleTextColor"))
                                    .multilineTextAlignment(.leading)
                                    .padding(20)
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                    .onChange(of: visibleText) { _ in
                                        withAnimation {
                                            proxy.scrollTo("end", anchor: .bottom)
                                        }
                                    }
                                Color.clear.frame(height: 1).id("end")
                            }
                        }
                        .onAppear {
                            typeText()
                        }
                    }
                    .frame(height: geometry.size.height * 0.15) // Reduced height for the text box
                    .padding(.horizontal, 20)
                    
                    // Input boxes for causes and effects arranged in three rows, moved up
                    VStack(spacing: 12) {
                        // First row of cause and effect boxes
                        HStack(spacing: 12) {
                            ThoughtTextEditor(
                                text: $firstCause,
                                placeholder: " Activity",
                                isFocused: focusedField == "firstCause" && isKeyboardVisible,
                                onTap: { focusedField = "firstCause" }
                            )
                            ThoughtTextEditor(
                                text: $firstEffect,
                                placeholder: " Related Community",
                                isFocused: focusedField == "firstEffect" && isKeyboardVisible,
                                onTap: { focusedField = "firstEffect" }
                            )
                        }
                        
                        // Second row of cause and effect boxes
                        HStack(spacing: 12) {
                            ThoughtTextEditor(
                                text: $secondCause,
                                placeholder: " Activity",
                                isFocused: focusedField == "secondCause" && isKeyboardVisible,
                                onTap: { focusedField = "secondCause" }
                            )
                            ThoughtTextEditor(
                                text: $secondEffect,
                                placeholder: " Related Community",
                                isFocused: focusedField == "secondEffect" && isKeyboardVisible,
                                onTap: { focusedField = "secondEffect" }
                            )
                        }
                        
                        // Third row of cause and effect boxes
                        HStack(spacing: 12) {
                            ThoughtTextEditor(
                                text: $thirdCause,
                                placeholder: " Activity",
                                isFocused: focusedField == "thirdCause" && isKeyboardVisible,
                                onTap: { focusedField = "thirdCause" }
                            )
                            ThoughtTextEditor(
                                text: $thirdEffect,
                                placeholder: " Related Community",
                                isFocused: focusedField == "thirdEffect" && isKeyboardVisible,
                                onTap: { focusedField = "thirdEffect" }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Continue button for next screen
                    Button(action: {
                        navigateToNextScreen = true
                    }) {
                        Text("Continue")
                            .font(.custom("SFProText-Bold", size: 20))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("LightPurpleButtonGradientColor1"), Color("LightPurpleButtonGradientColor2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: areAllTextFieldsFilled ? Color.white.opacity(1) : Color.clear, radius: 10, x: 0, y: 0)
                    }
                    .padding(.top, 16)
                    .disabled(!areAllTextFieldsFilled)
                    .background(
                        NavigationLink(
                            destination: P5QuizPageView(), // Replace with your next screen view
                            isActive: $navigateToNextScreen,
                            label: { EmptyView() }
                        )
                    )
                    
                    Spacer()
                }
                .padding(.horizontal)
                .onAppear {
                    setupKeyboardObservers()
                }
            }
        }
    }
    
    private func typeText() {
        visibleText = ""
        var charIndex = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            if charIndex < introText.count {
                let index = introText.index(introText.startIndex, offsetBy: charIndex)
                visibleText.append(introText[index])
                charIndex += 1
            } else {
                timer.invalidate()
                isTypingCompleted = true
            }
        }
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            isKeyboardVisible = true
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            isKeyboardVisible = false
        }
    }
}

struct P5CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        P5CommunityView()
    }
}
