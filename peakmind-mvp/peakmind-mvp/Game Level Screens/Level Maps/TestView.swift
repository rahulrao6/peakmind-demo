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
import ProgressIndicatorView

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

struct LevelDecoration: Identifiable {
    var id = UUID()
    var name: String
    var size: CGSize
}


struct TestView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    let positions: [CGPoint] = [CGPoint(x: 215, y: 150), CGPoint(x: 240, y: 300), CGPoint(x: 215, y: 450), CGPoint(x: 240, y: 600), CGPoint(x: 180, y: 750),
                                CGPoint(x: 150, y: 750)]
    
    @State private var activeModal: LevelNode?
    @State private var confetti = 0
    @State private var currentPhase = 1
    @State private var progress = CGFloat(0.22)
    @State private var progressString = "0"
    @State private var canViewVertProgress = true
    
    @State private var showElevation: Bool = true
    
    @StateObject private var scene: MapScene = {
        let scene = MapScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scene.scaleMode = .fill
        scene.backgroundColor = .clear
        scene.imagePositions = [CGPoint(x: 215, y: 150), CGPoint(x: 240, y: 300), CGPoint(x: 190, y: 450), CGPoint(x: 150, y: 600), CGPoint(x: 180, y: 750), CGPoint(x: 195, y: 900), CGPoint(x: 240, y: 1050), CGPoint(x: 225, y: 1200), CGPoint(x: 165, y: 1350), CGPoint(x: 160, y: 1500)]
        scene.reloadGates()
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
                    .onChange(of: scene.selectedPhase) { levelID in
                        if (levelID == -1) {
                            showElevation = true
                        } else {
                            showElevation = false
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
                            scene.updatePhase()
                            scene.reloadGates()
                            
                            activeModal = nil
                            
                            if (scene.completedLevelsList.count % 10 == 0) {
                                scene.animateGate()
                                
                            }
                            
                            currentPhase = Int(floor(Double(scene.completedLevelsList.count) / 10.0))
                            
                            
                            progress = CGFloat(Float(user.completedLevels.count) / Float(50))
                            progressString = String(Int(Float(user.completedLevels.count) / Float(50) * Float(1000))) + "ft"
                            
                        }
                    }
                    .onAppear {
                        scene.levels = [

                            LevelNode(uid: 0, internalName: "P1_1", title: "Mental Health Intro", viewFactory: { AnyView(P1_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 1),
                            LevelNode(uid: 1, internalName: "P1_2", title: "Mental Health 2", viewFactory: { AnyView(P2_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 1),
                            LevelNode(uid: 2, internalName: "P1_3", title: "Coping Mechanism", viewFactory: { AnyView(P3_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 1),
                            LevelNode(uid: 3, internalName: "P1_4", title: "Stress Triggers", viewFactory: { AnyView(P4_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 1),
                            LevelNode(uid: 4, internalName: "P1_5", title: "Trigger Mapping", viewFactory: { AnyView(P5_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 1),
                            LevelNode(uid: 5, internalName: "P1_6", title: "Reframing", viewFactory: { AnyView(P6_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 1),
                            LevelNode(uid: 6, internalName: "P1_7", title: "Mood Boost", viewFactory: { AnyView(P7_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 1),
                            LevelNode(uid: 7, internalName: "P1_8", title: "Muscle Relaxation", viewFactory: { AnyView(P8_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 1),
                            LevelNode(uid: 8, internalName: "P1_9", title: "Wellness Question", viewFactory: { AnyView(P9_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 1),
                            LevelNode(uid: 9, internalName: "P1_10", title: "Minigame", viewFactory: { AnyView(GameUnavailable(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 1),
                            
                            LevelNode(uid: 0, internalName: "P2_1", title: "Anxiety Info", viewFactory: { AnyView(P2_1_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 2),
                            LevelNode(uid: 1, internalName: "P2_2", title: "Defining Anxiety", viewFactory: { AnyView(P2_2_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 2),
                            LevelNode(uid: 2, internalName: "P2_3", title: "Breathing Exercise", viewFactory: { AnyView(P2_3_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 2),
                            LevelNode(uid: 3, internalName: "P2_4", title: "Thought Patterns", viewFactory: { AnyView(P2_4_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 2),
                            LevelNode(uid: 4, internalName: "P2_5", title: "Quiz", viewFactory: { AnyView(P2_5_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 2),
                            LevelNode(uid: 5, internalName: "P2_6", title: "Set a Goal", viewFactory: { AnyView(P2_6_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 2),
                            LevelNode(uid: 6, internalName: "P2_7", title: "External Factors", viewFactory: { AnyView(P2_7_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 2),
                            LevelNode(uid: 7, internalName: "P2_8", title: "Mindfulness", viewFactory: { AnyView(P2_8_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 2),
                            LevelNode(uid: 8, internalName: "P2_9", title: "4/7/8 Breathing", viewFactory: { AnyView(LevelUnavailable(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 2),
                            LevelNode(uid: 9, internalName: "P2_10", title: "Minigame", viewFactory: { AnyView(
                                GameUnavailable(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 2),
                            
                            LevelNode(uid: 0, internalName: "P3_1", title: "Congratulations", viewFactory: { AnyView(P3_1_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 3),
                            LevelNode(uid: 1, internalName: "P3_2", title: "Anxiety Physical", viewFactory: { AnyView(P3_2_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 3),
                            LevelNode(uid: 2, internalName: "P3_3", title: "Mindfulness 2", viewFactory: { AnyView(P3_3_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 3),
                            LevelNode(uid: 3, internalName: "P3_4", title: "Trigger Mapping", viewFactory: { AnyView(P3_4_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 3),
                            LevelNode(uid: 4, internalName: "P3_5", title: "Connecting Anxiety", viewFactory: { AnyView(P3_5_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 3),
                            LevelNode(uid: 5, internalName: "P3_6", title: "Wellness Question", viewFactory: { AnyView(P3_6_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 3),
                            LevelNode(uid: 6, internalName: "P3_7", title: "Anxiety Scenario", viewFactory: { AnyView(P3_7_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 3),
                            LevelNode(uid: 7, internalName: "P3_8", title: "Anxiety Strategies", viewFactory: { AnyView(P3_8_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 3),
                            LevelNode(uid: 8, internalName: "P3_9", title: "Anxiety Coping", viewFactory: { AnyView(P3_9_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 3),
                            LevelNode(uid: 9, internalName: "P3_10", title: "Quiz", viewFactory: { AnyView(P3_10_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 3),
                            
                            LevelNode(uid: 0, internalName: "P4_1", title: "Phase Intro", viewFactory: { AnyView(P4_1_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 4),
                            LevelNode(uid: 1, internalName: "P4_2", title: "Self Care", viewFactory: { AnyView(P4_2_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 4),
                            LevelNode(uid: 2, internalName: "P4_3", title: "Resilience", viewFactory: { AnyView(P4_3_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 4),
                            LevelNode(uid: 3, internalName: "P4_4", title: "5/4/3/2/1 Grounding", viewFactory: { AnyView(P4_4_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 4),
                            LevelNode(uid: 4, internalName: "P4_5", title: "Wellness Question", viewFactory: { AnyView(P4_5_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 4),
                            LevelNode(uid: 5, internalName: "P4_6", title: "Mindfulness Strategies", viewFactory: { AnyView(P4_6_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 4),
                            LevelNode(uid: 6, internalName: "P4_7", title: "Routine Coping", viewFactory: { AnyView(P4_7_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 4),
                            LevelNode(uid: 7, internalName: "P4_8", title: "Self Care", viewFactory: { AnyView(P4_8_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 4),
                            LevelNode(uid: 8, internalName: "P4_9", title: "Scenario", viewFactory: { AnyView(P4_9_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 4),
                            LevelNode(uid: 9, internalName: "P4_10", title: "Minigame", viewFactory: { AnyView(GameUnavailable(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 4),
                            
                            LevelNode(uid: 0, internalName: "P5_1", title: "Phase Intro", viewFactory: { AnyView(P5_1_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 5),
                            LevelNode(uid: 1, internalName: "P5_2", title: "Support System", viewFactory: { AnyView(P5_2_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 5),
                            LevelNode(uid: 2, internalName: "P5_3", title: "Wellness Question", viewFactory: { AnyView(P5_3_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 5),
                            LevelNode(uid: 3, internalName: "P5_4", title: "Support Mapping", viewFactory: { AnyView(P5_4_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 5),
                            LevelNode(uid: 4, internalName: "P5_5", title: "Reflection", viewFactory: { AnyView(P5_5_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 4),
                            LevelNode(uid: 5, internalName: "P5_6", title: "Finding Community", viewFactory: { AnyView(P5_6_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 5),
                            LevelNode(uid: 6, internalName: "P5_7", title: "Finding Community 2", viewFactory: { AnyView(P5_7_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 5),
                            LevelNode(uid: 7, internalName: "P5_8", title: "Quiz", viewFactory: { AnyView(P5_8_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 5),
                            LevelNode(uid: 8, internalName: "P5_9", title: "Safe Spaces", viewFactory: { AnyView(P5_9_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 5),
                            LevelNode(uid: 9, internalName: "P5_10", title: "Self Reflection", viewFactory: { AnyView(P5_10_1(closeAction: { (str) -> Void in
                                completeLevel(str: str)
                            })) }, phase: 5),
                            

                        ]
                        
                        scene.phaseColors = [
                            UIColor(red: 102/255, green: 185/255, blue: 102/255, alpha: 1),   // Brighter Forest
                            UIColor(red: 152/255, green: 182/255, blue: 91/255, alpha: 1),    // Brighter Treeline
                            UIColor(red: 160/255, green: 170/255, blue: 180/255, alpha: 1),   // Brighter Rocky
                            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1),   // Bright Snowy (pure white)
                            UIColor(red: 220/255, green: 215/255, blue: 215/255, alpha: 1)    // Brighter Summit
                        ]
                        
                        if (user.LevelOneCompleted) {
                            scene.completedPhases = 1
                            currentPhase = 2
                        }
                        
                        if (user.LevelTwoCompleted) {
                            scene.completedPhases = 2
                            currentPhase = 3
                        }
                        
                        
                        
                        
                        
                        
                        
                         for levelName in user.completedLevels {
                             let level = getNodeFromInternalLevelName(internalName: levelName)
                             if (level != nil) {
                                 scene.completedLevelsList.append(CompletedLevel(uid: level!.uid, phase: level!.phase))
                             }
                         }
                        
                        currentPhase = Int(floor(Double(scene.completedLevelsList.count) / 10.0))
                        
                        //scene.reloadCompletedLevels()
                        scene.updatePhase()
                        scene.reloadGates()
                        
                        
                        progress = CGFloat(Float(user.completedLevels.count) / Float(50))
                        progressString = String(Int(Float(user.completedLevels.count) / Float(50) * Float(1000))) + "ft"
                         
                    }
                
                VStack {
                    VStack {
                        VStack {
                            Text("Mount Anxiety")
                                .font(.system(size: 30, weight: .heavy, design: .default))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            Text("Phase "+String(currentPhase))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            
                        }
                        .padding()
                        
                        
                    }
                    .frame(width: 350)
                    .background {
                        RoundedRectangle(cornerRadius: 13, style: .continuous).fill(Color.white)
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x:0, y:10)
                    }
                    
                    if (true) {
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .bottom) {
                                ProgressIndicatorView(isVisible: $canViewVertProgress, type: .impulseBar(progress: $progress, backgroundColor: .white.opacity(0.25)))
                                    .foregroundColor(.white.opacity(0.65))
                                    .frame(width: geometry.size.height - 100, height: 50) // Adjust the width based on the height
                                    .rotationEffect(Angle(degrees: -90))
                                
                                Spacer()
                                
                                Text(progressString)
                                    .foregroundColor(.white)
                            }
                            .position(x: 25, y: geometry.size.height / 2 - 40) // Adjust x position for left alignment
                            .padding(.leading, 20) // Ensure no padding on the leading side
                            .offset(x: showElevation ? 0 : -geometry.size.width) // Slide in from left
                            .animation(.easeInOut, value: showElevation) // Animate the change
                        }
                        
                        
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
    }
    
    func completeLevel(str: String) {
        Task {try await viewModel.markLevelCompleted(levelID: activeModal!.internalName); scene.currentLevel = -1}
        if(str != "") {
            viewModel.saveGameData(phase: activeModal!.phase, level: activeModal!.uid, data: str)
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
