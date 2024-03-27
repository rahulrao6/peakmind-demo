//
//  BreathingExerciseView.swift
//  peakmind-mvp
//
//  Created by James Wilson on 3/26/24.
//

import SwiftUI

struct BreathingExerciseView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var userAnswer: String = ""
    @State private var showThankYou = false

    var body: some View {
        ZStack {
            // Background
            Image("MainBG")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            // Content
            VStack {
                // Title
                Text("Mt. Anxiety: Level Three")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.bottom, 40)

                VStack {
                    Text("Breathing for Stress")
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .padding()
                    Text("The 4 second inhale, 7 second hold, and 8 second exhale is a prime therapeutic technique for stress relief.")
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .foregroundColor(.white)
                        .padding(.leading, 40)
                        .padding(.trailing, 40)
                        .padding(.bottom, 20)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 350, height: 200)
                .background(Color("Dark Blue").opacity(0.75))
                .cornerRadius(30)
                .shadow(radius: 5)
                
                Image("breathingTriangle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220)
                
                
                

                Spacer()

                // Sherpa Image and Prompt
                HStack {
                    Image("Sherpa")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                    
                    Text("Lets learn a breathing method!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue.opacity(0.85))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .padding()
        }
    }
}



// Other struct definitions (SubmitButton, ThankYouMessage, TruthfulPrompt, and Text extensions) remain unchanged...

struct BreathingExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        BreathingExerciseView().environmentObject(AuthViewModel())
    }
}

