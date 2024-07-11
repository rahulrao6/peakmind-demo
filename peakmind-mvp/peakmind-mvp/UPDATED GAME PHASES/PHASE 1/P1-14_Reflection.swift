//
//  P1-14_Reflection.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 4/21/24.
//

import SwiftUI


struct P1_14_Reflection: View {
    let reflectionTexts: [String] = ["In this phase, we learned about anxiety as a concept and how it can affect us.", "We worked through some scenarios to better understand anxiety as well as learned some new ways to help our anxiety such as box breathing."]
    var closeAction: () -> Void

    var body: some View {
        
            VStack {
                Text("Mt. Anxiety: Phase One")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .padding(.bottom, 40)
                
                VStack {
                    Text("Reflection")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 2)
                        .padding(11)
                        .background(Color("Navy Blue"))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.black, lineWidth: 2)
                        )
                        .padding(.top, 20)
                    TabView {
                        ForEach(reflectionTexts.indices, id: \.self) { index in
                            Text("\(reflectionTexts[index])")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(20)
                                .background(Color(hex: "677072").opacity(0.33))  // Adjusted color for the inner box
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.black, lineWidth: 2)
                                )
                                .cornerRadius(12)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: 200)
                    Button(action: {closeAction()}) {
                        Text("Continue")
                    }
                    // Spacer()
                    
                }
                .padding([.horizontal, .bottom], 30)
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
                .cornerRadius(50)
                .shadow(color: .black.opacity(0.5), radius: 5, x: 3, y: 3)  // Added drop shadow here
                .padding(.horizontal, 20)
                
                SherpaTalking(speech: "Let's review what you have learned!", closeAction: closeAction, showBack: false)
            }
            .background(Background())
        
    }
}

//struct P1_14_Reflection_Previews: PreviewProvider {
//    static var previews: some View {
//        P1_14_Reflection()
//    }
//}
