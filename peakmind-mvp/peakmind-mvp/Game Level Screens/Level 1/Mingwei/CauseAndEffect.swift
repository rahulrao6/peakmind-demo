//
//  CauseAndEffect.swift
//  peakmind-mvp
//
//  Created by Mingwei Li on 4/21/24.
//

import SwiftUI

struct CauseAndEffect: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
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
                                Text("Scenario")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(
                                        Rectangle()
                                            .foregroundColor(Color(hex: "1E4E96"))
                                            .opacity(0.8)
                                            .overlay(RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.black, lineWidth: 3))
                                    )
                                    .cornerRadius(10)
                                    .font(.title2)
                                    .padding(.horizontal)
                                
                                Text("Have you ever had something in your life like a big project or test that causes a lot of stress. That is what we call a trigger or stressor in the world of mental health.")
                                    .padding()
                                    .background(
                                        Rectangle()
                                            .foregroundColor(Color(hex: "2A4D7C"))
                                            .cornerRadius(10)
                                            .opacity(0.8)
                                            .cornerRadius(3.0)
                                            .overlay(RoundedRectangle(cornerRadius: 8)
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
                                    .frame(width:380, height: 200)
                                    .opacity(0.8)
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 2))
                            )
                            .padding()
                            Spacer()
                            ForEach(0..<2) { _ in
                                HStack {
                                    Text("Cause")
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(
                                            Rectangle()
                                                .foregroundColor(Color(hex: "62A7DD"))
                                                .cornerRadius(10)
                                                .overlay(RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.black, lineWidth: 2))
                                        )
                                    Text("→")
                                        .foregroundColor(.white)
                                    Text("Effect")
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(
                                            Rectangle()
                                                .foregroundColor(Color(hex: "62A7DD"))
                                                .cornerRadius(10)
                                                .overlay(RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.black, lineWidth: 2))
                                        )
                                }
                                .padding(.horizontal)
                            }
                            
                            HStack {
                                VStack {
                                    Text("Let's trigger map\n\nSwipe through the \ninstructions")
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .padding()
                                        .background(
                                            Rectangle()
                                                .foregroundColor(Color(hex: "62A7DD"))
                                                .cornerRadius(10)
                                                .overlay(RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.black, lineWidth: 2))
                                        )
                                        .font(.footnote)
                                        .padding(.leading, 170)
                                        .padding(.top, 70)
                                    Text("Tap to Continue")
                                        .foregroundColor(.white)
                                        .opacity(0.5)
                                        .font(.title3)
                                        .alignmentGuide(.bottom) { d in d[.bottom] }
                                        .padding(.leading, 200)
                                        .padding(.top, 90)
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
    
    struct CauseAndEffect_Previews: PreviewProvider {
        static var previews: some View {
            CauseAndEffect()
        }
    }
}
