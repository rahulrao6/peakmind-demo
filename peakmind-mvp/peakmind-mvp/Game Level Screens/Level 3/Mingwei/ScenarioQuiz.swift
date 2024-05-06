//
//  ScenarioQuiz.swift
//  peakmind-mvp
//
//  Created by Mingwei Li on 5/5/24.
//

import SwiftUI

struct ScenarioQuiz: View {
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
                    Text("Scenario")
                        .glowBorder(color: .black, lineWidth: 2)
                        .background(
                            Rectangle()
                                .foregroundColor(Color(hex: "004FAC"))
                                .opacity(0.8)
                                .cornerRadius(11.1)
                                .overlay(RoundedRectangle(cornerRadius: 11.1)
                                    .stroke(Color.black, lineWidth: 2))
                                .frame(width: 99, height: 30)
                        )
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .padding(.bottom, 10)
                    
                    Text("Johnny is coming home from a\nrough day at work. He’s\nexperiencing muscle tensing and\nanxiety about going to work the\nnext day.")
                        .glowBorder(color: .black, lineWidth: 2)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .background(
                            Rectangle()
                                .foregroundColor(Color(hex: "677072"))
                                .opacity(0.33)
                                .cornerRadius(20.0)
                                .overlay(RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 1))
                                .frame(width: 266, height: 132)
                        )
                        .padding(.bottom, 70)
                }
                .background(
                    LinearGradient(colors: [sColor, eColor], startPoint: .top, endPoint: .bottom)
                        .cornerRadius(30.0)
                        .overlay(RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.black, lineWidth: 1))
                        .frame(width: 320, height: 182)
                        .opacity(0.8)
                        .offset(y: -33)
                )
                .padding()
                .offset(y: -35)
                VStack{
                    HStack{
                        Button("Box\nBreathing"){
                            
                        }
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .bold()
                            .glowBorder(color: .black, lineWidth: 1)
                            .multilineTextAlignment(.center)
                            .background(
                                EllipticalGradient(colors: [sColor3, eColor4], center: .center)
                                    .cornerRadius(30.0)
                                    .overlay(RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.black, lineWidth: 1))
                                    .frame(width: 83, height: 75)
                            )
                            .padding()
                        
                        Button("Drinking\nAlcohol"){
                            
                        }
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .bold()
                            .glowBorder(color: .black, lineWidth: 1)
                            .multilineTextAlignment(.center)
                            .background(
                                EllipticalGradient(colors: [sColor3, eColor4], center: .center)
                                    .cornerRadius(30.0)
                                    .overlay(RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.black, lineWidth: 1))
                                    .frame(width: 83, height: 75)
                            )
                            .padding()
                    }
                    
                    HStack{
                        Button("Progressive\nMuscle\nRelaxation"){
                            
                        }
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .bold()
                            .glowBorder(color: .black, lineWidth: 1)
                            .multilineTextAlignment(.center)
                            .background(
                                EllipticalGradient(colors: [sColor3, eColor4], center: .center)
                                    .cornerRadius(30.0)
                                    .overlay(RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.black, lineWidth: 1))
                                    .frame(width: 83, height: 75)
                            )
                            .padding()
                        
                        Button("Ingnore\nAnxiety"){
                            
                        }
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .bold()
                            .glowBorder(color: .black, lineWidth: 1)
                            .multilineTextAlignment(.center)
                            .background(
                                EllipticalGradient(colors: [sColor3, eColor4], center: .center)
                                    .cornerRadius(30.0)
                                    .overlay(RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.black, lineWidth: 1))
                                    .frame(width: 83, height: 75)
                            )
                            .padding()
                            .offset(x: -6)
                    }
                }
                .background(
                    LinearGradient(colors: [sColor, eColor], startPoint: .top, endPoint: .bottom)
                        .cornerRadius(12.64)
                        .overlay(RoundedRectangle(cornerRadius: 12.64)
                            .stroke(Color.black, lineWidth: 1))
                        .frame(width: 220, height: 196)
                        .opacity(0.8)
                )
                .offset(y: -80)
                
                
                Text("Choose the best\noption")
                    .multilineTextAlignment(.center)
                    .glowBorder(color: .black, lineWidth: 2)
                    .background(
                        LinearGradient(colors: [eColor, sColor], startPoint: .top, endPoint: .bottom)
                            .cornerRadius(15.0)
                            .overlay(RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black, lineWidth: 1))
                            .frame(width: 207, height: 88)
                    )
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .offset(x: 60)
                    .lineSpacing(10.0)
                
                Spacer()
            }
        }
    }
}

struct ScenarioQuiz_Previews: PreviewProvider {
    static var previews: some View {
        ScenarioQuiz()
    }
}
