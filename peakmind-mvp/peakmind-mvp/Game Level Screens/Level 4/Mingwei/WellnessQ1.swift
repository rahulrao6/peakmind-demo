//
//  WellnessQ1.swift
//  peakmind-mvp
//
//  Created by Mingwei Li on 5/13/24.
//

import SwiftUI

struct WellnessQ1: View {
    
    let sColor: Color = Color(hex: "6EADF0") ?? .white;
    let eColor: Color = Color(hex: "044F9E") ?? .white;
    let sColor3: Color = Color(hex: "B3DEF7") ?? .white;
    let eColor4: Color = Color(hex: "4CB9F8") ?? .white;
    
    @State private var answer: String = ""
    var body: some View {
        ZStack{
            Image("MainBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
            VStack {
                Text("—— Mt. Anxiety ——")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .glowBorder(color: .black, lineWidth: 2)
                
                
                Text("Level Four")
                    .glowBorder(color: .black, lineWidth: 2)
                    .font(.system(size: 26, weight: .bold, design: .default))
                    .foregroundColor(.white)
                VStack{
                    
                    Text("What do you find to be most helpful\n with high stress situations?")
                        .glowBorder(color: .black, lineWidth: 2)
                        .background(
                            Rectangle()
                                .foregroundColor(Color(hex: "4A9AE4"))
                                .opacity(0.8)
                                .cornerRadius(15)
                                .overlay(RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.black, lineWidth: 2))
                                .frame(width: 289, height: 73)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .padding()
                        .padding(.bottom, 30)
                        .shadow(radius: 5)
                        .bold()
                        .italic()   
                    
                    TextField(text: $answer, prompt: Text("Enter text here").foregroundStyle(.white).bold()){
                        
                    }
                    .offset(x:-55, y: -55)
                    .glowBorder(color: .black, lineWidth: 2)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .background(
                        Rectangle()
                            .foregroundColor(Color(hex: "677072"))
                            .opacity(0.33)
                            .cornerRadius(15)
                            .overlay(RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black, lineWidth: 1))
                            .frame(width: 253, height: 153)
                    )
                    .padding(.top, 40)
                    .padding(.bottom, 70)
                    
                    
                    Button("Submit"){
                        
                    }
                    .glowBorder(color: .black, lineWidth: 2)
                    .background(
                        EllipticalGradient(colors: [sColor3, eColor4], center: .center)
                            .cornerRadius(15.0)
                            .overlay(RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black, lineWidth: 1))
                            .frame(width: 225, height: 49)
                    )
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 20)
                }
                .background(
                    LinearGradient(colors: [sColor, eColor], startPoint: .top, endPoint: .bottom)
                        .cornerRadius(30)
                        .overlay(RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.black, lineWidth: 1))
                        .frame(width: 320, height: 337)
                        .opacity(0.8)
                        .offset(y:5)
                )
                .padding(.bottom, 40)
                .padding(.top, 70)
                
                Text("Please Answer Truthfully!")
                    .glowBorder(color: .black, lineWidth: 2)
                    .background(
                        LinearGradient(colors: [eColor, sColor], startPoint: .top, endPoint: .bottom)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 2))
                            .frame(width: 232, height: 57)
                            .opacity(0.8)
                    )
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .bold()
                    .italic()
                    .padding()
                    .offset(x: 20, y:30)
                
                Spacer()
            }
            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(width: 115)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
                .offset(x: 7, y: 20)
        }
    }
}

struct WellnessQ1_Previews: PreviewProvider {
    static var previews: some View {
        WellnessQ1()
    }
}

