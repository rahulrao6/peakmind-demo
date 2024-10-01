//
//  GreenNewBG3.2.swift
//  peakmind-mvp
//
//  Created by ZA on 9/17/24.
//

import SwiftUI

struct P2_3_2: View {
    var closeAction: (String) -> Void
    @State private var currentIndex: Int = 0
    @State private var isTextCompleted: Bool = false
    @State private var isExerciseStarted: Bool = false
    @State private var currentStep: Int = 0
    @State private var progress: CGFloat = 0.0
    @State private var cycleCount: Int = 0
    @State private var showEndButtons: Bool = false
    @State private var timeRemaining: Int = 4
    @State private var navigatetoStressIntroView: Bool = false
    @State private var timer: Timer? = nil

    let bulletPoints = [
        "Breathe in quietly through your nose for a count of four. Focus on filling your lungs slowly and deeply, drawing in as much air as comfortably possible.",
        "Hold your breath for a count of seven. This pause allows your body to absorb the oxygen, and you'll begin to feel a calming sensation as your focus shifts inward.",
        "Exhale completely through your mouth, making a whooshing sound, for a count of eight. Visualize releasing all your stress and tension with each breath out.",
        "Repeat this cycle for three to four breaths, or until you feel your body and mind calming down, gradually relaxing into the rhythm of your breathing."
    ]

    
    let breathingSteps = [
        ("Breathe In", 4),
        ("Hold", 7),
        ("Breathe Out", 8)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("GreenNewBG")
                    .resizable()
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 19) {
                    Spacer()
                        .frame(height: 10)
                    
                    // Breathing exercise title
                    Text("Breathing Exercise")
                        .font(.custom("SFProText-Bold", size: 28))
                        .foregroundColor(Color("GreenTitleColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    // Larger text box with typing animation for bullet points
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("GreenBoxGradientColor1"), Color("GreenBoxGradientColor2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: geometry.size.height * 0.45)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color("GreenBorderColor"), lineWidth: 3.5)
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
                                        .id(index)
                                    }
                                }
                                .padding(20)
                            }
                            .frame(height: geometry.size.height * 0.45)
                            .onChange(of: currentIndex) { _ in
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
                    
                    // Begin Button before exercise starts
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
                                        gradient: Gradient(colors: [Color("GreenButtonGradientColor1"), Color("GreenButtonGradientColor2")]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(15)
                                .shadow(color: Color.white.opacity(1), radius: 10, x: 0, y: 0)
                        }
                        .padding(.top, 20)
                    }
                    
                    // Breathing exercise animation and instructions
                    if isExerciseStarted || showEndButtons {
                        ZStack {
                            TriangleShape()
                                .stroke(Color("GreenBorderColor"), lineWidth: 3.5)
                                .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
                            
                            TriangleShape()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color("GreenBoxGradientColor1"), Color("GreenBoxGradientColor2")]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * 0.4 * progress, height: geometry.size.width * 0.4)
                            
                            // Moved the text lower inside the triangle by adding padding
                            Text(showEndButtons ? "All done!" : breathingSteps[currentStep].0)
                                .font(.custom("SFProText-Bold", size: 14))
                                .foregroundColor(Color("GreenTextColor"))
                                .padding(.top, geometry.size.width * 0.2)  // Shift text lower within the triangle
                                .padding(.bottom, 20)
                            
                            VStack {
                                Spacer()
                                
                                HStack {
                                    Text("\(cycleCount)/3")
                                        .font(.custom("SFProText-Bold", size: 12))
                                        .foregroundColor(Color("GreenTextColor"))
                                    
                                    Spacer()
                                    
                                    Text("\(timeRemaining)s")
                                        .font(.custom("SFProText-Bold", size: 12))
                                        .foregroundColor(Color("GreenTextColor"))
                                }
                                .padding([.leading, .trailing], 10)
                                .padding(.bottom, 10)
                            }
                            .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
                        }
                    }
                    
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
                                            gradient: Gradient(colors: [Color("GreenButtonGradientColor1"), Color("GreenButtonGradientColor2")]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(15)
                                    .shadow(color: Color.white.opacity(1), radius: 10, x: 0, y: 0)
                            }
                            
                            Button(action: {
                                navigatetoStressIntroView = true
                                closeAction("")
                                
                            }) {
                                Text("Continue")
                                    .font(.custom("SFProText-Bold", size: 20))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color("GreenButtonGradientColor1"), Color("GreenButtonGradientColor2")]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(15)
                                    .shadow(color: Color.white.opacity(1), radius: 10, x: 0, y: 0)
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
    
    // Function to start typing the bullet points
    func startTyping() {
        for index in 0..<bulletPoints.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 3) {
                currentIndex += 1
            }
        }
    }
    
    // Function to start the exercise
    func startExercise() {
        isExerciseStarted = true
        cycleCount = 0
        startBreathingCycle()
    }
    
    // Function to handle the breathing cycle and sync animation with time
    func startBreathingCycle() {
        currentStep = 0
        progress = 0.0
        cycleBreathingSteps()
    }
    
    func cycleBreathingSteps() {
        if cycleCount >= 3 {
            showEndButtons = true
            isExerciseStarted = false
            return
        }
        
        timeRemaining = breathingSteps[currentStep].1
        progress = 0.0
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
                progress += CGFloat(1.0 / CGFloat(breathingSteps[currentStep].1))
            } else {
                timer.invalidate()
                currentStep += 1
                if currentStep >= breathingSteps.count {
                    cycleCount += 1
                    currentStep = 0
                }
                cycleBreathingSteps() // Proceed to next step or cycle
            }
        }
    }
    
    // Function to redo the exercise
    func redoExercise() {
        showEndButtons = false
        isTextCompleted = true
        isExerciseStarted = false
        progress = 0.0
        cycleCount = 0
        startExercise()
    }
}
