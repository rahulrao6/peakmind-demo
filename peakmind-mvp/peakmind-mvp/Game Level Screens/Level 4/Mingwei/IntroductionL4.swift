//
//  IntroductionL4.swift
//  peakmind-mvp
//
//  Created by Mingwei Li on 5/13/24.
//

import SwiftUI

struct IntroductionL4: View {
    
    let sColor: Color = Color(hex: "6EADF0") ?? .white;
    let eColor: Color = Color(hex: "044F9E") ?? .white;
    let sColor3: Color = Color(hex: "B3DEF7") ?? .white;
    let eColor4: Color = Color(hex: "4CB9F8") ?? .white;
    var body: some View {
        ZStack{
            Image("MainBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
            VStack{
                Spacer()
                
                Text("Introduction")
                    .glowBorder(color: .black, lineWidth: 2)
                    .background(
                        Rectangle()
                            .foregroundColor(Color(hex: "004FAC"))
                            .opacity(0.8)
                            .cornerRadius(30.0)
                            .overlay(RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.black, lineWidth: 2))
                            .frame(width: 258, height: 33)
                    )
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                    .padding()
                    .padding(.bottom, 30)
                
                Text("Welcome to the next phase of\n your journey managing anxiety.\n This phase will teach you\n about building resilience and \nestablishing a routine in your \nlife. You’ll go through\n different activities to better\n your current habits and\n routines.")
                    .glowBorder(color: .black, lineWidth: 2)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .background(
                        Rectangle()
                            .foregroundColor(Color(hex: "677072"))
                            .opacity(0.33)
                            .cornerRadius(30.0)
                            .overlay(RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.black, lineWidth: 1))
                            .frame(width: 266, height: 280)
                    )
                    .padding(.bottom, 70)
                    
                
                Button("Continue"){
                    
                }
                    .glowBorder(color: .black, lineWidth: 2)
                    .background(
                        EllipticalGradient(colors: [sColor3, eColor4], center: .center)
                            .cornerRadius(15.0)
                            .overlay(RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black, lineWidth: 1))
                            .frame(width: 203, height: 44)
                    )
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                
                Spacer()
            }
            .background(
                LinearGradient(colors: [sColor, eColor], startPoint: .top, endPoint: .bottom)
                    .cornerRadius(18.0)
                    .overlay(RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.black, lineWidth: 1))
                    .frame(width: 364, height: 437)
                    .opacity(0.8)
                    .offset(y:20)
            )
            .padding(.bottom, 40)
            
            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(width: 90)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
                .offset(x: 18, y: -180)
        }
    }
}

struct IntroductionL4_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionL4()
    }
}

