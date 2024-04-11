//
//  L2QuizResponseView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/23/24.
//

import SwiftUI

// Screen three - Level 2
struct L2QuizResponseView: View {
    let sherpaText = "Physical anxiety is very real, thank you for taking the time to understand how it works!"
    @State private var animatedText = ""
    @State var navigateToNext = false
    @EnvironmentObject var viewModel: AuthViewModel



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

            SpeechBubble(text: $animatedText, width:300.0)
                .onAppear { animateText() }
                .offset(x: 90, y: 300)
        }
        .background(
            NavigationLink(destination: WindsFlavorView().navigationBarBackButtonHidden(true).environmentObject(viewModel), isActive: $navigateToNext) {
                EmptyView()
            })
        .onTapGesture {
            // When tapped, navigate to the next screen
            navigateToNext = true
        }
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



struct L2QuizResponseView_Previews: PreviewProvider {
    static var previews: some View {
        L2QuizResponseView()
    }
}
