
//
//  PurpleNewBG2.swift
//  peakmind-mvp
//
//  Created by ZA on 8/22/24.
//



import SwiftUI

struct P2_1: View {
    var closeAction: (String) -> Void
    @State private var currentIndex: Int = 0
    @State private var isButtonDisabled: Bool = true
    @State private var showGlow: Bool = false
    @State private var navigateToWellnessQuestion = false // state to control navigation
    
    let bulletPoints = [
        "Mental health involves our emotional, psychological, and social well-being. It shapes how we perceive the world and think about ourselves. Every decision we make is influenced by our mental health, making it so important to learn coping strategies and how to manage it correctly!",
        "Managing our mental health requires a conscious effort since we have different personal and environmental needs. Our mental health impacts how we interact with others, shaping personal relationships and social interactions.",
        "Just like taking care of our bodies, prioritizing mental health is essential. A happy life is within reach for everyone. Using coping strategies, support groups, and learning about our specific mental health struggles will lead to a happier lifestyle."
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("PurpleNewBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    Spacer()
                        .frame(height: 80)
                    
                    Text("Mental Health")
                        .font(.custom("SFProText-Bold", size: 30))
                        .foregroundColor(Color("PurpleTitleColor"))
                        .padding(.bottom, 10)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PurpleBoxGradientColor1"), Color("PurpleBoxGradientColor2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: geometry.size.height * 0.55)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color("PurpleBorderColor"), lineWidth: 3.5)
                            )
                        
                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(0..<currentIndex + 1, id: \.self) { index in
                                        FeatureBulletPoint(text: bulletPoints[index], onTypingComplete: {
                                            isButtonDisabled = false
                                            showGlow = true
                                        })
                                        .id(index)
                                    }
                                    Color.clear.frame(height: 1).id("bottom")
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                            }
                            .defaultScrollAnchor(.bottom)
                        }
                        .frame(height: geometry.size.height * 0.53)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    Button(action: {
                        if currentIndex < bulletPoints.count - 1 {
                            isButtonDisabled = true
                            showGlow = false
                            currentIndex += 1
                        } else {
                            navigateToWellnessQuestion = true
                        }
                    }) {
                        Text(currentIndex < bulletPoints.count - 1 ? "Next" : "Continue")
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
                            .shadow(color: showGlow ? Color.white.opacity(1) : Color.clear, radius: 10, x: 0, y: 0)
                    }
                    .padding(.bottom, 50)
                    .disabled(isButtonDisabled)
                }
                .padding(.horizontal)
                .fullScreenCover(isPresented: $navigateToWellnessQuestion) {
                    P2_2(closeAction: closeAction)
                }
                
            }
        }
        .onAppear {
            currentIndex = 0
            isButtonDisabled = true
            showGlow = false
        }
    }
}

struct FeatureBulletPoint: View {
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
        
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
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

struct MentalHealthFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MentalHealthFeatureView()
        }
    }
}
