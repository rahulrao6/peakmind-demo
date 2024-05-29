//
//  TestView.swift
//  peakmind-mvp
//
//  Created by James Wilson on 5/26/24.
//

import SwiftUI
import SpriteKit
import Glur

struct Phase: Identifiable {

    var id = UUID()

    var uid: Int

    var title: String

    var viewFactory: () -> AnyView

    var position: CGPoint

}

struct TestView: View {
    let positions: [CGPoint] = [CGPoint(x: 215, y: 150), CGPoint(x: 240, y: 300)]
    let phases: [Phase] = [

            Phase(uid: 0, title: "Intro", viewFactory: { AnyView(P1_Intro(closeAction: { print("Close Intro") })) }, position: CGPoint(x: 215, y: 150)),

            Phase(uid: 1, title: "Mental Health", viewFactory: { AnyView(P1_MentalHealthMod(closeAction: { print("Close Mental Health Mod") })) }, position: CGPoint(x: 240, y: 300)),

        ]
    
    @State private var activeModal: Phase?
    
    @StateObject private var scene: MapScene = {
        let scene = MapScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scene.scaleMode = .fill
        scene.backgroundColor = .clear
        scene.imagePositions = [CGPoint(x: 215, y: 150), CGPoint(x: 240, y: 300)]
        scene.phases = [
            Phase(uid: 0, title: "Intro", viewFactory: { AnyView(P1_Intro(closeAction: { scene.currentPhase = -1 })) }, position: CGPoint(x: 215, y: 150)),

            Phase(uid: 1, title: "Mental Health", viewFactory: { AnyView(P1_MentalHealthMod(closeAction: { scene.currentPhase = -1 })) }, position: CGPoint(x: 240, y: 300)),
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
                .onChange(of: scene.currentPhase) { phaseIndex in

                                if phaseIndex != -1 {

                                    activeModal = phases[phaseIndex]

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
                        
                        Text("Level 1")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                    }
                    .padding()
                    
                }
                .frame(width: 350)
                .background {
                    RoundedRectangle(cornerRadius: 13, style: .continuous).fill(Color.white)
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x:0, y:10)
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
