//
//  ConsistentMealsCheck.swift
//  peakmind-mvp
//
//  Created by Katharina Reimer on 3/29/24.
//

import SwiftUI

struct ConsistentMealsCheck: View {
    @EnvironmentObject var viewModel: AuthViewModel
    let titleText = "Mt. Anxiety: Level Two"
    let sherpaText = "How consistent have you been about eating 3 meals per day in the past 2 weeks?"
    let levelDesc = "Select on a scale from 1-5 below 1 being not consistent at all and 5 being everyday."
    @State var speed = 1.0
    @State private var animatedText = ""
    @State var navigateToNext = false
    
    var body: some View {
        ZStack {
            Image("MainBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(width: 140)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
                .offset(x: 25, y: 20)
            
            VStack(spacing: 20) {
                // Title
                Text(titleText)
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.top, 50)
                    .padding(.horizontal)
                
                // description
                VStack(alignment: .center) {
                    Text(animatedText)
                        .font(.system(size: 24))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .onAppear {
                            animateText()
                        }
                }
                .background(Color("Dark Blue"))
                .cornerRadius(15)
                .padding(.horizontal, 40)
                .frame(height: 120)
                Divider()
                VStack {
                    Text(levelDesc)
                        .foregroundColor(.white)
                        .padding()
                        .shadow(color: .black, radius: 1)
                }
                .background(LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .top, endPoint: .center))
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.black, lineWidth: 2)
                    )
                    .padding(.horizontal, 40)
                
                // Slider
                VStack {
                    Slider(
                        value: $speed,
                        in: 1...5,
                        step: 1.0
                    )
                    
                    .background(LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: UnitPoint(x: 0, y: 0), endPoint: .trailing))
                    .cornerRadius(15)
                    .tint(.cyan)
                    .padding(.horizontal, 40)
                    
                    VStack {
                        Text("\(Int(speed))")
                            .foregroundColor(.white)
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .padding()
                        if (speed == 1.0) {
                            Text("You have never eaten 3 meals.")
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.bottom, 20)
                        } else if (speed == 2.0) {
                            Text("You have eaten 3 meals once or twice.")
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.bottom, 20)
                        } else if (speed == 3.0) {
                            Text("You have sometimes eaten 3 meals.")
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.bottom, 20)
                        } else if (speed == 4.0) {
                            Text("You have eaten 3 meals almost every day.")
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.bottom, 20)
                        } else if (speed == 5.0) {
                            Text("You have always eaten 3 meals.")
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.bottom, 20)
                        }
                                
                        
                    }
                    .background(LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .top, endPoint: .center))
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.black, lineWidth: 2)
                    )
                    .padding(.horizontal, 40)
                    
                }
                
                
                
                Spacer()
                MainScreenView()
            }
        }
    }

    
    private func animateText() {
        var charIndex = 0.0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            let roundedIndex = Int(charIndex)
            if roundedIndex < sherpaText.count {
                let index = sherpaText.index(sherpaText.startIndex, offsetBy: roundedIndex)
                animatedText.append(sherpaText[index])
            }
            charIndex += 1
            if roundedIndex >= sherpaText.count {
                timer.invalidate()
            }
        }
        timer.fire()
    }
}

/*
struct SpeechBubble: View {
    @Binding var text: String

    var body: some View {
        Text(text)
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .lineLimit(7)
            .padding()
            .frame(width: 300, height: 150, alignment: .topLeading)
            .background(Color("Dark Blue"))
            .cornerRadius(10)
            .overlay(
                Triangle()
                    .fill(Color("Dark Blue"))
                    .frame(width: 20, height: 20)
                    .rotationEffect(Angle(degrees: 45))
                    .offset(x: 0, y: 10),
                alignment: .bottomLeading
            )
            .offset(x: -70, y: -240)
    }
}



struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

struct DangersOfNightfallView_Previews: PreviewProvider {
    static var previews: some View {
        DangersOfNightfallView()
    }
}
*/

#Preview {
    ConsistentMealsCheck()
}
