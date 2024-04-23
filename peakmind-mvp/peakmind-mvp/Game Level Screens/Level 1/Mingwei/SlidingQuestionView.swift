//
//  SlidingQuestionView.swift
//  peakmind-mvp
//
//  Created by Mingwei Li on 4/21/24.
//

import SwiftUI

struct SlidingQuestionView: View {
    @State private var sliderValues: [Double] = [0, 0, 0, 0]
    @State private var activeSlider = 0
    
    let questions: [String] = [
            "I feel comfortable when I am alone at home \n(from disagree to agree)",
            "I get anxious in social situations with others \n(from disagree to agree)",
            "Thinking about going into work makes me anxious \n(from disagree to agree)",
            "Other family members have anxiety similar to myself (from disagree to agree)"
    ]
    
    var body: some View {
        ZStack {
            Image("MainBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
                .offset(x: 5, y: 30)
            VStack {
                

                Text("—— Mt. Anxiety ——\n          Level One")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()

                ForEach(0..<sliderValues.count, id: \.self) { index in
                    if index <= activeSlider {
                        VStack {
                            Text(questions[index])
                                .foregroundColor(.white)
                                .padding(.bottom, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: 6.0)
                                        .foregroundColor(Color(hex: "366093"))
                                        .opacity(0.8)
                                        
                                        .frame(width: 390,height: 50)
                                )

                            Slider(value: $sliderValues[index], in: 0...1, minimumValueLabel: Text(""), maximumValueLabel: Text("")) {
                                Text("")
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 6.0)
                                    .foregroundColor(Color(hex: "1E90FF"))
                                    .opacity(0.3)
                                    
                                    .frame(width: 350,height: 40)
                            )
                            .accentColor(.white)
                            .padding()
                        }
                        .transition(.move(edge: .leading))
                    }
                }
                Spacer()
                HStack {
                    VStack {
                        Text("Let's look at this\n scenario and see\n what you should do")
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .background(
                                RoundedRectangle(cornerRadius: 6.0)
                                    .foregroundColor(Color(hex: "1E4E96"))
                                    .opacity(0.8)
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 1.5))
                                    .frame(width: 160,height: 80)
                            )
                            .font(.system(size: 15))
                            .padding(.leading, 130)
                        Text("Tap to Continue")
                            .foregroundColor(.white)
                            .opacity(0.5)
                            .padding(.leading, 250)
                            .padding(.top, 20)
                    }
                    Spacer()
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).delay(0.3)) {
                    activeSlider = 1
                }
                withAnimation(.easeInOut(duration: 1.0).delay(0.6)) {
                    activeSlider = 2
                }
                withAnimation(.easeInOut(duration: 1.0).delay(0.9)) {
                    activeSlider = 3
                }
                withAnimation(.easeInOut(duration: 1.0).delay(1.2)) {
                    activeSlider = 4
                }
        }
        }
    }
}

struct SlidingQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        SlidingQuestionView()
    }
}

