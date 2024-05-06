//
//  ReflectionL3.swift
//  peakmind-mvp
//
//  Created by Mingwei Li on 5/5/24.
//

import SwiftUI

struct ReflectionL3: View {
    let sColor: Color = Color(hex: "005D92") ?? .white;
    let eColor: Color = Color(hex: "B6E0F8") ?? .white;
    let sColor3: Color = Color(hex: "6EADF0") ?? .white;
    let eColor4: Color = Color(hex: "044F9E") ?? .white;
    let sColor5: Color = Color(hex: "0771A7") ?? .white;
    private let texts = ["In this phase, you learned so much\nabout the physical and emotional\nimpacts of anxiety. You also\nexplored the different ways you\ncan adjust your thinking and\nimprove upon your coping\nmechanisms.",
        "We worked through scenarios,\ncoping strategies, progressive\nmuscle relaxation, and more! In\nthe next phase you’ll learn about\nbuilding routines and resilience."]
    
    var body: some View {
        ZStack{
            Image("MainBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(width: 115)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
                .offset(x: 40, y: -20)
            
            VStack{
                Text("—— Mt. Anxiety ——")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .glowBorder(color: .black, lineWidth: 2)
                
                Text("Level Three")
                    .glowBorder(color: .black, lineWidth: 2)
                    .font(.system(size: 26, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.bottom, 40)
                
                
                VStack{
                    Text("Reflection")
                        .glowBorder(color: .black, lineWidth: 3)
                        .background(
                            Rectangle()
                                .foregroundColor(Color(hex: "2D6AB4"))
                                .opacity(0.8)
                                .cornerRadius(15.0)
                                .overlay(RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.black, lineWidth: 2))
                                .frame(width: 125, height: 38)
                                .shadow(radius: 10, y: 10)
                        )
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                    
                    TabView{
                        ForEach(0..<texts.count, id: \.self) { index in
                            VStack {
                                Text(texts[index])
                                    .glowBorder(color: .black, lineWidth: 2)
                                    .font(.system(size: 13))
                                    .foregroundColor(.white)
                                    .lineSpacing(8)
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
                            .frame(width: 253, height: 187)
                            .shadow(radius: 10, y: 10)
                    )
                    .frame(width: 300, height: 300)
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                    .offset(y: -50)
                    
                    Button("Proceed to Quiz"){
                        
                    }
                    .glowBorder(color: .black, lineWidth: 2)
                    .background(
                        LinearGradient(colors: [eColor, sColor5,eColor], startPoint: .top, endPoint: .bottom)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 1))
                            .frame(width: 177, height: 41)
                    )
                    .font(.title2)
                    .foregroundColor(.white)
                    .offset(y: -50)
                }
                .background(
                    LinearGradient(colors: [sColor3, eColor4], startPoint: .top, endPoint: .bottom)
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black, lineWidth: 1))
                        .frame(width: 320, height: 357)
                        .opacity(0.8)
                        .offset(y: -20)
                )
                .padding(.bottom, 70)
                
                Text("Lets look at this\nscenario and see\nwhat you should do")
                    .font(.system(size: 15))
                    .glowBorder(color: .black, lineWidth: 2)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .background(
                        EllipticalGradient(colors: [sColor3, eColor4], center: .center)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 2))
                            .frame(width: 207, height: 88)
                            .opacity(0.8)
                    )
                    .offset(x: 60, y: 40)
                Spacer()
            }
        }
    }
}

struct ReflectionL3_Previews: PreviewProvider {
    static var previews: some View {
        ReflectionL3()
    }
}
