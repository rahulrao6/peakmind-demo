//
//  MiniQuizView.swift
//  peakmind-mvp
//
//  Created by James Wilson on 5/9/24.
//

import SwiftUI
import FirebaseFirestore

struct ResilienceChecklistView: View {
    let titleText = "Mt. Anxiety: Level Two"
    let narrationText = "Which of the following isn’t a symptom of anxiety?"
    @State private var animatedText = ""
    @State private var popupText = ""
    @State private var answerShown = false
    let options = [
        "Taking breaks from devices",
        "Regular gratitude",
        "Forgiveness of your mistakes",
        "Eating 3 meals a day",
        "Sleep 8+ hours a night",
        "Exercise at least 3x/week"
    ]
    @State private var selectedOption: Int? = nil
    @State var navigateToNext = false
    @State private var buttonOpacities = [0.0,0.0,0.0,0.0,0.0,0.0]


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
                    Text("Building resilience involves understanding your self care habits. Let’s fill out a checklist to help you learn what is currently working best in your life.")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .animation(nil)
                        
                    
                    
                }
                .background(Color(hex: "#0f075a"))
                .cornerRadius(15)
                .animation(.easeInOut)
                .padding(.horizontal, 40)
                .onAppear {
                    animateText()
                }
                
                VStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { row in
                        HStack(spacing: 20) {
                            ForEach(0..<2, id: \.self) { col in
                                let index = row * 2 + col
                                Button(action: {
                                    selectedOption = index
                                    
                                    print(options[index])
                                                                        
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        buttonOpacities[4] = 1
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        buttonOpacities[5] = 1
                    }
                }
            }
        }
        timer.fire()
    }
    
     
}

struct ResilienceChecklistView_Previews: PreviewProvider {
    static var previews: some View {
        ResilienceChecklistView()
    }
}
