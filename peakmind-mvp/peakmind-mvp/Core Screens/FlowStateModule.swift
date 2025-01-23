//
//  FlowStateModule.swift
//  peakmind-mvp
//
//  Created by ZA on 9/24/24.
//

import SwiftUI

struct FlowStateModuleView: View {
    @State private var currentIndex: Int = 0
    @State private var isButtonDisabled: Bool = true
    @State private var showGlow: Bool = false
    @State private var navigateToNextScreen = false // state to control navigation

    let bulletPoints = [
        "Flow state, often referred to as being 'in the zone,' is a mental state where you feel completely absorbed in a task. Achieving flow can lead to increased focus, productivity, and a sense of fulfillment. It occurs when your skills align perfectly with the challenge at hand.",
        "Creating the right environment is key to reaching flow state. This means eliminating distractions, setting clear goals, and immersing yourself in a task you genuinely enjoy. When you're in flow, time seems to fly, and you perform at your best.",
        "Maintaining flow requires practice and self-awareness. Regularly engaging in activities that challenge you just enough to keep you engaged can help you cultivate flow more easily. Remember, flow isn't about overworking but about finding balance and enjoyment in what you do."
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("NewBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 16) {
                    Spacer()
                        .frame(height: 80)

                    // Title above the box
                    Text("Flow State")
                        .font(.custom("SFProText-Bold", size: 30))
                        .foregroundColor(Color("QuestionHeaderColor"))
                        .padding(.bottom, 10)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)

                    // Larger gradient box with bullet points
                    ZStack {
                        // Gradient background box
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("BoxGradient1"), Color("BoxGradient2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: geometry.size.height * 0.55) // Increased height
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color("BoxStrokeColor"), lineWidth: 3.5)
                            )

                        // Scrollable list of bullet points with auto-scroll
                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(0..<currentIndex + 1, id: \ .self) { index in
                                        FlowStateBulletPoint(text: bulletPoints[index], onTypingComplete: {
                                            isButtonDisabled = false
                                            showGlow = true // Show glow when typing is complete
                                        })
                                        .id(index) // Attach the ID for scrolling
                                    }
                                    // Dummy item to force scroll to bottom
                                    Color.clear.frame(height: 1).id("bottom")
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                            }
                            .defaultScrollAnchor(.bottom)
                        }
                        .frame(height: geometry.size.height * 0.53) // Adjust height to stay within the gradient box
                        .clipShape(RoundedRectangle(cornerRadius: 15)) // Ensure the text is clipped within the box
                    }
                    .padding(.horizontal, 30)

                    Spacer()

                    // Next/continue button
                    Button(action: {
                        if currentIndex < bulletPoints.count - 1 {
                            isButtonDisabled = true
                            showGlow = false // Hide glow when text starts typing
                            currentIndex += 1
                        } else {
                            navigateToNextScreen = true // Trigger navigation
                        }
                    }) {
                        Text(currentIndex < bulletPoints.count - 1 ? "Next" : "Continue")
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
                            .shadow(color: showGlow ? Color.white.opacity(1) : Color.clear, radius: 10, x: 0, y: 0) // Show glow when required
                    }
                    .padding(.bottom, 50)
                    .disabled(isButtonDisabled) // Disable button if typing is not complete

                    // Navigation link to the next screen
                    NavigationLink(destination: SelectToolsView(), isActive: $navigateToNextScreen) {
                        EmptyView()
                    }

                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            // Start typing the first bullet point when the view appears
            currentIndex = 0
            isButtonDisabled = true
            showGlow = false
        }
    }
}

struct FlowStateBulletPoint: View {
    var text: String
    @State private var visibleText: String = ""
    @State private var charIndex: Int = 0
    var onTypingComplete: () -> Void

    var body: some View {
        // Feature text with typing animation
        Text(visibleText)
            .font(.custom("SFProText-Medium", size: 16))
            .foregroundColor(Color("TextInsideBoxColor"))
            .multilineTextAlignment(.leading)
            .onAppear {
                typeText()
            }
    }

    private func typeText() {
        visibleText = ""
        charIndex = 0

        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            if charIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: charIndex)
                visibleText.append(text[index])
                charIndex += 1
            } else {
                timer.invalidate()
                onTypingComplete()
            }
        }
    }
}

struct FlowStateModuleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FlowStateModuleView()
        }
    }
}
