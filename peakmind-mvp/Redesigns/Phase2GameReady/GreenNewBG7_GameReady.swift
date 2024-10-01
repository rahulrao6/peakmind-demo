//
//  GreenNewBG7.swift
//  peakmind-mvp
//
//  Created by ZA on 9/18/24.
//

import SwiftUI

struct P2_7_1: View {
    var closeAction: (String) -> Void
    @State private var factor1: String = ""
    @State private var factor2: String = ""
    @State private var factor3: String = ""
    @State private var factor4: String = ""
    @State private var factor5: String = ""
    @State private var isClicked = false

    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("GreenNewBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    Spacer().frame(height: 40)
                    
                    // Title Text
                    Text("Environmental Factors")
                        .font(.custom("SFProText-Bold", size: 30))
                        .foregroundColor(Color("GreenTitleColor"))
                        .padding(.bottom, 10)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    // Intro Text
                    Text("Many factors influence our anxiety and well-being, including environmental, familial, and upbringing-related elements. Let's consider five external factors that impact your environment.")
                        .font(.custom("SFProText-Medium", size: 16))
                        .foregroundColor(Color("GreenTextColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // 5 Text boxes for entering factors
                    ForEach(1...5, id: \.self) { index in
                        ZStack(alignment: .topLeading) {
                            if getText(for: index).isEmpty {
                                Text("Enter factor \(index)...")
                                    .foregroundColor(Color.gray.opacity(0.5))
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                    .zIndex(1)
                            }
                            
                            TextEditor(text: binding(for: index))
                                .font(.custom("SFProText-Medium", size: 16))
                                .foregroundColor(Color("GreenTextColor"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(height: 60)
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
                    }
                    .fullScreenCover(isPresented: $isClicked) {
                        P2_4_2(closeAction: closeAction)
                    }
                    
                    Spacer()
                    
                    // NavigationLink wraps the button as its label
                    if allTextBoxesFilled {
                        Button(action: {
                                    isClicked = true
                                }) {
                                    Text("Continue")
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
                                        .shadow(color: Color.white.opacity(1), radius: 10, x: 0, y: 0)
                                }
                                .padding(.bottom, 50)
                    }
                }
            }
        }
    }
    
    // Text binding for each factor input
    private func binding(for index: Int) -> Binding<String> {
        switch index {
        case 1: return $factor1
        case 2: return $factor2
        case 3: return $factor3
        case 4: return $factor4
        case 5: return $factor5
        default: return $factor1
        }
    }
    
    // Get text for each factor
    private func getText(for index: Int) -> String {
        switch index {
        case 1: return factor1
        case 2: return factor2
        case 3: return factor3
        case 4: return factor4
        case 5: return factor5
        default: return ""
        }
    }
    
    // Check if all text boxes are filled
    private var allTextBoxesFilled: Bool {
        !factor1.isEmpty && !factor2.isEmpty && !factor3.isEmpty && !factor4.isEmpty && !factor5.isEmpty
    }
}
