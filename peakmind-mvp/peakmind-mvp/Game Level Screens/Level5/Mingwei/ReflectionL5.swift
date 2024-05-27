//
//  ReflectionL5.swift
//  peakmind-mvp
//
//  Created by Mingwei Li on 5/18/24.
//

import SwiftUI

struct ReflectionL5: View {
    let sColor: Color = Color(hex: "005D92") ?? .white;
    let eColor: Color = Color(hex: "B6E0F8") ?? .white;
    let sColor3: Color = Color(hex: "6EADF0") ?? .white;
    let eColor4: Color = Color(hex: "044F9E") ?? .white;
    let sColor5: Color = Color(hex: "0771A7") ?? .white;
    let sColor6: Color = Color(hex: "5DBCEF") ?? .white;
    private let texts = ["In this phase you learned so much about building support systems, finding communities, and choosing the right coping mechanisms in your life. You’ve identified your top supporters and how they can best help you in stressful situations. You’ve successfully worked through many different activities to build and find your support network. Throughout mount anxiety, we went through plenty of coping mechanisms, educational modules, and other activities. You did an amazing job and now have a tool box to better handle your anxiety!"]
    
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
                
                Text("Level Five")
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
                            .frame(width: 320, height: 280)
                            .shadow(radius: 10, y: 10)
                    )
                    .frame(width: 300, height: 300)
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                    .offset(y: -0)
                    
                    Button("Proceed to Quiz"){
                        
                    }
                    .glowBorder(color: .black, lineWidth: 2)
                    .background(
                        LinearGradient(colors: [eColor, sColor6, sColor5], startPoint: .top, endPoint: .bottom)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 1))
                            .frame(width: 177, height: 41)
                    )
                    .font(.title2)
                    .foregroundColor(.white)
                    .offset(y: 20)
                }
                .background(
                    LinearGradient(colors: [sColor3, eColor4], startPoint: .top, endPoint: .bottom)
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black, lineWidth: 1))
                        .frame(width: 340, height: 457)
                        .opacity(0.8)
                        .offset(y: 0)
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

struct ReflectionL5_Previews: PreviewProvider {
    static var previews: some View {
        ReflectionL5()
    }
}
