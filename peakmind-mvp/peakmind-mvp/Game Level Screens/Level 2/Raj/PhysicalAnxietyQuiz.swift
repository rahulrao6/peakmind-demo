//
//  NightfallFlavorView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/17/24.
//

import SwiftUI
import FirebaseFirestore
//SCREEN FOUR
struct PhysicalAnxietyQuiz: View {
    @EnvironmentObject var viewModel: AuthViewModel
    let titleText = "Mt. Anxiety: Level Two"
    let narrationText = "Which of the following ways is not a symptom of anxiety?"
    @State private var animatedText = ""
    let options = [
        "Muscle Tensing",
        "Rapid Breathing",
        "Fevers",
        "Nausea"
    ]
    
    @State private var selectedOption: Int? = nil
    @State private var correctAnswerIndex = 2 // Index of the correct answer
    @State private var isAnswered = false // Flag to check if an option is already selected
    @State private var isCorrect = false // Flag to check if the selected option is correct

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
                    Text(animatedText)
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .onAppear {
                            animateText()
                        }
                }
                .background(Color("Dark Blue"))
                .cornerRadius(15)
                .padding(.horizontal, 40)

                VStack(spacing: 20) {
                    ForEach(0..<2, id: \.self) { row in
                        HStack(spacing: 20) {
                            ForEach(0..<2, id: \.self) { col in
                                let index = row * 2 + col
                                let option = options[index]
                                Button(action: {
                                    if !isAnswered {
                                        selectedOption = index
                                        isAnswered = true
                                        isCorrect = index == correctAnswerIndex
                                    }
                                }) {
                                    Text(option)
                                        .fontWeight(.semibold)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.white)
                                        .background(isAnswered && selectedOption == index ? (isCorrect ? Color.green : Color.red) : Color("Dark Blue"))
                                        .cornerRadius(15)
                                        .disabled(isAnswered)
                                }
                                .overlay(
                                    Group {
                                        if isAnswered && !isCorrect && correctAnswerIndex == index {
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.green, lineWidth: 2)
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
                .padding(.top, 20)
                Spacer()
                if isAnswered {
                    
                    VStack(alignment: .trailing) {
                        Spacer()
                        if (isAnswered && isCorrect){
                            Text("You got it right!")
                                .fontWeight(.semibold)
                                .padding()
                                .frame(maxWidth: 200)
                                .foregroundColor(.white)
                                .background(Color.green)
                                .cornerRadius(15)
                                .padding(.horizontal, 40)
                        } else {
                            Text("You got it wrong!")
                                .fontWeight(.semibold)
                                .padding()
                                .frame(maxWidth: 200)
                                .foregroundColor(.white)
                                .background(Color.red)
                                .cornerRadius(15)
                                .padding(.horizontal, 40)
                        }
                        Spacer()
                        Button(action: {
                            // Move to the next screen
                        }) {
                            Text("Next")
                                .fontWeight(.semibold)
                                .padding()
                                .frame(maxWidth: 200)
                                .foregroundColor(.white)
                                .background(Color.darkBlue)
                                .cornerRadius(15)
                                .padding(.horizontal, 40)
                        }
                    
                    }
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)

                }
                
                Spacer()
            }
        }
    }
    
    private func animateText() {
        var charIndex = 0.0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            let roundedIndex = Int(charIndex)
            if roundedIndex < narrationText.count {
                let index = narrationText.index(narrationText.startIndex, offsetBy: roundedIndex)
                animatedText.append(narrationText[index])
            }
            charIndex += 1
            if roundedIndex >= narrationText.count {
                timer.invalidate()
            }
        }
        timer.fire()
    }
}


struct PhysicalAnxietyQuiz_Previews: PreviewProvider {
    static var previews: some View {
        PhysicalAnxietyQuiz()
    }
}
 
