//
//  PurpleNewBG5.swift
//  peakmind-mvp
//
//  Created by ZA on 8/27/24.
//


import SwiftUI
import Combine

struct TriggerMappingView: View {
    @State private var currentIndex: Int = 0
    @State private var isIntroTextCompleted: Bool = false
    @State private var showInputBoxes: Bool = false
    @State private var trigger1: String = ""
    @State private var trigger2: String = ""
    @State private var trigger3: String = ""
    @State private var effect1: String = ""
    @State private var effect2: String = ""
    @State private var effect3: String = ""
    @State private var navigateToNextScreen = false
    @State private var selectedField: String? = nil // Track which field is selected
    @State private var isTypingCompleted: Bool = false // Track typing completion
    @State private var isKeyboardVisible: Bool = false // Track keyboard visibility
    
    let introText = [
        "Understanding your triggers is key to managing anxiety. Ever had a project that just sends stress levels skyrocketing? That's what we call a trigger or stressor in the realm of mental health.",
        "Here's a neat strategy to tackle them head-on: trigger mapping.",
        "Write down your top three current stress triggers in the bubbles on the left.",
        "Now, pause for a moment and think about how these triggers are impacting your life.",
        "Let's dive in! Fill these in on the corresponding symptom bubble on the right."
    ]
    
    var areAllTextFieldsFilled: Bool {
        return !trigger1.isEmpty && !trigger2.isEmpty && !trigger3.isEmpty && !effect1.isEmpty && !effect2.isEmpty && !effect3.isEmpty
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // background image
                Image("PurpleNewBG")
                    .resizable()
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 36) {
                    Spacer()
                        .frame(height: 10)
                    
                    // title section
                    Text("Cause and Effect Mapping")
                        .font(.custom("SFProText-Bold", size: 28))
                        .foregroundColor(Color("PurpleTitleColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    // typing intro text inside a box
                    ZStack {
                        // gradient background box
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PurpleBoxGradientColor1"), Color("PurpleBoxGradientColor2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: isKeyboardVisible ? geometry.size.height * 0.15 : geometry.size.height * 0.25) // adjust height when keyboard is visible
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color("PurpleBorderColor"), lineWidth: 3.5)
                            )
                        
                        // scrollable typing text with auto-scroll
                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(0..<currentIndex + 1, id: \.self) { index in
                                        TriggerBulletPoint(text: introText[index], onTypingComplete: {
                                            // text completion handling
                                            isTypingCompleted = true
                                        })
                                        .id(index)
                                    }
                                    Color.clear.frame(height: 1).id("bottom")
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                            }
                            .onChange(of: currentIndex) { _ in
                                withAnimation {
                                    proxy.scrollTo(currentIndex, anchor: .bottom)
                                }
                            }
                        }
                        .frame(height: isKeyboardVisible ? geometry.size.height * 0.15 : geometry.size.height * 0.25) // adjust height when keyboard is visible
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    .padding(.horizontal, 20)
                    
                    // next or Continue Button outside the text box
                    if !isIntroTextCompleted {
                        Button(action: {
                            withAnimation {
                                if currentIndex < introText.count - 1 {
                                    currentIndex += 1
                                    isTypingCompleted = false
                                } else {
                                    isIntroTextCompleted = true
                                    showInputBoxes = true // trigger showing the input boxes immediately
                                }
                            }
                        }) {
                            Text(currentIndex == introText.count - 1 ? "Continue" : "Next")
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
                                .shadow(color: isTypingCompleted ? Color.white.opacity(1) : Color.clear, radius: 10, x: 0, y: 0)
                        }
                        .padding(.top, 16)
                        .disabled(!isTypingCompleted) // disable the button until typing is completed
                    }
                    
                    // input boxes for triggers and effects
                    if showInputBoxes {
                        HStack(spacing: 16) {
                            VStack(spacing: 12) {
                                // trigger text boxes
                                TriggerEffectTextEditor(
                                    text: $trigger1,
                                    placeholder: " Trigger",
                                    isFocused: selectedField == "trigger1" && isKeyboardVisible,
                                    onTap: { selectedField = "trigger1" }
                                )
                                TriggerEffectTextEditor(
                                    text: $trigger2,
                                    placeholder: " Trigger",
                                    isFocused: selectedField == "trigger2" && isKeyboardVisible,
                                    onTap: { selectedField = "trigger2" }
                                )
                                TriggerEffectTextEditor(
                                    text: $trigger3,
                                    placeholder: " Trigger",
                                    isFocused: selectedField == "trigger3" && isKeyboardVisible,
                                    onTap: { selectedField = "trigger3" }
                                )
                            }
                            
                            VStack(spacing: 12) {
                                // effect text boxes
                                TriggerEffectTextEditor(
                                    text: $effect1,
                                    placeholder: " Effect",
                                    isFocused: selectedField == "effect1" && isKeyboardVisible,
                                    onTap: { selectedField = "effect1" }
                                )
                                TriggerEffectTextEditor(
                                    text: $effect2,
                                    placeholder: " Effect",
                                    isFocused: selectedField == "effect2" && isKeyboardVisible,
                                    onTap: { selectedField = "effect2" }
                                )
                                TriggerEffectTextEditor(
                                    text: $effect3,
                                    placeholder: " Effect",
                                    isFocused: selectedField == "effect3" && isKeyboardVisible,
                                    onTap: { selectedField = "effect3" }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // continue button for next screen
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
                                        gradient: Gradient(colors: [Color("PurpleButtonGradientColor1"), Color("PurpleButtonGradientColor2")]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(15)
                                .shadow(color: areAllTextFieldsFilled ? Color.white.opacity(1) : Color.clear, radius: 10, x: 0, y: 0)
                        }
                        .padding(.top, 16)
                        .disabled(!areAllTextFieldsFilled) // disable the button until all fields are filled
                        .background(
                            NavigationLink(
                                destination: ReframeExerciseView(), // replace with your next screen view
                                isActive: $navigateToNextScreen,
                                label: { EmptyView() }
                            )
                        )
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .onAppear {
                    setupKeyboardObservers()
                }
            }
        }
        .onAppear {
            // start typing intro text when the view appears
            currentIndex = 0
            isIntroTextCompleted = false
            showInputBoxes = false
            isTypingCompleted = false
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

struct TriggerBulletPoint: View {
    var text: String
    @State private var visibleText: String = ""
    @State private var charIndex: Int = 0
    var onTypingComplete: () -> Void
    
    var body: some View {
        // feature text with typing animation
        Text(visibleText)
            .font(.custom("SFProText-Medium", size: 16))
            .foregroundColor(Color("PurpleTextColor"))
            .multilineTextAlignment(.leading)
            .onAppear {
                typeText()
            }
    }
    
    private func typeText() {
        visibleText = ""
        charIndex = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            if charIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: charIndex)
                visibleText.append(text[index])
                charIndex += 1
            } else {
                timer.invalidate()
                onTypingComplete()
            }
        }
    }
}

struct TriggerEffectTextEditor: View {
    @Binding var text: String
    var placeholder: String
    var isFocused: Bool
    var onTap: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color("PurpleBoxGradientColor1"), Color("PurpleBoxGradientColor2")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("PurpleBorderColor"), lineWidth: 3.5)
                )
                .frame(height: isFocused ? 90 : 60) // enlarge when focused
            
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color.gray.opacity(0.5))
                    .padding(.leading, 16)
                    .padding(.top, 20) // adjust this value to move the placeholder down
            }
            
            TextEditor(text: $text)
                .scrollContentBackground(.hidden) // makes the background of TextEditor clear
                .foregroundColor(Color("PurpleTextColor")) // Text color
                .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)) // adjust padding
                .frame(height: isFocused ? 90 : 60) // enlarge when focused
                .onTapGesture {
                    onTap()
                }
                .animation(.easeInOut(duration: 0.2), value: isFocused) // smooth animation
        }
    }
}

struct TriggerMappingView_Previews: PreviewProvider {
    static var previews: some View {
        TriggerMappingView()
    }
}



