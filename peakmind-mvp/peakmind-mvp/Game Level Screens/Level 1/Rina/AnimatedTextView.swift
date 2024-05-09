//
//  AnimatedTextView.swift
//  peakmind-mvp
//
//  Created by Katharina Reimer on 4/7/24.
//

import SwiftUI

struct AnimatedTextView<nextView: View>: View {
    let title: String
    let narration: String
    @State private var animatedText = ""
    var nextScreen: nextView
    var closeAction: () -> Void

    var body: some View {
        VStack {
            VStack(spacing: 20) {
                Text(title)
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.top, 50)
                    .padding(.horizontal)
                
                VStack(alignment: .center) {
                    Text(animatedText)
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .onAppear {
                            animateText()
                        }
                }
                .background(Color("Dark Blue"))
                .cornerRadius(15)
                .padding(.horizontal, 40) // Increase horizontal padding to prevent background from extending to the sides
                
                
                Spacer()
                
                SherpaContinue(nextScreen: nextScreen, closeAction: closeAction)
                
            }
        }
        .background(Background())
    }
    private func animateText() {
        var charIndex = 0.0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            let roundedIndex = Int(charIndex)
            if roundedIndex < narration.count {
                let index = narration.index(narration.startIndex, offsetBy: roundedIndex)
                animatedText.append(narration[index])
            }
            charIndex += 1
            if roundedIndex >= narration.count {
                timer.invalidate()
            }
        }
        timer.fire()
    }
        
}
//
//#Preview {
//    AnimatedTextView<SherpaFullMoonView>(title: "Mt. Anxiety: Level One",
//                                         narration: "You hear the howls of wolves in the distance. They seem to be getting louder and louder.",
//                                         nextScreen: SherpaFullMoonView())
//}
