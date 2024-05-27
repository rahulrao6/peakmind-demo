//
//  TestView.swift
//  peakmind-mvp
//
//  Created by James Wilson on 5/26/24.
//

import SwiftUI
import SpriteKit

struct TestView: View {
    let positions: [CGPoint] = [CGPoint(x: 215, y: 150), CGPoint(x: 240, y: 300)]

    var body: some View {
        SpriteView(scene: setupScene())
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .edgesIgnoringSafeArea(.all)
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
