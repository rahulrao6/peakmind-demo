//
//  LevelMapView.swift
//  peakmind-mvp
//
//  Created by James Wilson on 5/25/24.
//

import SwiftUI
import Glur

struct LevelMapView: View {
    @State private var activeModal: Screen?

    var body: some View {
        VStack {
            ZStack {
                Image("pkmd_path")
                    .resizable()
                    .ignoresSafeArea()
                    .frame(width: 250, height: UIScreen.main.bounds.size.height + 30)
                    .glur(radius: 16.0,
                          offset: 0,
                          interpolation: 0.5,
                          direction: .up
                    )
                    .glur(radius: 16.0,
                          offset: 0.9,
                          interpolation: 0.1,
                          direction: .down
                    )
                VStack {
                    ZStack {
                        VStack {
                            VStack {
                                VStack {
                                    Text("Mount Anxiety")
                                        .font(.system(size: 30, weight: .heavy, design: .default))
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                    
                                    Text("Level 1")
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                    
                                }
                                .padding()
                                
                            }
                            .frame(width: 350)
                            .background {
                                RoundedRectangle(cornerRadius: 13, style: .continuous).fill(Color.white)
                            }
                            Spacer()
                        }
                        LevelCircle(level: "1")
                            .onTapGesture {
                                activeModal = Screen(screenName: "1")
                            }
                            .padding(.top, 500)
                            .padding(.leading, 50)
                    }
                }
                .padding(.top, 65)
                .multilineTextAlignment(.trailing)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color.blue.opacity(0.2)
                .ignoresSafeArea()
        }
        .fullScreenCover(item: $activeModal) { screen in
            destinationView(for: screen.screenName) {
                Task {
                    print("Done")
                    //try await viewModel.markLevelCompleted(levelID: screen.screenName)
                }
                activeModal = nil
            }
        }
    
    }
    
    @ViewBuilder
    private func destinationView(for screenName: String, close: @escaping () -> Void) -> some View {
        switch screenName {
        case "1":
            P1_Intro(closeAction: close)
        case "2":
            P1_MentalHealthMod(closeAction: close)
        case "3":
            P1_3_EmotionsScenario(closeAction: close)
        case "4":
            BoxBreathingView(closeAction: close)
        case "5":
            P1_10_LifestyleModule(closeAction: close)
        case "6":
            P1_6_PersonalQuestion(closeAction: close)
        case "7":
            P1_4_StressModule(closeAction: close)
        case "8":
            MuscleRelaxationView(closeAction: close)
        case "9":
            P1_14_Reflection(closeAction: close)
        case "10":
            Minigame2View(closeAction: close)
        default:
            Text("Unknown View").onTapGesture {
                close()
            }
        }
    }
}


#Preview {
    LevelMapView()
}
