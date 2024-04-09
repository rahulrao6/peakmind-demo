//
//  AnimatedSpeechBubble.swift
//  peakmind-mvp
//
//  Created by Katharina Reimer on 4/7/24.
//

import SwiftUI

struct AnimatedSpeechBubble<nextView: View>: View {
    let title: String
    let sherpaText: String
    @State private var animatedText = ""
    var nextScreen: nextView
    
    var body: some View {
        VStack {
            Text(title)
                .font(.system(size: 34, weight: .bold, design: .default))
                .foregroundColor(.white)
                .padding(.top, 50)
                .padding(.horizontal)
                
            Spacer()
            
            SpeechBubble(text: $animatedText)
                .onAppear { animateText() }
                .offset(x: 90, y: 520)
            
            SherpaContinue(nextScreen: nextScreen)
                
        }
        .background(Background())
    }
    private func animateText() {
        var charIndex = 0.0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            let roundedIndex = Int(charIndex)
            if roundedIndex < sherpaText.count {
                let index = sherpaText.index(sherpaText.startIndex, offsetBy: roundedIndex)
                animatedText.append(sherpaText[index])
            }
            charIndex += 1
            if roundedIndex >= sherpaText.count {
                timer.invalidate()
            }
        }
        timer.fire()
    }
}

struct SpeechBubble: View {
    @Binding var text: String

    var body: some View {
        Text(text)
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .lineLimit(7)
            .padding()
            .frame(width: 300, height: 150, alignment: .topLeading)
            .background(Color("Dark Blue"))
            .cornerRadius(10)
            .overlay(
                Triangle()
                    .fill(Color("Dark Blue"))
                    .frame(width: 20, height: 20)
                    .rotationEffect(Angle(degrees: 45))
                    .offset(x: 0, y: 10),
                alignment: .bottomLeading
            )
            .offset(x: -70, y: -240)
    }
}



struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    AnimatedSpeechBubble(title:"Mt. Anxiety Level One",
                         sherpaText:"isfdhgfaoi",
                        nextScreen: NightfallFlavorView())
}
