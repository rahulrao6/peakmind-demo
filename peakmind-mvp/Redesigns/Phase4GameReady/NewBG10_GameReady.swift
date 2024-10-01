//
//  NewBG10.swift
//  peakmind-mvp
//
//  Created by ZA on 9/24/24.
//

import SwiftUI

struct P4_WQ3: View {
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
                Image("NewBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 8) {
                    Spacer()
                        .frame(height: (isTextEditorFocused || isTyping) ? 100 : 10)
                    
                    // question header
                    Text("Wellness Question")
                        .font(.custom("SFProText-Bold", size: (isTextEditorFocused || isTyping) ? 12 : 18))
                        .foregroundColor(Color("QuestionHeaderColor"))
                        .padding(.top, (isTextEditorFocused || isTyping) ? -44 : 10)
                        .animation(.easeInOut(duration: 0.3), value: isTyping)
                        .animation(.easeInOut(duration: 0.3), value: isTextEditorFocused)
                    
                    // question text
                    Text("When could you best use a short daily wellness routine in your daily life?")
                        .font(.custom("SFProText-Heavy", size: (isTextEditorFocused || isTyping) ? 12 : 27))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("QuestionColor"))
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
                        
                        // textEditor for user input
                        TextEditor(text: $userInput)
                            .font(.custom("SFProText-Bold", size: 16))
                            .foregroundColor(Color("TextInsideBoxColor"))
                            .focused($isTextEditorFocused)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(height: 200, alignment: .topLeading)
                            .background(Color.clear) // Make the background clear
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
                            .onChange(of: userInput) { newValue in
                                withAnimation {
                                    isTyping = !userInput.isEmpty
                                }
                                // Enforce character limit
                                if newValue.count > 250 {
                                    userInput = String(newValue.prefix(250))
                                }
                            }
                            .onSubmit {
                                isTextEditorFocused = false // dismiss the keyboard
                            }
                        
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
                        closeAction("")
                    }) {
                        Text("Submit")
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
                            .shadow(color: userInput.isEmpty ? Color.clear : Color.white.opacity(1), radius: 10, x: 0, y: 0) // light glow when input is not empty
                    }
                    .disabled(userInput.isEmpty) // Disable the button when there is no input
                    .padding(.bottom, 50)
                    
                    // Navigation to P4IntroView. Just a placehodler for now since it's the last screen on this phase.
                    NavigationLink(destination: P4IntroView(), isActive: $navigateToQuizIntro) {
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

