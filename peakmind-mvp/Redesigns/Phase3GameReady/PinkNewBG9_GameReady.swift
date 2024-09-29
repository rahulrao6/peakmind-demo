//
//  PinkNewBG9.swift
//  peakmind-mvp
//
//  Created by ZA on 9/24/24.
//

import SwiftUI

struct P3_9_1: View {
    var closeAction: () -> Void
    @State private var firstCause: String = ""
    @State private var firstEffect: String = ""
    @State private var secondCause: String = ""
    @State private var secondEffect: String = ""
    @State private var navigateToNextScreen = false
    @State private var isKeyboardVisible: Bool = false // track keyboard visibility
    @State private var currentIndex: Int = 0
    @State private var visibleText: String = ""
    @State private var isTypingCompleted: Bool = false
    @State private var focusedField: String? = nil // track which field is focused
    
    let introText = """
    Time to level up our routines! Let's dive into ways we can be more mindful and cultivate greater happiness.
    
    Let's reflect on your anxiety coping toolbox. What's one go-to strategy you currently use? Is there a specific way you manage anxiety right now? How could we tweak it for even better results?
    
    Think of a current practice you have related to anxiety? What could you change this practice to for bettering your coping. Fill them in the boxes below.
    """
    
    var areAllTextFieldsFilled: Bool {
        return !firstCause.isEmpty && !firstEffect.isEmpty && !secondCause.isEmpty && !secondEffect.isEmpty
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // background image
                Image("PinkNewBG")
                    .resizable()
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 36) {
                    Spacer().frame(height: 10)
                    
                    // title section
                    Text("Self Care Practice")
                        .font(.custom("SFProText-Bold", size: 28))
                        .foregroundColor(Color("PinkTitleColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    // typing intro text inside a box
                    ZStack(alignment: .topLeading) {
                        // gradient background box
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PinkBoxGradientColor1"), Color("PinkBoxGradientColor2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color("PinkBorderColor"), lineWidth: 3.5)
                            )
                        
                        // typing text animation with auto-scroll
                        ScrollViewReader { proxy in
                            ScrollView {
                                Text(visibleText)
                                    .font(.custom("SFProText-Medium", size: 16))
                                    .foregroundColor(Color("PinkTextColor"))
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
                    .frame(height: geometry.size.height * 0.3) // set a fixed height for the text box
                    .padding(.horizontal, 20)
                    
                    // input boxes for causes and effects arranged side by side
                    VStack(spacing: 12) {
                        // first pair of cause and effect boxes
                        HStack(spacing: 12) {
                            ThoughtTextEditor(
                                text: $firstCause,
                                placeholder: " Current Practice",
                                isFocused: focusedField == "firstCause" && isKeyboardVisible,
                                onTap: { focusedField = "firstCause" }
                            )
                            ThoughtTextEditor(
                                text: $firstEffect,
                                placeholder: " New Practice",
                                isFocused: focusedField == "firstEffect" && isKeyboardVisible,
                                onTap: { focusedField = "firstEffect" }
                            )
                        }
                        
                        // second pair of cause and effect boxes
                        HStack(spacing: 12) {
                            ThoughtTextEditor(
                                text: $secondCause,
                                placeholder: " Current Practice",
                                isFocused: focusedField == "secondCause" && isKeyboardVisible,
                                onTap: { focusedField = "secondCause" }
                            )
                            ThoughtTextEditor(
                                text: $secondEffect,
                                placeholder: " New Practice",
                                isFocused: focusedField == "secondEffect" && isKeyboardVisible,
                                onTap: { focusedField = "secondEffect" }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // continue button for next screen
                    Button(action: {
                        closeAction()
                    }) {
                        Text("Continue")
                            .font(.custom("SFProText-Bold", size: 20))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PinkButtonGradientColor1"), Color("PinkButtonGradientColor2")]),
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
                            destination: P3EmotionalPageView(), // replace with your next screen view
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
