//
//  LevelCompleteView.swift
//  peakmind-mvp
//
//  Created by James Wilson on 4/13/24.
//

import SwiftUI

struct LevelCompleteView: View {
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
                .offset(x: 225, y: 20)
                .zIndex(1)
            
            Image("Raj")
                .resizable()
                .scaledToFit()
                .frame(width: 240)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
                .offset(x: -20, y: 20)
                .zIndex(1)
            
            VStack(spacing: 0) {
                Text("Mt. Anxiety: Level One")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .padding(.bottom, 40)

                ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
                    VStack {
                        Text("Level One Complete!")
                            .font(.system(size: 32, weight: .bold, design: .default))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 5)
                        
                        Image("IndianIcon")
                            .resizable()
                            .frame(width: 75, height: 75)
                            .padding(.bottom, 40)

                        Image("StarsCropped")
                            .resizable()
                            .frame(width: 300, height: 120)
                            
                        
                        Text("Congratulations, you have summited mount anxiety!")
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 5)
                    }
                    .frame(width: 300, height: 430)
                    .background(Color("Dark Blue").opacity(0.75))
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .zIndex(0)
                }
                Spacer()
            }
        }
    }
}

struct LevelCompleteView_Previews: PreviewProvider {
    static var previews: some View {
        LevelCompleteView()
    }
}
