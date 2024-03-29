//
//  L2SherpaChatView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/23/24.
//

import SwiftUI

struct L2SherpaChatView: View {
    let sherpaText = "Getting a deeper understanding of anxiety is the first step to improving it. First, it's important to understand where your anxiety is coming from. Step by step, you’ll learn how to handle and react to every source of anxiety you have."
    @State private var animatedText = ""

    var body: some View {
        ZStack {
            Image("MainBG")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            Text("Mt. Anxiety: Level Two")
                .font(.system(size: 34, weight: .bold, design: .default))
                .foregroundColor(.white)
                .padding(.top, -350)
                .padding(.horizontal)

            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(width: 140)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
                .offset(x: 25, y: 20)

            SpeechBubble(text: $animatedText)
                .onAppear { animateText() }
                .offset(x: 90, y: 300)
        }
    }
    
    private func animateText() {
        var charIndex = 0.0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
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



struct L2SherpaChatView_Previews: PreviewProvider {
    static var previews: some View {
        L2SherpaChatView()
    }
}
