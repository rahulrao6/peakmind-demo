//
//  SherpaFullMoonID.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/17/24.
//

import SwiftUI

struct SherpaFullMoonView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    let sherpaText = "It seems there is a full moon. That must be why all of the werewolves are out. Times like these can be stressful but you will get through it. Take it one step at a time."
    @State private var animatedText = ""
    @State var navigateToNext = false


    var body: some View {
        ZStack {
            Image("ChatBG2")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            Text("Mt. Anxiety: Level One")
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
        .background(
            NavigationLink(destination: AnxietyGoalSetting().navigationBarBackButtonHidden(true).environmentObject(viewModel), isActive: $navigateToNext) {
            EmptyView()
        })
        .onTapGesture {
            // When tapped, navigate to the next screen
            navigateToNext = true
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



struct SherpaFullMoonView_Previews: PreviewProvider {
    static var previews: some View {
        SherpaFullMoonView()
    }
}
