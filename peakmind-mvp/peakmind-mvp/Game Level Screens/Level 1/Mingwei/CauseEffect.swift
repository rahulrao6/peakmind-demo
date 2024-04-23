//
//  CauseEffect.swift
//  peakmind-mvp
//
//  Created by Mingwei Li on 4/22/24.
//

import SwiftUI

struct CauseEffect: View {
    
    var body: some View {
        ZStack {
            Image("MainBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(width: 140)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
                .offset(x: 5, y: 20)
            
            VStack {
                Text("—— Mt. Anxiety ——\n           Level One")
                    .modernTitleStyle()
                    .foregroundColor(.white)
                
                Text("Select a category of each\ninfluencing factor")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .background(
                        RoundedRectangle(cornerRadius: 22.0)
                            .foregroundColor(Color(hex: "366093"))
                            .opacity(0.5)
                            .overlay(RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.black, lineWidth: 1.5))
                            .frame(width: 255, height: 60)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 30.0)
                            .foregroundColor(Color(hex: "4068AA"))
                            .opacity(0.5)
                            .overlay(RoundedRectangle(cornerRadius: 30.0)
                                .stroke(Color.black, lineWidth: 1.5))
                            .frame(width: 320, height: 80)
                    )
                    .font(.system(size: 15))
                    .padding()
                    .padding(.bottom, 10)
                
                
                HStack {
                    Text("2/5")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 15.0)
                                .foregroundColor(Color(hex: "1E4E96"))
                                .opacity(0.9)
                                .overlay(RoundedRectangle(cornerRadius: 15.0)
                                    .stroke(Color.black, lineWidth: 1.5))
                                .frame(width: 50, height: 40)
                        )
                        .offset(x: -5)
                        .padding()
                    Text("Term")
                        .bold()
                        .font(.title2)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 25.0)
                                .foregroundColor(Color(hex: "366093"))
                                .opacity(0.9)
                                .overlay(RoundedRectangle(cornerRadius: 25.0)
                                    .stroke(Color.black, lineWidth: 1.5))
                                .frame(width: 230, height: 40)
                                .offset(x: 76)
                        )
                        .offset(x: 0)
                }
                .offset(x: -100)
                .background(
                    RoundedRectangle(cornerRadius: 27.0)
                        .foregroundColor(Color(hex: "4068AA"))
                        .opacity(0.9)
                        .overlay(RoundedRectangle(cornerRadius: 27.0)
                            .stroke(Color.black, lineWidth: 1.5))
                        .frame(width: 360, height: 60)
                )
                .padding(.bottom, 20)
                VStack {
                    HStack {
                        Text("Can Control")
                            .foregroundColor(.white)
                            .bold()
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15.0)
                                    .foregroundColor(Color(hex: "1E4E96"))
                                    .opacity(0.9)
                                    .overlay(RoundedRectangle(cornerRadius: 15.0)
                                        .stroke(Color.black, lineWidth: 1.5))
                                    .frame(width: 130, height: 40)
                            )
                            .padding(.trailing, 30)
                        
                        Text("Can't Control")
                            .foregroundColor(.white)
                            .bold()
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15.0)
                                    .foregroundColor(Color(hex: "1E4E96"))
                                    .opacity(0.9)
                                    .overlay(RoundedRectangle(cornerRadius: 15.0)
                                        .stroke(Color.black, lineWidth: 1.5))
                                    .frame(width: 130, height: 40)
                            )
                        
                        
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(hex: "00BFFF"))
                            .frame(width: 300, height: 5)
                            .offset(y: 30)
                            .shadow(radius: 10)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(hex: "00BFFF"))
                            .frame(width: 5, height: 160)
                            .offset(y: 110)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 27.0)
                            .foregroundColor(Color(hex: "4068AA"))
                            .opacity(0.9)
                            .overlay(RoundedRectangle(cornerRadius: 27.0)
                                .stroke(Color.black, lineWidth: 1.5))
                            .frame(width: 340, height: 240)
                            .offset(y: 90)
                    )
                    
                    Text("Drag the factors into\nthe category you\nthink they go")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .bold()
                        .offset(x: 70, y: 250)
                        .background(
                            GlowingView(color: "4068AA", frameWidth: 200, frameHeight: 80, cornerRadius: 15)
                                .offset(x: 70, y: 250)
                        )
                    
                    Spacer()
                }
            }
        }
    }
}


struct CauseEffect_Previews: PreviewProvider {
    static var previews: some View {
        CauseEffect().environmentObject(InteractiveViewModel())
    }
}
