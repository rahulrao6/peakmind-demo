//
//  P2-1_Intro.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 4/21/24.
//

import SwiftUI

struct P2_1_Intro: View {
    var closeAction: () -> Void

    var body: some View {
        ZStack {
            Image("MainBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
            
            
            VStack {
                // Title
                Text("Mt. Anxiety: Phase Two")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .padding(.bottom, 40)
                
                // Welcome
                HStack {
                    Text("Welcome to Phase Two!")
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .padding(.bottom, 5)
                }
                .frame(width: 350, height: 70)
                .background(Color("Dark Blue").opacity(0.75))
                .cornerRadius(30)
                .shadow(radius: 5)
                .padding(.bottom, 20)
                
                // Next Steps
                HStack {
                    Text("Get ready to conquer anxiety at PeakMind! Phase two is all about becoming an anxiety-fighting pro. We'll explore different types of anxiety and how they can impact your choices and actions. By understanding them, you'll gain the power to manage them and live your best life! Are you ready to unlock your inner PeakMind?")
                        .font(.system(size: 17, weight: .medium, design: .default))
                        .foregroundColor(.white)
                        .padding(.bottom)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 290, height: 230)
                .padding(30)
                .background(Color("Dark Blue").opacity(0.75))
                .cornerRadius(30)
                .shadow(radius: 5)
                
                Spacer()
            }
            
            // Instruction Text

            Text("Tap to Continue")
                .foregroundColor(.white.opacity(0.4))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding()
                .offset(x: -140, y: -245)
                .onTapGesture {
                    closeAction()
                }
            // Sherpa & Avatar
            
            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(width: 140)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
                .offset(x: 25, y: 20)
            
            Image("Raj")
                .resizable()
                .scaledToFit()
                .frame(width: 260)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
                .offset(x: 180, y: 30)
        }
    }
}

/*struct P2_1_Intro_Previews: PreviewProvider {
    static var previews: some View {
        P2_1_Intro()
    }
}
*/
