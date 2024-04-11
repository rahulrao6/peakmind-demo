//
//  ScenarioTemplate.swift
//  peakmind-mvp
//
//  Created by Katharina Reimer on 4/10/24.
//

import SwiftUI

struct ScenarioTemplate<nextView: View>: View {
    let titleText: String
    let scenarioText: String
    var nextScreen: nextView
    
    var body: some View {
        VStack{
            Text(titleText)
                .font(.system(size: 34, weight: .bold, design: .default))
                .foregroundColor(.white)
                .padding(.top, 50)
                .padding(.horizontal)
            
            // Text Box
            VStack {
                Text("Scenario Time!")
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
                
                Text(scenarioText)
                    .foregroundStyle(.white)
                    .padding()
                
                Spacer()
                
                NavigationLink {
                    nextScreen
                } label: {
                    Text("Proceed to quiz")
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 2)
                        .padding()
                        .background(.blue)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.black, lineWidth: 2)
                        )
                }
                
            }
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .top, endPoint: .bottom))
            .cornerRadius(25)
            
            
            SherpaTalking(speech: "Let's look at this scenario and see what you should do!")
        }
        .background(Background())
    }
}

#Preview {
    ScenarioTemplate(titleText: "Mt. Anxiety Level One",
                     scenarioText: "Alex feels very stressed out about a deadline coming up in a few days. Alex is overwhelmed with everything.",
                     nextScreen: VStack{})
}
