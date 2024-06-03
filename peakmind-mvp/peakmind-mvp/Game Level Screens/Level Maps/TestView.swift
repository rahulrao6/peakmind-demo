//
//  TestView.swift
//  peakmind-mvp
//
//  Created by James Wilson on 5/26/24.
//

import SwiftUI
import SpriteKit
import Glur

struct LevelNode: Identifiable {
    var id = UUID()
    var uid: Int
    var title: String
    var viewFactory: () -> AnyView
    var phase: Int
}

struct TestView: View {
    let positions: [CGPoint] = [CGPoint(x: 215, y: 150), CGPoint(x: 240, y: 300), CGPoint(x: 215, y: 450), CGPoint(x: 240, y: 600)]
    let levels: [LevelNode] = [

        LevelNode(uid: 0, title: "Intro", viewFactory: { AnyView(P1_Intro(closeAction: { print("Closed") })) }, phase: 1),

        LevelNode(uid: 1, title: "Mental Health", viewFactory: { AnyView(P1_MentalHealthMod(closeAction: { print("Closed") })) }, phase: 1),
        
        LevelNode(uid: 2, title: "Emotions", viewFactory: { AnyView(P1_3_EmotionsScenario(closeAction: { print("Closed") })) }, phase: 1),
        
        LevelNode(uid: 3, title: "Stress", viewFactory: { AnyView(P1_4_StressModule(closeAction: { print("Closed") })) }, phase: 1),
        

        ]
    
    @State private var activeModal: LevelNode?
    
    @StateObject private var scene: MapScene = {
        let scene = MapScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scene.scaleMode = .fill
        scene.backgroundColor = .clear
        scene.imagePositions = [CGPoint(x: 215, y: 150), CGPoint(x: 240, y: 300), CGPoint(x: 190, y: 450), CGPoint(x: 150, y: 600)]
        scene.levels = [
            LevelNode(uid: 0, title: "Intro", viewFactory: { AnyView(P1_Intro(closeAction: { scene.currentLevel = -1 })) }, phase: 1),

            LevelNode(uid: 1, title: "Mental Health", viewFactory: { AnyView(P1_MentalHealthMod(closeAction: { scene.currentLevel = -1 })) }, phase: 1),
            
            LevelNode(uid: 2, title: "Emotions", viewFactory: { AnyView(P1_3_EmotionsScenario(closeAction: { scene.currentLevel = -1 })) }, phase: 1),
            
            LevelNode(uid: 3, title: "Stress", viewFactory: { AnyView(P1_4_StressModule(closeAction: { scene.currentLevel = -1 })) }, phase: 1),
        ]
        return scene
    }()
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .edgesIgnoringSafeArea(.all)
                .overlay(alignment: .top) {
                        GeometryReader { geom in
                            VariableBlurView(maxBlurRadius: 5)
                                .frame(height: 200)
                                .ignoresSafeArea()
                        }
                    }
                .onChange(of: scene.currentLevel) { levelIndex in

                                if levelIndex != -1 {

                                    activeModal = levels[levelIndex]

                                } else {

                                    activeModal = nil

                                }

                            }


            VStack {
                VStack {
                    VStack {
                        Text("Mount Anxiety")
                            .font(.system(size: 30, weight: .heavy, design: .default))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        Text("Phase 1")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                    }
                    .padding()
                    
                }
                .frame(width: 350)
                .background {
                    RoundedRectangle(cornerRadius: 13, style: .continuous).fill(Color.white)
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x:0, y:10)
                }
                HStack {
                    Spacer()
                    VStack {
                        VStack {
                            Text("Complete 3/4 Levels to Continue")
                                .padding([.top, .leading, .bottom, .trailing], 10)
                                .font(.system(size: 10))
                            
                        }
                        
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 13, style: .continuous).fill(Color.white)
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x:0, y:10)
                    }
                    .padding(.trailing, 20)
                    .frame(width: 200, alignment: .trailing)
                }

                Spacer()
            }
            .padding(.top, 50)
            
        }
        .overlay(alignment: .bottom) {
                GeometryReader { geom in
                    VariableBlurView(maxBlurRadius: 2, direction: .blurredBottomClearTop)
                        .frame(height: 100)
                        .ignoresSafeArea()
                        .padding(.top, 750)
                }
            }
        .fullScreenCover(item: $activeModal) { phase in
                    phase.viewFactory()
        }
    }

    private func setupScene() -> SKScene {
        let scene = MapScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scene.scaleMode = .fill
        scene.backgroundColor = .clear
        scene.imagePositions = positions
        return scene
    }
}

#Preview {
    TestView()
}
