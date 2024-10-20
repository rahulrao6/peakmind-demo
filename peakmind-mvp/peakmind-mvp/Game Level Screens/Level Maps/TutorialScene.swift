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
import FirebaseFirestore

struct TutorialScene: View {
    var closeAction: () -> Void
    @EnvironmentObject var viewModel: AuthViewModel
    
    let positions: [CGPoint] = [CGPoint(x: 215, y: 150), CGPoint(x: 240, y: 300), CGPoint(x: 215, y: 450), CGPoint(x: 240, y: 600), CGPoint(x: 180, y: 750),
                                CGPoint(x: 150, y: 750)]
    
    @State private var activeModal: LevelNode?
    @State private var confetti = 0
    @State private var currentPhase = 1
    
    @Binding var isShowingTutorial: Bool
    
    @StateObject private var scene: MapScene = {
        let scene = MapScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scene.scaleMode = .fill
        scene.backgroundColor = .clear
        scene.imagePositions = [CGPoint(x: 215, y: 150), CGPoint(x: 240, y: 300), CGPoint(x: 190, y: 450), CGPoint(x: 150, y: 600), CGPoint(x: 180, y: 750), CGPoint(x: 195, y: 900), CGPoint(x: 240, y: 1050), CGPoint(x: 225, y: 1200), CGPoint(x: 165, y: 1350), CGPoint(x: 160, y: 1500)]
        scene.maxY = 1
        return scene
    }()
    
    func buildCompletedLevelArray(uid: Int) -> [CompletedLevel] {
        var arr: [CompletedLevel] = []
        
        for i in 0...uid {
            let completedLevel = CompletedLevel(uid: i, phase: 1)
            arr.append(completedLevel)
        }
        
        return arr
    }
    
    
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
                        
                        scene.reloadCompletedLevels()
                        
                        
                    }
                }
                .onAppear {
                    
                    scene.levels = [
                        LevelNode(uid: 0, internalName: "T1", title: "PeakMind Game", viewFactory: { AnyView(Tutorial1(closeAction: { (str) -> Void in
                            completeLevel(str: str)
                        })) }, phase: 1),
                        LevelNode(uid: 1, internalName: "T2", title: "Routines", viewFactory: { AnyView(Tutorial2(closeAction: { (str) -> Void in
                            completeLevel(str: str)
                        })) }, phase: 1),
                        LevelNode(uid: 2, internalName: "T3", title: "Flow Mode", viewFactory: { AnyView(Tutorial3(closeAction: { (str) -> Void in
                            completeLevel(str: str)
                        })) }, phase: 1),
                        LevelNode(uid: 3, internalName: "T4", title: "Profiles", viewFactory: { AnyView(Tutorial4(closeAction: { (str) -> Void in
                            completeLevel(str: str)
                        })) }, phase: 1),
                        LevelNode(uid: 4, internalName: "T5", title: "Quests", viewFactory: { AnyView(Tutorial5(closeAction: { (str) -> Void in
                            completeLevel(str: str)
                        })) }, phase: 1),
                        LevelNode(uid: 5, internalName: "T6", title: "Journal", viewFactory: { AnyView(Tutorial6(closeAction: { (str) -> Void in
                            completeLevel(str: str)
                        })) }, phase: 1),
                        LevelNode(uid: 6, internalName: "T7", title: "Daily Check-In", viewFactory: { AnyView(Tutorial7(closeAction: { (str) -> Void in
                            completeLevel(str: str)
                        })) }, phase: 1),
                        LevelNode(uid: 7, internalName: "T8", title: "AI Wellness", viewFactory: { AnyView(Tutorial8(closeAction: { (str) -> Void in
                            completeLevel(str: str)
                        })) }, phase: 1),
                    ]
                     
                    
                    scene.phaseColors = [
                        UIColor(red: 142/255, green: 214/255, blue: 137/255, alpha: 1)
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
                    VStack {
                        Button(action: {
                            closeAction()
                        }, label: {
                            Text("Exit Tutorial")
                                .foregroundStyle(.gray)
                                .padding(20)

                        })
                        .background {
                            RoundedRectangle(cornerRadius: 13, style: .continuous).fill(Color.white)
                                .shadow(color: Color.black.opacity(0.3), radius: 10, x:0, y:10)
                        }
                        
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 13, style: .continuous).fill(Color.white)
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x:0, y:10)
                    }
                    .padding(.leading, 25)
                    .frame(width: 200, alignment: .leading)
                    .opacity(1)
                    Spacer()

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
    
    func completeLevel(str: String) {
        Task {
            scene.completedLevelsList.append(CompletedLevel(uid: scene.currentLevel, phase: 1))
            scene.currentLevel = -1
            if(scene.completedLevelsList.count == 8) {
                closeAction()
            }
        }

    }
    
    private func completeTutorial() {
        guard let user = viewModel.currentUser else {
            print("No authenticated user found.")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.id ?? "")
        userRef.updateData(["hasCompletedTutorial": true]) { error in
            if let error = error {
                print("Error updating tutorial completion flag: \(error)")
            } else {
                print("Tutorial completion flag updated successfully.")
                Task {
                    await viewModel.fetchUser()  // Refresh user data
                }
            }
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
