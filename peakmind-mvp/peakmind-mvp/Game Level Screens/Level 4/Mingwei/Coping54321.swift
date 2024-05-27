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
    @State private var currentStep = 1
    
    let sColor: Color = Color(hex: "012649") ?? .white;
    let eColor: Color = Color(hex: "004FAC") ?? .white;
    let sColor3: Color = Color(hex: "6EADF0") ?? .white;
    let eColor4: Color = Color(hex: "044F9E") ?? .white;
    let sColor5: Color = Color(hex: "B3DEF7") ?? .white;
    let eColor6: Color = Color(hex: "4CB9F8") ?? .white;
    
    @State private var answers: [Int: [String]] = [:];
    
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
                    ZStack{
                        Text(promptText)
                            .glowBorder(color: .black, lineWidth: 3)
                            .background(
                                Rectangle()
                                    .foregroundColor(Color(hex: "677072"))
                                    .opacity(0.33)
                                    .cornerRadius(20)
                                    .overlay(RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.black, lineWidth: 2))
                                    .frame(width: 253, height: 59)
                                    .shadow(radius: 10, y: 10)
                            )
                            .background(
                                LinearGradient(colors: [sColor3, eColor4], startPoint: .top, endPoint: .bottom)
                                    .cornerRadius(30)
                                    .overlay(RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.black, lineWidth: 1))
                                    .frame(width: 320, height: 82)
                                    .opacity(0.7)
                            )
                            .foregroundColor(.white)
                            .font(currentStep == 5 ? .system(size: 12):.system(size: 16))
                            .offset(y: -140)
                            .multilineTextAlignment(.center)
                        
                        VStack{
                            ForEach(0..<boxesCount, id: \.self) { index in
                                HStack{
                                    Text("\(index + 1).")
                                        .foregroundStyle(.white)
                                        .background(
                                            RadialGradient(colors: [sColor, eColor4], center: .center, startRadius: 1, endRadius: 15)
                                                .cornerRadius(15)
                                                .overlay(RoundedRectangle(cornerRadius: 15)
                                                    .stroke(Color.black, lineWidth: 2))
                                                .frame(width: 36, height: 38)
                                                .opacity(0.5)
                                        )
                                    .bold()
                                    .padding(.trailing, 9)
                                    .padding(.leading, 6)
                                    
                                    TextField("Enter text here", text: Binding(
                                        get: {
                                            answers[currentStep, default: Array(repeating: "", count: boxesCount)][index]
                                        },
                                        set: { newValue in
                                            var stepAnswers = answers[currentStep, default: Array(repeating: "", count: boxesCount)]
                                            stepAnswers[index] = newValue
                                            answers[currentStep] = stepAnswers
                                        }
                                    ))
                                    .bold()
                                    .textFieldStyle(.plain)
                                    .padding(.bottom, 20)
                                    .background(
                                        Rectangle()
                                            .foregroundColor(Color(hex: "677072"))
                                            .opacity(0.33)
                                            .cornerRadius(20)
                                            .overlay(RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.black, lineWidth: 2))
                                            .frame(width: 253, height: 45)
                                            .shadow(radius: 10, y: 10)
                                            .offset(x: -13, y: -10)
                                    )
                                    .offset(x: 10, y: 10)
                                }
                            }
                            .offset(y: (-53 - 26.30 * (5 - CGFloat(boxesCount))))
                        }
                        .background(
                            LinearGradient(colors: [sColor3, eColor4], startPoint: .top, endPoint: .bottom)
                                .cornerRadius(30)
                                .overlay(RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.black, lineWidth: 1))
                                .frame(width: 333, height: 387)
                                .opacity(0.8)
                        )
                        .frame(width: 300, height: 300)
                        .offset(y: 100)
                        
                        Button(action: {
                            if currentStep < 5 {
                                currentStep += 1
                            }
                        }) {
                            Text("Continue")
                                .glowBorder(color: .black, lineWidth: 2)
                                .background(
                                    EllipticalGradient(colors: [sColor5, eColor6], center: .center)
                                        .cornerRadius(15.0)
                                        .overlay(RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.black, lineWidth: 1))
                                        .frame(width: 203.7, height: 44.37)
                                )
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                        }
                        .offset(y: 250)
                    }
                }
                
                
                Spacer()
            }
            
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
                            .font(.system(size: 15))
                        
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
                        .offset(x: 18, y: -130)
                }
            }
        }
    }
    
    private var boxesCount: Int {
            switch currentStep {
            case 1: return 5
            case 2: return 4
            case 3: return 3
            case 4: return 2
            case 5: return 1
            default: return 5
            }
        }

        private var promptText: String {
            switch currentStep {
            case 1: return "- Let's begin! What are five\nthings you can see in your\nsurroundings?"
            case 2: return "Next, what are four things\nyou can touch around you?"
            case 3: return "Now, what are three things\nyou can hear?"
            case 4: return "Great job, what are two\nthings you can smell?"
            case 5: return "Lastly, what is one thing you can taste?\nYou should feel more grounded and in\ntune with your surroundings now."
            default: return "- Let's begin! What are five\nthings you can see in your\nsurroundings?"
            }
        }
}




struct Coping54321_Previews: PreviewProvider {
    static var previews: some View {
        Coping54321()
    }
}
