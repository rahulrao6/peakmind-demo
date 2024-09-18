//
//  PurpleNewBG3.2.swift
//  peakmind-mvp
//
//  Created by ZA on 8/26/24.
//

import SwiftUI

struct P3_2: View {
    @State private var currentIndex: Int = 0
    @State private var isTextCompleted: Bool = false
    @State private var showAnimation = false
    @State private var isExerciseStarted: Bool = false
    @State private var currentStep: Int = 0
    @State private var progress: CGFloat = 0.0
    @State private var cycleCount: Int = 0
    @State private var showEndButtons: Bool = false
    @State private var timeRemaining: Int = 4
    @State private var navigatetoStressIntroView: Bool = false
    
    let bulletPoints = [
        "Controlled breathing can bring about significant positive changes in the body, such as lowering blood pressure and heart rate.",
        "It also helps reduce stress hormone levels in the bloodstream, promoting a sense of calm.",
        "Below, you'll find an animated guide to Box Breathing—a powerful technique for relaxation.",
        "This exercise involves a four-part cycle: inhale for four counts, hold for four counts, exhale for four counts, and hold again for four counts.",
        "Let’s practice together by following the guide."
    ]
    
    let breathingSteps = [
        "Breathe In",
        "Hold",
        "Breathe Out",
        "Hold"
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // background image
                Image("PurpleNewBG")
                    .resizable()
                    .clipped() // ensures the image fills the screen without distortion
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 19) {
                    Spacer()
                        .frame(height: 10)
                    
                    // breathing exercise title
                    Text("Box Breathing")
                        .font(.custom("SFProText-Bold", size: 28))
                        .foregroundColor(Color("PurpleTitleColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    // larger text box with typing animation for bullet points
                    ZStack {
                        // gradient background box
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PurpleBoxGradientColor1"), Color("PurpleBoxGradientColor2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: geometry.size.height * 0.45) // increased height for the text box
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color("PurpleBorderColor"), lineWidth: 3.5)
                            )
                        
                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(0..<currentIndex, id: \.self) { index in
                                        FeatureBulletPoint2(text: bulletPoints[index], onTypingComplete: {
                                            if index == bulletPoints.count - 1 {
                                                isTextCompleted = true
                                            }
                                        })
                                        .id(index) // ID for scroll-to functionality
                                    }
                                }
                                .padding(20)
                            }
                            .frame(height: geometry.size.height * 0.45) // ensure ScrollView stays within the box
                            .onChange(of: currentIndex) { _ in
                                // scroll to the last typed bullet point
                                withAnimation {
                                    proxy.scrollTo(currentIndex - 1, anchor: .bottom)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .onAppear {
                        startTyping()
                    }
                    
                    // begin Button before exercise starts
                    if isTextCompleted && !isExerciseStarted && !showEndButtons {
                        Button(action: {
                            startExercise()
                        }) {
                            Text("Begin")
                                .font(.custom("SFProText-Bold", size: 20))
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color("PurpleButtonGradientColor1"), Color("PurpleButtonGradientColor2")]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(15)
                                .shadow(color: Color.white.opacity(1), radius: 10, x: 0, y: 0)
                        }
                        .padding(.top, 20)
                    }
                    
                    // breathing exercise animation and instructions
                    if isExerciseStarted || showEndButtons {
                        ZStack {
                            // background for the timer
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color("PurpleBorderColor"), lineWidth: 3.5)
                                .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4) // smaller square for the exercise
                            
                            // gradient progress bar
                            RoundedRectangle(cornerRadius: 15)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color("PurpleBoxGradientColor1"), Color("PurpleBoxGradientColor2")]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * 0.4 * progress, height: geometry.size.width * 0.4)
                                .animation(.easeInOut(duration: 4), value: progress)
                            
                            // instruction text or completion text
                            Text(showEndButtons ? "All done!" : breathingSteps[currentStep])
                                .font(.custom("SFProText-Bold", size: 14))
                                .foregroundColor(Color("PurpleTextColor"))
                                .padding(.bottom, 20)
                            
                            // exercise counter and timer
                            VStack {
                                Spacer()
                                
                                HStack {
                                    // exercise counter
                                    Text("\(cycleCount)/4")
                                        .font(.custom("SFProText-Bold", size: 12))
                                        .foregroundColor(Color("PurpleTextColor"))
                                    
                                    Spacer()
                                    
                                    // timer for the current step
                                    Text("\(timeRemaining)s")
                                        .font(.custom("SFProText-Bold", size: 12))
                                        .foregroundColor(Color("PurpleTextColor"))
                                }
                                .padding([.leading, .trailing], 10)
                                .padding(.bottom, 10)
                            }
                            .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
                        }
                        .onAppear {
                            showAnimation = true
                        }
                    }
                    
                    // redo exercise and continue buttons after four cycles
                    if showEndButtons {
                        VStack(spacing: 20) {
                            Button(action: {
                                redoExercise()
                            }) {
                                Text("Redo")
                                    .font(.custom("SFProText-Bold", size: 20))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color("PurpleButtonGradientColor1"), Color("PurpleButtonGradientColor2")]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(15)
                                    .shadow(color: Color.white.opacity(1), radius: 10, x: 0, y: 0)
                            }
                            
                            NavigationLink(destination: StressIntroView(), isActive: $navigatetoStressIntroView) {
                                Button(action: {
                                    navigatetoStressIntroView = true
                                }) {
                                    Text("Continue")
                                        .font(.custom("SFProText-Bold", size: 20))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color("PurpleButtonGradientColor1"), Color("PurpleButtonGradientColor2")]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .cornerRadius(15)
                                        .shadow(color: Color.white.opacity(1), radius: 10, x: 0, y: 0)
                                }
                            }
                        }
                        .padding(.top, 20)
                    }


                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
    }
    
    // function to start typing the bullet points
    func startTyping() {
        for index in 0..<bulletPoints.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 3) {
                currentIndex += 1
            }
        }
    }
    
    // function to start the exercise
    func startExercise() {
        isExerciseStarted = true
        cycleCount = 0
        startBreathingCycle()
    }
    
    // function to handle the breathing cycle
    func startBreathingCycle() {
        for step in 0..<breathingSteps.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(step) * 4) {
                currentStep = step
                progress = CGFloat(step + 1) / CGFloat(breathingSteps.count)
                timeRemaining = 4
                startStepTimer()
            }
        }
        
        // check for completion after a full cycle
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(breathingSteps.count) * 4) {
            cycleCount += 1
            if cycleCount >= 4 {
                showEndButtons = true
                isExerciseStarted = false
                progress = 1.0
            } else {
                startBreathingCycle()
            }
        }
    }
    
    // timer for each step
    func startStepTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            timeRemaining -= 1
            if timeRemaining <= 0 {
                timer.invalidate()
            }
        }
    }
    
    // function to redo the exercise
    func redoExercise() {
        showEndButtons = false
        isTextCompleted = true
        isExerciseStarted = false
        progress = 0.0
        cycleCount = 0
        timeRemaining = 4
        startExercise()
    }
}

struct FeatureBulletPoint2: View {
    var text: String
    @State private var visibleText: String = ""
    @State private var charIndex: Int = 0
    var onTypingComplete: () -> Void
    
    var body: some View {
        // feature text with typing animation
        Text(visibleText)
            .font(.custom("SFProText-Medium", size: 16))
            .foregroundColor(Color("PurpleTextColor"))
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

struct BreathingExerciseView2_Previews: PreviewProvider {
    static var previews: some View {
        BreathingExerciseView2()
    }
}


