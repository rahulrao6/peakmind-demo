//
//  TestView.swift
//  peakmind-mvp
//
//  Created by James Wilson on 5/26/24.
//

import SwiftUI
import SpriteKit
import Glur
import ConfettiSwiftUI

struct LevelNode: Identifiable {
    var id = UUID()
    var uid: Int
    var internalName: String
    var title: String
    var viewFactory: () -> AnyView
    var phase: Int
}

struct CompletedLevel: Identifiable {
    var id = UUID()
    var uid: Int
    var phase: Int
}

struct PhaseGate: Identifiable {
    var id = UUID()
    var phase: Int
}

struct TestView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    let positions: [CGPoint] = [CGPoint(x: 215, y: 150), CGPoint(x: 240, y: 300), CGPoint(x: 215, y: 450), CGPoint(x: 240, y: 600), CGPoint(x: 180, y: 750),
                                CGPoint(x: 150, y: 750)]
    
    @State private var activeModal: LevelNode?
    @State private var confetti = 0
    
    @StateObject private var scene: MapScene = {
        let scene = MapScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scene.scaleMode = .fill
        scene.backgroundColor = .clear
        scene.imagePositions = [CGPoint(x: 215, y: 150), CGPoint(x: 240, y: 300), CGPoint(x: 190, y: 450), CGPoint(x: 150, y: 600), CGPoint(x: 180, y: 750), CGPoint(x: 195, y: 900), CGPoint(x: 240, y: 1050), CGPoint(x: 225, y: 1200), CGPoint(x: 165, y: 1350), CGPoint(x: 160, y: 1500)]
        return scene
    }()
    
    
    var body: some View {
        if let user = viewModel.currentUser {
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
                            scene.completedLevelsList = []
                            for levelName in user.completedLevels {
                                let level = getNodeFromInternalLevelName(internalName: levelName)
                                if (level != nil) {
                                    scene.completedLevelsList.append(CompletedLevel(uid: level!.uid, phase: level!.phase))
                                }
                            }
                            scene.reloadCompletedLevels()
                            
                            activeModal = nil
                        }
                    }
                    .onAppear {
                        scene.levels = [
                            LevelNode(uid: 0, internalName: "P1_5_StressTriggerMap", title: "Intro", viewFactory: { AnyView(P1_Intro(closeAction: { Task {try await viewModel.markLevelCompleted(levelID: activeModal!.internalName); scene.currentLevel = -1} })) }, phase: 1),

                            LevelNode(uid: 1, internalName: "P1_MentalHealthMod", title: "Mental Health", viewFactory: { AnyView(P1_MentalHealthMod(closeAction: { Task {try await viewModel.markLevelCompleted(levelID: activeModal!.internalName); scene.currentLevel = -1} })) }, phase: 1),
                            
                            LevelNode(uid: 2, internalName: "P1_3_EmotionsScenario", title: "Emotions", viewFactory: { AnyView(P1_3_EmotionsScenario(closeAction: { Task {try await viewModel.markLevelCompleted(levelID: activeModal!.internalName); scene.currentLevel = -1} })) }, phase: 1),
                            
                            LevelNode(uid: 3, internalName: "P1_4_StressModule", title: "Stress", viewFactory: { AnyView(P1_4_StressModule(closeAction: { Task {try await viewModel.markLevelCompleted(levelID: activeModal!.internalName); scene.currentLevel = -1} })) }, phase: 1),
                            
                            LevelNode(uid: 4, internalName: "P1_5_StressTriggerMap", title: "Stress Triggers", viewFactory: { AnyView(P1_5_StressTriggerMap()) }, phase: 1),
                            
                            LevelNode(uid: 5, internalName: "P1_5_StressTriggerMap", title: "Personal Question", viewFactory: { AnyView(P1_5_StressTriggerMap()) }, phase: 1),
                            
                            LevelNode(uid: 6, internalName: "P1_MentalHealthMod", title: "Level 7", viewFactory: { AnyView(P1_MentalHealthMod(closeAction: { scene.selectedPhase = -1 })) }, phase: 1),
                            
                            LevelNode(uid: 7, internalName: "P1_MentalHealthMod", title: "Level 8", viewFactory: { AnyView(P1_MentalHealthMod(closeAction: { scene.selectedPhase = -1 })) }, phase: 1),
                            
                            LevelNode(uid: 8, internalName: "P1_MentalHealthMod", title: "Level 9", viewFactory: { AnyView(P1_MentalHealthMod(closeAction: { scene.selectedPhase = -1 })) }, phase: 1),
                            
                            LevelNode(uid: 9, internalName: "P1_MentalHealthMod", title: "Level 10", viewFactory: { AnyView(P1_MentalHealthMod(closeAction: { scene.selectedPhase = -1 })) }, phase: 1),
                            
                            LevelNode(uid: 0, internalName: "P1_MentalHealthMod", title: "Level 11", viewFactory: { AnyView(P1_MentalHealthMod(closeAction: { scene.selectedPhase = -1 })) }, phase: 2),
                        ]
                        
                         for levelName in user.completedLevels {
                             let level = getNodeFromInternalLevelName(internalName: levelName)
                             if (level != nil) {
                                 scene.completedLevelsList.append(CompletedLevel(uid: level!.uid, phase: level!.phase))
                             }
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
                        .opacity(0)
                    }
                    
                    Spacer()
                }
                .padding(.top, 70)
                
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
            .confettiCannon(counter: $confetti)
        }
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

//#Preview {
    //TestView()
//}
