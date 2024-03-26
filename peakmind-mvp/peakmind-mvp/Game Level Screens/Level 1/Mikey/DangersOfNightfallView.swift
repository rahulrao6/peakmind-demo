//
//  DangersOfNightfallView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/17/24.
//

import SwiftUI

struct DangersOfNightfallView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    let sherpaText = "Be careful of the dangers at night. In the mountains, there’s wolves, winds, and critters. Be wary of the limited visibility and always stay on a path."
    @State private var animatedText = ""
    @State var navigateToNext = false

    var body: some View {
        ZStack {
            Image("MainBG")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            Text("Mt. Anxiety: Level One")
                .font(.system(size: 34, weight: .bold, design: .default))
                .foregroundColor(.white)
                .padding(.top, -350)
                .padding(.horizontal)
            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(width: 140)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
                .offset(x: 25, y: 20)

            SpeechBubble(text: $animatedText)
                .onAppear { animateText() }
                .offset(x: 90, y: 300)
        }
        .background(
            NavigationLink(destination: NightfallFlavorView().navigationBarBackButtonHidden(true).environmentObject(viewModel), isActive: $navigateToNext) {
            EmptyView()
        })
        .onTapGesture {
            // When tapped, navigate to the next screen
            navigateToNext = true
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
