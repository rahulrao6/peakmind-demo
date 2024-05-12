//
//  MiniQuizView.swift
//  peakmind-mvp
//
//  Created by James Wilson on 5/9/24.
//

import SwiftUI
import FirebaseFirestore

struct ScenarioQuizView: View {
    let titleText = "Mt. Anxiety: Level Two"
    let narrationText = "Which of the following isn’t a symptom of anxiety?"
    @State private var animatedText = ""
    @State private var popupText = ""
    @State private var answerShown = false
    let options = [
        "Box Breathing",
        "Drinking Alcohol",
        "Progressive Muscle Relaxation",
        "Ignore the Anxiety"
    ]
    let responses = [
        "Great choice! Doing breathing exercises will help Johnny relieve his anxiety and have a more mindful following day.)",
        "Drinking alcohol is not an effective way to cope. It suppresses emotions and makes it difficult to find mental clarity",
        "Great choice! Progressive Muscle Relaxation will help Johnny stop the muscle tensing and cause him to feel more relaxed for tomorrow.",
        "This is a poor choice for Johnny because he will be even more anxious tomorrow."
    ]
    @State private var selectedOption: Int? = nil
    @State var navigateToNext = false
    @State private var buttonOpacities = [0.0,0.0,0.0,0.0]


    var body: some View {
        ZStack {
            Image("MainBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(width: 140)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
                .offset(x: 25, y: 20)
            VStack(spacing: 20) {
                Text(titleText)
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.top, 50)
                    .padding(.horizontal)
                
                VStack(alignment: .center) {
                    Text("Scenario")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                    Text("Johnny is coming home from a rough day at work. He’s experiencing muscle tensing and anxiety about going to work the next day.")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.leading)
                        .padding(.trailing)
                        .padding(.bottom)
                        .animation(nil)
                        
                    
                    
                }
                .background(Color(hex: "#0f075a"))
                .cornerRadius(15)
                .animation(.easeInOut)
                .padding(.horizontal, 40)
                .onAppear {
                    animateText()
                }
                
                VStack(spacing: 20) {
                    ForEach(0..<2, id: \.self) { row in
                        HStack(spacing: 20) {
                            ForEach(0..<2, id: \.self) { col in
                                let index = row * 2 + col
                                Button(action: {
                                    selectedOption = index
                                    
                                    print(options[index])
                                    print(responses[index])
                                    
                                    popupText = responses[index]
                                    
                                    answerShown = true
                                }) {
                                    Text(options[index])
                                        .fontWeight(.light)
                                        .padding(.top, 30)
                                        .padding(.bottom, 30)
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.white)
                                        .background(Color(hex: "#080331"))
                                        .cornerRadius(15)
                                        .opacity(buttonOpacities[index])
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
                .padding(.top, 20)
                
                /*
                NavigationLink(destination: SetHabits().navigationBarBackButtonHidden(true).environmentObject(viewModel), isActive: $navigateToNext) {
                    EmptyView()
                }
                 */
                 
                
                Spacer()
            }
            .overlay {
                Spacer()
                VStack(alignment: .center) {
                    Text(popupText)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .animation(nil)
                        .padding(.top, 30)

                        
                    
                    Button(action: {
                        // put action here
                    }) {
                        Text("Continue")
                            .fontWeight(.light)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .background(Color(hex: "#080331"))
                            .cornerRadius(15)
                    }
                    .padding()
                }
                .background(Color(hex: "#0f075a"))
                .cornerRadius(15)
                .padding(.horizontal, 40)
                .padding([.top, .bottom], 300)
                .background {
                    Color.clear
                        .background(.ultraThinMaterial)
                        .environment(\.colorScheme, .dark)
                }
                .opacity(answerShown ? 1 : 0)
                .animation(.easeInOut)
                .edgesIgnoringSafeArea(.all)
                Spacer()
            }
            
            
            
            
            
        }
    }
    
    private func animateText() {
        var charIndex = 0.0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            let roundedIndex = Int(charIndex)
            if roundedIndex < narrationText.count {
                let index = narrationText.index(narrationText.startIndex, offsetBy: roundedIndex)
                animatedText.append(narrationText[index])
            }
            charIndex += 1
            if roundedIndex >= narrationText.count {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        buttonOpacities[0] = 1
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        buttonOpacities[1] = 1
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        buttonOpacities[2] = 1
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        buttonOpacities[3] = 1
                    }
                }
            }
        }
        timer.fire()
    }
    
     
}

struct ScenarioQuizView_Previews: PreviewProvider {
    static var previews: some View {
        ScenarioQuizView()
    }
}
