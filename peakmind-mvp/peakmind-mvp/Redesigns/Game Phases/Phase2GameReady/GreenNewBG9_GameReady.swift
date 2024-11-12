
//
//  PurpleNewBG8.swift
//  peakmind-mvp
//
//  Created by ZA on 8/28/24.
//

import SwiftUI

struct P2_9_1: View {
    var closeAction: (String) -> Void
    @State private var currentIndex: Int = 0
    @State private var visibleText: String = ""
    @State private var isTypingCompleted: Bool = false
    @State private var navigateToIntroView2 = false // state to control navigation
    
    let introText = """
    Let's take a moment to center ourselves with a breathing exercise. This technique will help clear your mind and wash away any built-up stress. Deep breaths are a powerful tool for relaxation.


    Breathe in quietly through your nose for a count of four. Hold your breath for a count of seven. Exhale completely through your mouth, making a whooshing sound, for a count of eight. Repeat this cycle for three to four breaths, or until you feel yourself calming down!
    """
    
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
                    Text("4/7/8 Breathing")
                        .font(.custom("SFProText-Bold", size: 28))
                        .foregroundColor(Color("PurpleTitleColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    // typing intro text inside a box
                    ZStack(alignment: .topLeading) {
                        // gradient background box
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PurpleBoxGradientColor1"), Color("PurpleBoxGradientColor2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color("PurpleBorderColor"), lineWidth: 3.5)
                            )
                        
                        // typing text animation with auto-scroll
                        ScrollViewReader { proxy in
                            ScrollView {
                                Text(visibleText)
                                    .font(.custom("SFProText-Medium", size: 16))
                                    .foregroundColor(Color("PurpleTextColor"))
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
                    
                    
                    SpriteKitUIView(scene: SpriteKitScene(size: CGSize(width: 200, height: 200)))
                        .frame(width: 250, height: 200)
                        .background(Color.clear)
                    
                    // next Button
                    Button(action: {
                        closeAction("You completed a coping mechanism!")
                    }) {
                        Text("Next")
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
                            .shadow(color: Color.white.opacity(1), radius: 10, x: 0, y: 0) // show glow when required
                    }
                    .padding(.bottom, 50)
                    .disabled(!isTypingCompleted) // disable button if typing is not complete
                    
                    // navigation link to the next screen
                    NavigationLink(destination: IntroView2(), isActive: $navigateToIntroView2) {
                        EmptyView()
                    }
                }
                .padding(.horizontal)
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
}
