//
//  PinkNewBG10.swift
//  peakmind-mvp
//
//  Created by ZA on 9/24/24.
//

import SwiftUI

struct P3EmotionalPageView: View {
    @State private var selectedOptions: Set<String> = []
    @State private var navigateToNextView = false // State to control navigation
    
    // Quiz Question
    let question = "Thinking about the past week, have you noticed any of these feelings coming up for you?"
    
    // Answer options
    let options = [
        "Feeling on edge (nervousness)",
        "Physical tension (muscle tensing)",
        "Feeling overwhelmed or worried (dread)",
        "Frustration or irritation (anger)",
        "Feeling jump or on high alert (panic)",
        "Feeling insecure or vulnerable (unsafe)"
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // background image
                Image("PinkNewBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 10) {
                    Spacer()
                        .frame(height: 80)
                    
                    // Quiz title
                    Text("Self-Discovery Quiz")
                        .font(.custom("SFProText-Bold", size: 28))
                        .foregroundColor(Color("PinkTitleColor"))
                        .padding(.bottom, 10)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    // Quiz question
                    Text(question)
                        .font(.custom("SFProText-Medium", size: 18))
                        .foregroundColor(Color("PinkTextColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                    
                    // Answer options (scrollable if needed)
                    ScrollView {
                        VStack(spacing: 12) {
                            Spacer() // Adds space before the first option
                                .frame(height: 12)
                            ForEach(options, id: \.self) { option in
                                AnswerBox3(text: option, isSelected: selectedOptions.contains(option)) {
                                    toggleSelection(for: option)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(height: geometry.size.height * 0.5)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Submit button with conditional glow
                    Button(action: {
                        submitAnswers()
                    }) {
                        Text("Submit")
                            .font(.custom("SFProText-Bold", size: 20))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PinkButtonGradientColor1"), Color("PinkButtonGradientColor2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: selectedOptions.isEmpty ? Color.clear : Color.white.opacity(1), radius: 10, x: 0, y: 0)
                    }
                    .padding(.bottom, 50)
                    .background(
                        NavigationLink(destination: P3IntroView(), isActive: $navigateToNextView) {
                            EmptyView()
                        }
                    )
                }
                .padding(.horizontal)
            }
        }
    }
    
    // Toggle the selection of an option
    func toggleSelection(for option: String) {
        if selectedOptions.contains(option) {
            selectedOptions.remove(option)
        } else {
            selectedOptions.insert(option)
        }
    }
    
    // Action when submitting answers
    func submitAnswers() {
        // Navigate to the next view after submitting the answers
        if !selectedOptions.isEmpty {
            navigateToNextView = true
        }
    }
}

// Answer Box View (Single Option)
struct AnswerBox3: View {
    var text: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            HStack {
                Text(text)
                    .font(.custom("SFProText-Medium", size: 18))
                    .foregroundColor(Color("PinkTextColor"))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color("PinkTextColor"))
                        .padding(.trailing, 10)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(Color("PinkTextColor"))
                        .padding(.trailing, 10)
                }
            }
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color("PinkBoxGradientColor1"), Color("PinkBoxGradientColor2")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color("PinkBorderColor"), lineWidth: 2)
            )
            .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
        }
    }
}

struct P3EmotionalPageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            P3EmotionalPageView()
        }
    }
}
