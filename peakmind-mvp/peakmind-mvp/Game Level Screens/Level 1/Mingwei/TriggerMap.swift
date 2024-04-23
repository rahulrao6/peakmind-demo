//
//  TriggerMap.swift
//  peakmind-mvp
//
//  Created by Mingwei Li on 4/22/24.
//

import SwiftUI

struct TriggerMap: View {
    @EnvironmentObject var viewModel: InteractiveViewModel
    
    var body: some View {
        ZStack {
            Image("MainBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(width: 140)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
                .offset(x: 5, y: 20)
            
            VStack {
                ScrollView {
                    VStack(alignment: .center) {
                        Text("—— Mt. Anxiety ——\n           Level One")
                            .modernTitleStyle()
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Group {
                            VStack {
                                Text("Trigger Map")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(
                                        Rectangle()
                                            .foregroundColor(Color(hex: "1E4E96"))
                                            .opacity(0.8)
                                            .overlay(RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.black, lineWidth: 5))
                                            .frame(width: 130, height: 30)
                                            .cornerRadius(20)
                                    )
                                    
                                
                                Text("Have you ever had something in your \nlife like a big project or test that causes \na lot of stress. That is what we call a \ntrigger or stressor in the world of \nmental health.")
                                    .padding()
                                    .background(
                                        Rectangle()
                                            .foregroundColor(Color(hex: "366093"))
                                            .opacity(0.8)
                                            .cornerRadius(30.0)
                                            .overlay(RoundedRectangle(cornerRadius: 30)
                                                .stroke(Color.black, lineWidth: 1))
                                    )
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .font(.footnote)
                            }
                            .background(
                                Rectangle()
                                    .foregroundColor(Color(hex: "3D79C2"))
                                    .cornerRadius(10)
                                    .frame(width:347, height: 185)
                                    .opacity(0.8)
                                    .overlay(RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.black, lineWidth: 2))
                                    .cornerRadius(30)
                                    .offset(y: 6)
                            )
                            .offset(y: -20)
                            .padding()
                            
                            Spacer()
                            
                            ForEach($viewModel.causeEffectPairs.indices, id: \.self) { index in
                                HStack {
                                    TextField("Cause", text: $viewModel.causeEffectPairs[index].cause)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(
                                            GlowingView(color: "62A7DD", frameWidth: 120, frameHeight: 50, cornerRadius: 20)
                                                .offset(x: -40)
                                        )
                                        .offset(x: 50)
                                    Text("→")
                                        .foregroundColor(.white)
                                    TextField("Effect", text: $viewModel.causeEffectPairs[index].effect)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(
                                            GlowingView(color: "62A7DD", frameWidth: 120, frameHeight: 50, cornerRadius: 20)
                                                .offset(x: -40)
                                        )
                                        .offset(x: 40)
                                }
                                .padding(.horizontal)
                                .offset(x: offsetForIndex(index))
                            }
                            
                            HStack {
                                VStack {
                                    Text("Let's trigger map\n\nSwipe through the \ninstructions")
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .background(
                                            GlowingView(color: "1E90FF", frameWidth: 190, frameHeight: 90, cornerRadius: 20)
                                        )
                                        .frame(width: 190, height: 90)
                                        .cornerRadius(20)
                                        .offset(x: 70, y: 40)
                                    Text("Tap to Continue")
                                        .foregroundColor(.white)
                                        .opacity(0.5)
                                        .font(.title3)
                                        .alignmentGuide(.bottom) { d in d[.bottom] }
                                        .padding(.leading, 200)
                                        .padding(.top, 70)
                                        .offset(y: 80)
                                }
                                .padding()
                            }
                            .edgesIgnoringSafeArea(.bottom)
                        }
                    }
                }
            }
        }
    }
    private func offsetForIndex(_ index: Int) -> CGFloat {
        switch index {
        case 0:
            return -30
        case 1:
            return 0
        case 2:
            return 30
        default:
            return 0
        }
    }
}

struct TriggerMap_Previews: PreviewProvider {
    static var previews: some View {
        TriggerMap().environmentObject(InteractiveViewModel())
    }
}
