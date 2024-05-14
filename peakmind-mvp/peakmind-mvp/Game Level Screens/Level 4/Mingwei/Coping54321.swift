//
//  54321Coping.swift
//  peakmind-mvp
//
//  Created by Mingwei Li on 5/13/24.
//

import SwiftUI

struct Coping54321: View {
    @State private var isShowingPage = true;
    @State private var responses = Array(repeating: "", count: 15)
    @State private var index = 0
    
    let sColor: Color = Color(hex: "012649") ?? .white;
    let eColor: Color = Color(hex: "004FAC") ?? .white;
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
//                    if index == 0 {
//                        PromptScreen(numberOfBoxes: 5, curPage: 0, responses: $responses)
//                            .onContinue{
//                            index += 1;
//                        }
//                    }
                    
                    Text("Physical impacts of anxiety")
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
                    
                    Text("")
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
                        Text("5/4/3/2/1 Technique")
                            .glowBorder(color: .black, lineWidth: 3)
                            .background(
                                EllipticalGradient(colors: [sColor, eColor], center: .center)
                                    .cornerRadius(15.0)
                                    .overlay(RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.black, lineWidth: 2))
                                    .frame(width: 258, height: 33)
                                    .opacity(0.5)
                                )
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                            .padding()
                            .padding(.bottom, 30)
                        Text("Let’s learn about the 5/4/3/2/1\n grounding technique. You’ll point\n out 5 things you can see, 4 things\n you can touch, 3 things you can\n hear, 2 things you can smell, and 1\n thing you can taste. This technique\n is used for grounding yourself\n during panic, crisis, or high anxiety\n level situations.")
                            .glowBorder(color: .black, lineWidth: 2)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                            .background(
                                Rectangle()
                                    .foregroundColor(Color(hex: "677072"))
                                    .opacity(0.53)
                                    .cornerRadius(30.0)
                                    .overlay(RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.black, lineWidth: 1))
                                    .frame(width: 276, height: 280)
                            )
                            .padding(.bottom, 40)
                            .bold()
                        
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
                        .offset(y: 20)
                        
                        Spacer()
                    }
                    .transition(.scale)
                    .background(
                        LinearGradient(colors: [sColor3, eColor4], startPoint: .top, endPoint: .bottom)
                            .cornerRadius(18)
                            .overlay(RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.black, lineWidth: 1))
                            .frame(width: 364, height: 437)
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

struct PromptScreen: View {
    let numberOfBoxes: Int
    let curPage: Int
    @Binding var responses: [String]
    
    var body: some View {
        VStack {
            Text("Please enter \(numberOfBoxes) things you can see")
                .font(.title)
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)
            
            ForEach(0..<numberOfBoxes, id: \.self) { index in
                TextField("Enter something you see", text: $responses[index])
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            
            Button(action: {}) {
                Text("Continue")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct Coping54321_Previews: PreviewProvider {
    static var previews: some View {
        Coping54321()
    }
}
