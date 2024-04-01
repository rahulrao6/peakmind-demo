//
//  SpriteKitUIView.swift
//  peakmind-mvp
//
//  Created by James Wilson on 3/27/24.
//

import SwiftUI
import SpriteKit

// custom view which enables transparency
struct SpriteKitUIView: UIViewRepresentable {
    var scene: SKScene
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.allowsTransparency = true // Allow transparency
        view.presentScene(scene)
        view.backgroundColor = UIColor.clear // Explicitly set the background color to clear
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
    }
}
