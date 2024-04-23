//
//  Level1Reflection.swift
//  peakmind-mvp
//
//  Created by Mingwei Li on 3/17/24.
//

import SwiftUI

struct Level1Reflection: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    
    
    var body: some View {
        ZStack {
            Image("MainBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            Image("Raj")
                .resizable()
                .scaledToFit()
                .frame(width: 245)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
                .offset(x: -60, y: 20)
            
            VStack {
                Text("—— Mt. Anxiety ——\n          Level One")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.bottom, 30)
                VStack {
                    Text("Reflection")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.bottom, 35)
                        .background(
                            RoundedRectangle(cornerRadius: 17.0)
                                .foregroundColor(Color(hex: "1E4E96"))
                                .opacity(0.8)
                                .overlay(RoundedRectangle(cornerRadius: 17)
                                    .stroke(Color.black, lineWidth: 2))
                                .frame(width: 120,height: 40)
                                .offset(y: -16)
                        )
                    Text("• You’ve learned so much\n already about how anxiety works. \n\n• Amazing work starting your \nfirst habit to understanding \nhow anxiety works. \n\n• Throughout this journey, you\nwill gain a toolbox on how\nto manage your anxiety.")
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 40.0)
                                .foregroundColor(Color(hex: "2A4E7C"))
                                .opacity(0.6)
                                .overlay(RoundedRectangle(cornerRadius: 40)
                                    .stroke(Color.black, lineWidth: 1))
                                .frame(width: 290,height: 250)
                                .offset(x: -6, y: 4)
                        )
                }
                .background(
                    RoundedRectangle(cornerRadius: 40.0)
                        .foregroundColor(Color(hex: "1E90FF"))
                        .opacity(0.6)
                        .overlay(RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.black, lineWidth: 1))
                        .frame(width: 350,height: 370)
                        .offset(x: 0, y: 20)
                )
                
                Text("Let's review what \nyou have learned")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .background(
                        GlowingView(color: "2A4E7C", frameWidth: 190, frameHeight: 90, cornerRadius: 20)
                    )
                    .frame(width: 170, height: 90)
                    .cornerRadius(10)
                    .offset(y: 152)
                
                Spacer()
                Image("Sherpa")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 112)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .padding()
                    .offset(x: 240, y: 20)
            }
        }
    }
}

struct Level1Reflection_Previews: PreviewProvider {
    static var previews: some View {
        Level1Reflection()
    }
}
