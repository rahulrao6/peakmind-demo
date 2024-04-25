//
//  MuscleRelaxationExplanationView.swift
//  peakmind-mvp
//
//  Created by James Wilson on 4/13/24.
//

import SwiftUI

struct MuscleRelaxationExplanationView: View {
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
            
            Text("We should understand coping mechanisms and how they work.")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color("Medium Blue"))
                .frame(width: 150)
                .offset(x: 90, y: 250)
            
            VStack(spacing: 0) {
                Text("Mt. Anxiety: Level One")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .padding(.bottom, 40)

                ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
                    VStack {
                        Text("Progressive muscle relaxation")
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundColor(.white)
                            .padding(.bottom, 5)

                        Text("Progressive muscle relaxation involves tensing each muscle group for about five seconds and then releasing the tension, moving from your feet up to your face. This practice helps relieve the physical tension associated with your anxiety.")
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.white)
                            .padding()
                        
                        Button(action: {}) {
                            Text("Continue")
                        }
                    }
                    .frame(width: 300, height: 330)
                    .background(Color("Dark Blue").opacity(0.75))
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
                Spacer()
            }
        }
    }
}

struct MuscleRelaxationExplanationView_Previews: PreviewProvider {
    static var previews: some View {
        MuscleRelaxationExplanationView()
    }
}
