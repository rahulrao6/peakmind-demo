//
//  Level2FlavorView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/23/24.
//

import SwiftUI

// screen ten - level two 
struct Level2FlavorView: View {
    let titleText = "Mt. Anxiety: Level Two"
    let narrationText = "So far, you’ve learned so much about the physical effects of anxiety and how to reduce it. This is the beginning of your toolbox to be anxiety free!"
    @State private var animatedText = ""
    @State var navigateToNext = false
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        ZStack {
            Image("MainBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(width: 140)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
                .offset(x: 25, y: 20)
            VStack(spacing: 20) {
                Text(titleText)
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
                    .background(
                        NavigationLink(destination: WellnessQ3View().navigationBarBackButtonHidden(true).environmentObject(viewModel), isActive: $navigateToNext) {
                            EmptyView()
                        })
            }
        }
        .onTapGesture {
            // When tapped, navigate to the next screen
            navigateToNext = true
        }
    }
    
    private func animateText() {
        var charIndex = 0.0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            let roundedIndex = Int(charIndex)
            if roundedIndex < narrationText.count {
                let index = narrationText.index(narrationText.startIndex, offsetBy: roundedIndex)
                animatedText.append(narrationText[index])
            }
            charIndex += 1
            if roundedIndex >= narrationText.count {
                timer.invalidate()
            }
        }
        timer.fire()
    }
}

struct Level2FlavorView_Previews: PreviewProvider {
    static var previews: some View {
        Level2FlavorView()
    }
}
