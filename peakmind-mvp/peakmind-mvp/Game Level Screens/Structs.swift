//
//  Structs.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 5/24/24.
//

import SwiftUI

struct ReflectiveQuestionBox: View {
    @Binding var userAnswer: String
    @Binding var question: String

    var body: some View {
        VStack(spacing: 10) {
            // Question Header
            Text("Reflective Question")
                .modernTextStyle()
            
            // Question Text
            Text(question)
                .font(.title2)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.vertical, 10)
            
            // Answer TextField
            TextEditor(text: $userAnswer)
                .padding(10) // You can adjust padding as needed
                .frame(height: 180) // Adjust the height as necessary
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 10)
                .padding(.horizontal, 20)
                .padding(.bottom, 25)

        }
        .background(Color("SentMessage"))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
}

struct SubmitButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Submit")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(LinearGradient(gradient: Gradient(colors: [Color("Ice Blue"), Color("Medium Blue")]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(15)
                .shadow(radius: 5)
        }
        .padding(.horizontal)
        .transition(.scale)
    }
}

struct ThankYouMessage: View {
    var body: some View {
        Text("Thank You!")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .scaleEffect(1.5)
            .opacity(1.0)
            .transition(.opacity.combined(with: .scale))
    }
}

struct TruthfulPrompt: View {
    var body: some View {
        HStack {
            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(width: 120)
                .offset(x: 0, y: 20)

            Text("Please answer truthfully.")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color("Medium Blue"))
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .padding(.top, 20) // Add padding to the top of the HStack

    }
}

extension Text {
    func modernTextStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity)
            .background(Color("Medium Blue"))
            .cornerRadius(10)
            .shadow(radius: 5)
    }
    
    func modernTitleStyle() -> some View {
        self
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .shadow(radius: 10)
            .padding()
    }
}
