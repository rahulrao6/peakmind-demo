//
//  LightPurpleNewBG.swift
//  peakmind-mvp
//
//  Created by ZA on 8/19/24.
//

import SwiftUI

struct WellnessQuestionViewLightPurple: View {
    @State private var userInput: String = ""
    @FocusState private var isTextEditorFocused: Bool
    @State private var isTyping: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // background image
                Image("LightPurpleNewBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 8) {
                    Spacer()
                        .frame(height: (isTextEditorFocused || isTyping) ? 100 : 10)
                    
                    // question header
                    Text("Wellness Question")
                        .font(.custom("SFProText-Bold", size: (isTextEditorFocused || isTyping) ? 12 : 18))
                        .foregroundColor(Color("LightPurpleTitleColor"))
                        .padding(.top, (isTextEditorFocused || isTyping) ? -44 : 10)
                        .animation(.easeInOut(duration: 0.3), value: isTyping)
                        .animation(.easeInOut(duration: 0.3), value: isTextEditorFocused)
                    
                    // question text
                    Text("What do you most enjoy when you have a day to yourself?")
                        .font(.custom("SFProText-Heavy", size: (isTextEditorFocused || isTyping) ? 18 : 27))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("LightPurpleQuestionColor"))
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
                            .foregroundColor(Color("LightPurpleTextColor"))
                            .focused($isTextEditorFocused)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(height: 200, alignment: .topLeading)
                            .background(Color.clear) // make the background clear
                            .scrollContentBackground(.hidden)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("LightPurpleBoxGradientColor2"), Color("LightPurpleBoxGradientColor1")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .cornerRadius(10)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color("LightPurpleBorderColor"), lineWidth: 3.5)
                            )
                            .onChange(of: userInput) { newValue in
                                withAnimation {
                                    isTyping = !userInput.isEmpty
                                }
                                // enforce character limit
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
                                    .foregroundColor(Color("LightPurpleTextColor"))
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
                    }) {
                        Text("Submit")
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
                            .shadow(color: Color.white.opacity(1), radius: 10, x: 0, y: 0) // light glow around the button
                    }
                    .padding(.bottom, 50)

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

struct WellnessQuestionViewLightPurple_Previews: PreviewProvider {
    static var previews: some View {
        WellnessQuestionViewLightPurple()
    }
}