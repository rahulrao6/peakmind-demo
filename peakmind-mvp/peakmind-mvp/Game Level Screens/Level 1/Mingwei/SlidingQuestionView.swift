//
//  SlidingQuestionView.swift
//  peakmind-mvp
//
//  Created by Mingwei Li on 4/21/24.
//

import SwiftUI

struct SlidingQuestionView: View {
    @State private var sliderValues: [Double] = [0, 0, 0, 0]
    @State private var activeSlider = 0 // To control which slider is currently shown

    var body: some View {
        ZStack {
            Image("MainBG") // Replace with your background asset name
                .resizable()
                .edgesIgnoringSafeArea(.all)
            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
                .offset(x: 5, y: 20)
            VStack {
                

                Text("—— Mt. Anxiety ——\n          Level One")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()

                ForEach(0..<sliderValues.count, id: \.self) { index in
                    if index <= activeSlider {
                        VStack {
                            Text("Question")
                                .foregroundColor(.white)
                                .padding(.bottom, 5)
                                .font(.title2)
                                

                            Slider(value: $sliderValues[index], in: 0...1, minimumValueLabel: Text(""), maximumValueLabel: Text("")) {
                                Text("")
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 6.0)
                                    .foregroundColor(Color(hex: "1E90FF"))
                                    .opacity(0.8)
                                    
                                    .frame(width: 350,height: 40)
                            )
                            .accentColor(.white)
                            .padding()
                        }
                        .transition(.move(edge: .leading))
                    }
                }

                HStack {
                    VStack {
                        Spacer()
                        Text("Let's look at this\n scenario and see\n what you should do")
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .background(
                                RoundedRectangle(cornerRadius: 6.0)
                                    .foregroundColor(Color(hex: "1E4E96"))
                                    .opacity(0.8)
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 1.5))
                                    .frame(width: 190,height: 90)
                            )
                            .font(.system(size: 17))
                            .padding(.leading, 130)
                            .padding(.bottom, 10)
                        Text("Tap to Continue")
                            .foregroundColor(.white)
                            .opacity(0.5)
                            .padding(.leading, 250)
                            .padding(.top, 60)
                    }
                    Spacer()
                }
                .padding(.bottom)
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

