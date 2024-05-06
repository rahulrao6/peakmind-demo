//
//  IntroL4.swift
//  peakmind-mvp
//
//  Created by Mingwei Li on 5/5/24.
//

import SwiftUI

struct IntroL4: View {
    
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
                
                Text("Physical and Emotional Anxiety")
                    .glowBorder(color: .black, lineWidth: 2)
                    .background(
                        Rectangle()
                            .foregroundColor(Color(hex: "004FAC"))
                            .opacity(0.8)
                            .cornerRadius(30.0)
                            .overlay(RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.black, lineWidth: 2))
                            .frame(width: 300, height: 30)
                    )
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                    .padding()
                    .padding(.bottom, 10)
                
                Text("Welcome to the next phase of \nyour journey to conquer \nanxiety. In this phase, you’ll \nlearn about the physical and \nemotional impacts of anxiety. \nYou’ll also go through \ndifferent strategies to identify \nand manage major sources of \nanxiety.")
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
                            .frame(width: 300, height: 240)
                    )
                    .padding(.bottom, 70)
                    
                
                Text("Continue")
                    .glowBorder(color: .black, lineWidth: 2)
                    .background(
                        EllipticalGradient(colors: [sColor3, eColor4], center: .center)
                            .cornerRadius(15.0)
                            .overlay(RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black, lineWidth: 1))
                            .frame(width: 200, height: 50)
                    )
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                
                Spacer()
            }
            .background(
                LinearGradient(colors: [sColor, eColor], startPoint: .top, endPoint: .bottom)
                    .cornerRadius(30.0)
                    .overlay(RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.black, lineWidth: 1))
                    .frame(width: 340, height: 425)
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

struct IntroL4_Previews: PreviewProvider {
    static var previews: some View {
        IntroL4()
    }
}
