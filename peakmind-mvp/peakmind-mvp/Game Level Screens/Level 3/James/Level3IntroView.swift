//
//  AnxietyModuleView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/17/24.
//

import SwiftUI

struct Level3IntroView: View {
    var body: some View {
        ZStack {
            Image("MainBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
            
            
            VStack {
                // Title
                Text("Mt. Anxiety: Level Three")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .padding(.bottom, 40)
                
                // Welcome
                HStack {
                    Text("Welcome to Level 3!")
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .padding(.bottom, 5)
                }
                .frame(width: 350, height: 70)
                .background(Color("Dark Blue").opacity(0.75))
                .cornerRadius(30)
                .shadow(radius: 5)
                .padding(.bottom, 40)
                
                // Next Steps
                HStack {
                    Text("Are you ready to begin your next step to summit Mt. Anxiety?")
                        .font(.system(size: 22, weight: .medium, design: .default))
                        .foregroundColor(.white)
                        .padding(.bottom)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 280, height: 170)
                .padding(30)
                .background(Color("Dark Blue").opacity(0.75))
                .cornerRadius(30)
                .shadow(radius: 5)
                
                Spacer()
            }
            
            // Instruction Text
            
            Text("Tap to Continue")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding()
                .offset(x: -140, y: -230)
            
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

struct Level3IntroView_Previews: PreviewProvider {
    static var previews: some View {
        Level3IntroView()
    }
}
