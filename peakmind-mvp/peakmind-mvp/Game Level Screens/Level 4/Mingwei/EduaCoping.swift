//
//  EduaCoping.swift
//  peakmind-mvp
//
//  Created by Mingwei Li on 5/13/24.
//

//
//  EduaResilience.swift
//  peakmind-mvp
//
//  Created by Mingwei Li on 5/13/24.
//

import SwiftUI

struct EduaCoping: View {
    private let texts = ["• When the body is in crisis, it is common\n for heart rate and breathing to speed\n up to a heightened rate. This can\n include high stress, panic, and high\n fear situations.\n• When this occurs, the first step is to\n regulate your breathing levels and\n focus on single points within the space\n you are in.",
        "• Remember, if it is an emergency, asking for\n professional services is the first step. There are\n many hotlines available and can be found in the\n HOTLINES area of the profile tab in your home\n screen.\n• Journaling a plan for stressful situations is one\n of the most beneficial things you can do as it\n gives you actionable steps for when you'r\n stressed.",
    "• It’s important to remind yourself that these\n feelings will pass. It can take anywhere from a\n few minutes to two hours to calm the body from\n a crisis situation.\n• Another great strategy for experiencing panic\n is the 5/4/3/2/1 grounding mechanism\n which you’ll learn about later in this phase."]

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
                    Text("Coping with crisis")
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

struct EduaCoping_Previews: PreviewProvider {
    static var previews: some View {
        EduaCoping()
    }
}
