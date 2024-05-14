//
//  EduaResilience.swift
//  peakmind-mvp
//
//  Created by Mingwei Li on 5/13/24.
//

import SwiftUI

struct EduaResilience: View {
    private let texts = ["• Resilience is the bodies ability to quickly respond to\n anxiety, stress, failure or even trauma. Building\n resilience is important to help you adapt quickly to\n events in your life.\n•  Focusing on self care habits is the foundation of\n resilience. Regularly exercising, getting 8+ hours\n of sleep, drinking plenty of water, and eating three\n meals a day are all essential for managing your entire\n mental health.",
        "• Your specific struggles require different\n types of coping mechanisms. Socially,\n setting boundaries, accepting compliments,\n and regularly reaching out to others all\n contribute to building strong resilience.\n• Beyond building effective habits,\n understand that there is always a coping\n mechanism that can be done to respond to\n any situation.",
    "• Remember, some mechanisms such as\n breathing, progressive muscle\n relaxation, and meditation are best for\n immediate response.\n• Building resilience requires an active\n effort to do immediate response coping\n mechanisms and maintaining self care\n habits. Doing both is equally important!"]

    let sColor: Color = Color(hex: "61A1E3") ?? .white;
    let eColor: Color = Color(hex: "0E58A5") ?? .white;
    let sColor3: Color = Color(hex: "6EADF0") ?? .white;
    let eColor4: Color = Color(hex: "044F9E") ?? .white;
    let sColor5: Color = Color(hex: "B3DEF7") ?? .white;
    let eColor6: Color = Color(hex: "4CB9F8") ?? .white;

    var body: some View {
        ZStack{
            Image("MainBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
            
            VStack{
                Text("—— Mt. Anxiety ——")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .glowBorder(color: .black, lineWidth: 2)
                
                Text("Level Four")
                    .glowBorder(color: .black, lineWidth: 2)
                    .font(.system(size: 26, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.bottom, 40)
                
                
                VStack{
                    Text("Resilience")
                        .glowBorder(color: .black, lineWidth: 3)
                        .background(
                            Rectangle()
                                .foregroundColor(Color(hex: "2D6AB4"))
                                .opacity(0.8)
                                .cornerRadius(15.0)
                                .overlay(RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.black, lineWidth: 2))
                                .frame(width: 273, height: 48)
                                .shadow(radius: 10, y: 10)
                        )
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                    
                    TabView{
                        ForEach(0..<texts.count, id: \.self) { index in
                            VStack {
                                Text(texts[index])
                                    .bold()
                                    .glowBorder(color: .black, lineWidth: 2)
                                    .font(.system(size: 10))
                                    .foregroundColor(.white)
                                    .lineSpacing(15)
                                    .transition(.identity)
                            }
                        }
                    }
                    .background(
                        Rectangle()
                            .foregroundColor(Color(hex: "677072"))
                            .opacity(0.33)
                            .cornerRadius(20.0)
                            .overlay(RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 2))
                            .frame(width: 271, height: 284)
                            .shadow(radius: 10, y: 10)
                    )
                    .frame(width: 300, height: 300)
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                    
                }
                .background(
                    LinearGradient(colors: [sColor, eColor], startPoint: .top, endPoint: .bottom)
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black, lineWidth: 1))
                        .frame(width: 320, height: 386)
                        .opacity(0.8)
                )
                .padding(.bottom, 70)
                
                Text("Swipe through the\neducation module")
                    .bold()
                    .font(.system(size: 21))
                    .glowBorder(color: .black, lineWidth: 2)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .background(
                        LinearGradient(colors: [eColor4, sColor3], startPoint: .top, endPoint: .bottom)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 2))
                            .frame(width: 207, height: 88)
                            .opacity(0.8)
                    )
                    .offset(x: 40)
                Spacer()
            }
            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(width: 115)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
                .offset(x: 40, y: -20)
            
        }
    }
}

struct EduaResilience_Previews: PreviewProvider {
    static var previews: some View {
        EduaResilience()
    }
}
