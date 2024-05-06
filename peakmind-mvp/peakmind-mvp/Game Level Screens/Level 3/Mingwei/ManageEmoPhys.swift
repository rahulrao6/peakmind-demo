//
//  ManageEmoPhys.swift
//  peakmind-mvp
//
//  Created by Mingwei Li on 5/5/24.
//

import SwiftUI

struct ManageEmoPhys: View {
    
    private let texts = ["• There are many different coping mechanisms to\n respond to physical and emotional symptoms.\n Doing something you enjoy such as dancing,\n sports, or swimming to reduce physical anxiety.\n• - Emotionally, it is great to accompany physical\n coping strategies with journaling, affirmations,\n or other mindfulness activities.",
        "• When experiencing anxiety, we are affected\n emotionally, psychologically, physically, and\n spiritually.\n• - Each of these areas involve coping in a\n different style, while some overlap. Finding the\n right balance between coping mechanisms is\n essential.",
    "• Emotionally, talking to others and watching\n your favorite shows or movies can be helpful.\n Psychologically, reading or learning more about\n a topic you like is effective.\n• - Spiritually, giving yourself time for prayer or\n reflection is necessary for mental clarity.\n Physically, staying active, getting rest, and\n breathing exercises are great."]

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
                
                Text("Level Three")
                    .glowBorder(color: .black, lineWidth: 2)
                    .font(.system(size: 26, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.bottom, 40)
                
                
                VStack{
                    Text(" Managing anxiety with physical and emotional effects")
                        .glowBorder(color: .black, lineWidth: 3)
                        .background(
                            Rectangle()
                                .foregroundColor(Color(hex: "2D6AB4"))
                                .opacity(0.8)
                                .cornerRadius(15.0)
                                .overlay(RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.black, lineWidth: 2))
                                .frame(width: 290, height: 48)
                                .shadow(radius: 10, y: 10)
                        )
                        .foregroundColor(.white)
                        .font(.system(size: 11))
                        .padding(.bottom, 5)
                    
                    TabView{
                        ForEach(0..<texts.count, id: \.self) { index in
                            VStack {
                                Text(texts[index])
                                    .bold()
                                    .glowBorder(color: .black, lineWidth: 3)
                                    .font(.system(size: 11))
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

struct ManageEmoPhys_Previews: PreviewProvider {
    static var previews: some View {
        ManageEmoPhys()
    }
}
