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
    var closeAction: () -> Void

    
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
                .background(Color("Dark Blue"))
                .cornerRadius(16)
                .multilineTextAlignment(.center)  // Center align text
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.black, lineWidth: 2)
                )
                .padding(.bottom, 20)

            
            // Quiz section
            VStack(spacing: 20) {
                ForEach(0..<options.count, id: \.self) { index in  // Changed to loop directly through options
                    Button(action: {
                        if !isAnswered {
                            selectedOption = index
                            isAnswered = true
                            isCorrect = index == correctAnswerIndex
                        }
                    }) {
                        Text(options[index])
                            .fontWeight(.semibold)
                            .padding(12)  // Dynamic padding
                            .frame(minWidth: 100, idealWidth: .infinity, maxWidth: .infinity, alignment: .center)  // Ensuring the button grows
                            .multilineTextAlignment(.center)  // Center align text
                            .foregroundColor(.white)
                            .background(isAnswered && selectedOption == index ? (isCorrect ? Color.green : Color.red) : Color("Dark Blue"))
                            .cornerRadius(15)
                            .disabled(isAnswered)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(isAnswered && selectedOption == index && isCorrect ? Color.green : Color.clear, lineWidth: 2)
                    )
                    // Adding condition for layout in two columns if more than two options
                    .frame(maxWidth: options.count > 2 ? .infinity : nil)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 50)
            .padding(.top, 50)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 110/255, green: 173/255, blue: 240/255),
                        Color(red: 4/255, green: 79/255, blue: 158/255)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .opacity(0.8)
            )
            .cornerRadius(25)
            .padding(.horizontal, 20)



            // End Quiz section
            
            if isAnswered {
                if isCorrect {
                    VStack {
                        SherpaTalking(speech: "You got it right!", closeAction: closeAction, showBack: true)

                    }
                   
                } else {
                    VStack{
                        SherpaTalking(speech: "You got it wrong!", closeAction: closeAction, showBack: true)
                    }
                    

                }
            } else {
                SherpaAlone()
            }

        }
        .background(Background())
    }
}

//#Preview {
//    ScenarioQuizTemplate(titleText: "Mt. Anxiety Level One",
//                         questionText: "How can Alex best manage his stress?",
//                         options: [
//                            "Overwork",
//                            "Meditate",
//                            "Avoid",
//                            "Isolate"
//                        ],
//                         nextScreen: VStack{})
//}
