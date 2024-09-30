//
//  NewBG8.2.swift
//  peakmind-mvp
//
//  Created by ZA on 9/24/24.
//

import SwiftUI

struct P4_8_3: View {
    var closeAction: () -> Void
    let selectedActivity: String // Passed from the first screen
    @State private var selectedOptions: Set<String> = []
    @State private var navigateToNextView = false

    // Options for the checklist
    let options = [
        "Stretching",
        "Affirmations",
        "Gratitude",
        "Journaling",
        "Meditation",
        "Box Breathing",
        "Strategy Game"
    ]
    
    var body: some View {
        let filteredOptions = options.filter { $0 != selectedActivity } // Filter inside the body

        return VStack(spacing: 20) {
            Spacer().frame(height: 40)

            // Title text
            Text("Choose your second 2-minute activity")
                .font(.custom("SFProText-Bold", size: 24))
                .foregroundColor(Color("QuestionHeaderColor"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            // Checklist options
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(filteredOptions, id: \.self) { option in
                        Button(action: {
                            toggleSelection(for: option)
                        }) {
                            HStack {
                                Text(option)
                                    .font(.custom("SFProText-Medium", size: 18))
                                    .foregroundColor(Color("TextInsideBoxColor"))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                
                                Spacer()
                                
                                if selectedOptions.contains(option) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color("TextInsideBoxColor"))
                                        .padding(.trailing, 10)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(Color("TextInsideBoxColor"))
                                        .padding(.trailing, 10)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("BoxGradient1"), Color("BoxGradient2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color("BoxStrokeColor"), lineWidth: 3.5)
                            )
                            .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }

            Spacer()

            // Continue button with conditional glow
            Button(action: {
                navigateToNextView = true // Navigate to next view
            }) {
                Text("Continue")
                    .font(.custom("SFProText-Bold", size: 20))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color("ButtonGradient1"), Color("ButtonGradient2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(15)
                    .shadow(color: selectedOptions.isEmpty ? Color.clear : Color.white.opacity(1), radius: 10, x: 0, y: 0)
            }
            .disabled(selectedOptions.isEmpty)
            .padding(.bottom, 50)
            .background(
                NavigationLink(destination: P4_8_4(closeAction: closeAction, selectedActivity1: selectedActivity, selectedActivity2: selectedOptions.first ?? ""), isActive: $navigateToNextView) {
                    EmptyView()
                }
            )
        }
        .background(
            Image("NewBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
        )
    }
    
    private func toggleSelection(for option: String) {
        if selectedOptions.contains(option) {
            selectedOptions.remove(option)
        } else {
            selectedOptions = [option] // Only one option can be selected at a time
        }
    }
}
