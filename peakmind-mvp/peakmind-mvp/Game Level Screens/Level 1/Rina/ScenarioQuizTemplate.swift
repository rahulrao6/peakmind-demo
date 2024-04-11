//
//  ScenarioQuiz.swift
//  peakmind-mvp
//
//  Created by Katharina Reimer on 4/10/24.
//

import SwiftUI

struct ScenarioQuizTemplate<nextView: View>: View {
    let titleText: String
    let questionText: String
    let options: [String]
    @State private var selectedOption: Int? = nil
    @State private var buttonOpacities = [0.0,0.0,0.0,0.0]
    @State private var correctAnswerIndex = 2 // Index of the correct answer
    @State private var isAnswered = false // Flag to check if an option is already selected
    @State private var isCorrect = false // Flag to check if the selected option is correct
    @State var sherpaSpeech: String = ""
    var nextScreen: nextView
    
    var body: some View {
        VStack {
            Text(titleText)
                .font(.system(size: 34, weight: .bold, design: .default))
                .foregroundColor(.white)
                .padding(.top, 50)
                .padding(.horizontal)
            
            Text(questionText)
                .bold()
                .foregroundStyle(.white)
                .shadow(color: .black, radius: 2)
                .padding()
                .background(.blue)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.black, lineWidth: 2)
                )
            
            
            // Quiz section
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
                if isAnswered {
                    NavigationLink {
                        
                    } label: {
                        Text("Next")
                            .padding()
                            .shadow(color: .black, radius: 2)
                            .foregroundColor(.white)
                            .background(.iceBlue)
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.black, lineWidth: 2)
                            )
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
            .padding(.top, 20)
            .background(LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .top, endPoint: .bottom))
            .cornerRadius(25)
            // End Quiz section
            
            if isAnswered {
                if isCorrect {
                    SherpaTalking(speech: "You got it right!")
                } else {
                    SherpaTalking(speech: "You got it wrong!")
                }
            } else {
                SherpaAlone()
            }

        }
        .background(Background())
    }
}

#Preview {
    ScenarioQuizTemplate(titleText: "Mt. Anxiety Level One",
                         questionText: "How can Alex best manage his stress?",
                         options: [
                            "Overwork",
                            "Meditate",
                            "Avoid",
                            "Isolate"
                        ],
                         nextScreen: VStack{})
}
