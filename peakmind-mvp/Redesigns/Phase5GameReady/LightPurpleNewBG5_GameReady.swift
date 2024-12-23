//
//  LightPurpleNewBG5.swift
//  peakmind-mvp
//
//  Created by ZA on 10/1/24.
//

import SwiftUI

struct P5_5_1: View {
    var closeAction: (String) -> Void
    @State private var firstText: String = ""
    @State private var secondText: String = ""
    @State private var thirdText: String = ""
    @State private var navigateToNextScreen = false
    @State private var focusedField: String? = nil
    
    // Accept supportNames as a parameter
    var supportNames: [String]

    var areAllTextFieldsFilled: Bool {
        return !firstText.isEmpty && !secondText.isEmpty && !thirdText.isEmpty
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // background image
                Image("LightPurpleNewBG")
                    .resizable()
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 36) {
                    Spacer().frame(height: 10)
                    
                    // title section
                    Text("What are some challenges you're dealing with?")
                        .font(.custom("SFProText-Bold", size: 28))
                        .foregroundColor(Color("LightPurpleTitleColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    // 3 long text input boxes
                    VStack(spacing: 12) {
                        ThoughtTextEditor(
                            text: $firstText,
                            placeholder: " Describe your first challenge",
                            isFocused: focusedField == "firstText",
                            onTap: { focusedField = "firstText" }
                        )
                        ThoughtTextEditor(
                            text: $secondText,
                            placeholder: " Describe your second challenge",
                            isFocused: focusedField == "secondText",
                            onTap: { focusedField = "secondText" }
                        )
                        ThoughtTextEditor(
                            text: $thirdText,
                            placeholder: " Describe your third challenge",
                            isFocused: focusedField == "thirdText",
                            onTap: { focusedField = "thirdText" }
                        )
                    }
                    .padding(.horizontal, 20)
                    .onAppear {
                        print(supportNames)
                    }
                    
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

                                        
                    Spacer()
                }
                .padding(.horizontal)
                .fullScreenCover(isPresented: $navigateToNextScreen) {
                    P5_5_2(closeAction: closeAction, firstText: firstText, secondText: secondText, thirdText: thirdText, supportNames: supportNames)
                }

            }
        }
    }
}
