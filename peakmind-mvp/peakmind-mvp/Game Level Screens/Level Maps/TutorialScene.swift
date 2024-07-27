//
//  TutorialScene.swift
//  peakmind-mvp
//
//  Created by James Wilson on 7/13/24.
//

import SwiftUI
import SpriteKit
import Glur
import ConfettiSwiftUI


struct TutorialScene: View {    
    let positions: [CGPoint] = [CGPoint(x: 215, y: 150), CGPoint(x: 240, y: 300), CGPoint(x: 215, y: 450), CGPoint(x: 240, y: 600), CGPoint(x: 180, y: 750),
                                CGPoint(x: 150, y: 750)]
    
    @State private var activeModal: LevelNode?
    @State private var confetti = 0
    @State private var currentPhase = 1
    
    @StateObject private var scene: MapScene = {
        let scene = MapScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scene.scaleMode = .fill
        scene.backgroundColor = .clear
        scene.imagePositions = [CGPoint(x: 215, y: 150), CGPoint(x: 240, y: 300), CGPoint(x: 190, y: 450), CGPoint(x: 150, y: 600), CGPoint(x: 180, y: 750), CGPoint(x: 195, y: 900), CGPoint(x: 240, y: 1050), CGPoint(x: 225, y: 1200), CGPoint(x: 165, y: 1350), CGPoint(x: 160, y: 1500)]
        scene.maxY = 0.5
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
                        activeModal = scene.levels[levelIndex]
                    } else {
                        confetti = confetti + 1
                        activeModal = nil
                    }
                }
                .onAppear {
                    scene.levels = [
                        LevelNode(uid: 0, internalName: "P1_5_StressTriggerMap", title: "Welcome to PeakMind!", viewFactory: { AnyView(P1_Intro(closeAction: {print("Done")})) }, phase: 1),
                        LevelNode(uid: 1, internalName: "P1_MentalHealthMod", title: "PeakMind Game", viewFactory: { AnyView(P1_MentalHealthMod(closeAction: {print("Done")})) }, phase: 1),
                        LevelNode(uid: 2, internalName: "P1_3_EmotionsScenario", title: "Self Care", viewFactory: { AnyView(P1_3_EmotionsScenario(closeAction: {print("Done")})) }, phase: 1),
                        LevelNode(uid: 3, internalName: "P1_4_StressModule", title: "Communities", viewFactory: { AnyView(P1_4_StressModule(closeAction: {print("Done")})) }, phase: 1),
                        LevelNode(uid: 4, internalName: "P1_4_StressModule", title: "Artificial Intelligence", viewFactory: { AnyView(P1_4_StressModule(closeAction: {print("Done")})) }, phase: 1),
                        LevelNode(uid: 5, internalName: "P1_4_StressModule", title: "PeakMind All Together", viewFactory: { AnyView(P1_4_StressModule(closeAction: {print("Done")})) }, phase: 1),
                    ]
                }
            
            VStack {
                VStack {
                    VStack {
                        Text("Tutorial")
                            .font(.system(size: 30, weight: .heavy, design: .default))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        Text("Welcome to PeakMind!")
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
                    .opacity(0)
                }
                
                Spacer()
            }
            .padding(.top, 70)
            
        }
        .overlay(alignment: .bottom) {
            GeometryReader { geom in
                VariableBlurView(maxBlurRadius: 2, direction: .blurredBottomClearTop)
                    .frame(height: 200)
                    .ignoresSafeArea()
                    .padding(.top, 700)
            }
        }
        .fullScreenCover(item: $activeModal) { phase in
            phase.viewFactory()
        }
        .confettiCannon(counter: $confetti)
    }
    
    private func getNodeFromInternalLevelName(internalName: String) -> LevelNode? {
        for level in scene.levels {
            if (level.internalName == internalName) {
                return level
            }
        }
        return nil
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
    TutorialScene()
}
