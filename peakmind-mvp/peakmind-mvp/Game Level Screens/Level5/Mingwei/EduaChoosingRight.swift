//
//  EduaChoosingRight.swift
//  peakmind-mvp
//
//  Created by Mingwei Li on 5/18/24.
//


import SwiftUI

struct EduaChoosingRight: View {
    @State private var isShowingPage = true;
    
    private let texts = [
        "• Remember, distracting yourself\n through grounding and other\n techniques is a very positive way\n to handle most situations. It is really\n difficult for anxiety to continuously\n impact someone when they keep\n partaking in fun tasks to distract\n themselves.",
        "• Focus on why you’re doing the\n coping mechanism. Whether it's\n grounding yourself, practicing\n self love, or relaxing, all\n require a different approach.\n• Mindfulness is great for\n relaxation, affirmations and\n support systems are great for\n self love, and 5/4/3/2/1\n is great for grounding.",
        "• Over time, you’ll get used to using\n different coping mechanisms in\n your life and it’ll be more clear\n when to use which techniques.\n• As usual, breathing exercises\n are the best for calming the body.\n Whenever you experience anxiety,\n you always have the ability to\n relieve the stress with slow\n breathing."]
    
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
                
                Text("Level Five")
                    .glowBorder(color: .black, lineWidth: 2)
                    .font(.system(size: 26, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.bottom, 40)
                
                
                VStack{
                    Text("Choosing the right mechanisms")
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
                        .font(.system(size: 19))
                    
                    TabView{
                        ForEach(0..<texts.count, id: \.self) { index in
                            VStack {
                                Text(texts[index])
                                    .glowBorder(color: .black, lineWidth: 2)
                                    .font(.system(size: 15))
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
                        LinearGradient(colors: [sColor3, eColor4], startPoint: .top, endPoint: .bottom)
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
            
            if isShowingPage {
                ZStack{
                    VStack {
                        Spacer()
                        Text("Let’s learn more about choosing the\nright coping mechanisms. This will\nhelp you respond very positively\nto situations that come up.")
                            .glowBorder(color: .black, lineWidth: 2)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .background(
                                Rectangle()
                                    .foregroundColor(Color(hex: "677072"))
                                    .opacity(0.53)
                                    .cornerRadius(30.0)
                                    .overlay(RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.black, lineWidth: 1))
                                    .frame(width: 300, height: 240)
                            )
                            .padding(.bottom, 70)
                        
                        Button("Continue"){
                            withAnimation{
                                isShowingPage.toggle()
                            }
                        }
                        .glowBorder(color: .black, lineWidth: 2)
                        .background(
                            EllipticalGradient(colors: [sColor5, eColor6], center: .center)
                                .cornerRadius(15.0)
                                .overlay(RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.black, lineWidth: 1))
                                .frame(width: 200, height: 50)
                        )
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .offset(y: 60)
                        
                        Spacer()
                    }
                    .transition(.scale)
                    .background(
                        LinearGradient(colors: [sColor, eColor], startPoint: .top, endPoint: .bottom)
                            .cornerRadius(30.0)
                            .overlay(RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.black, lineWidth: 1))
                            .frame(width: 340, height: 425)
                            .opacity(0.9)
                            .offset(y:20)
                    )
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
    }
}

struct EduaChoosingRight_Previews: PreviewProvider {
    static var previews: some View {
        EduaChoosingRight()
    }
}


