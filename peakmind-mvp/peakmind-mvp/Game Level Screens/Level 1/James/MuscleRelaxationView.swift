//
//  MuscleRelaxationExplanationView.swift
//  peakmind-mvp
//
//  Created by James Wilson on 4/13/24.
//

import SwiftUI
import AVFoundation
import AVKit
import SpriteKit

final class BreathingExerciseScene: SKScene {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        let player = AVPlayer(url: Bundle.main.url(forResource: "pkmdMuscleExerciseEncoded", withExtension: "mov")!)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            player.seek(to: CMTime.zero)
            player.play()
        }
        // make sure aspect ratio is right
        if let track = player.currentItem?.asset.tracks(withMediaType: .video).first {
            let videoSize = track.naturalSize.applying(track.preferredTransform)
            let videoAspectRatio = abs(videoSize.width / videoSize.height)

            let video = SKVideoNode(avPlayer: player)
            video.size = CGSize(width: size.width, height: size.width / videoAspectRatio)
            video.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
            addChild(video)
            player.play()
            
            scaleMode = .aspectFill
            backgroundColor = .clear
        } else {
            fatalError("Could not retrieve video tracks")
        }
    }
}

struct MuscleRelaxationView: View {
    var closeAction: () -> Void

    var body: some View {
        ZStack {
            Image("MainBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
            
            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(width: 140)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
                .offset(x: 25, y: 20)
            
            Text("We should understand coping mechanisms and how they work.")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color("Medium Blue"))
                .frame(width: 150)
                .offset(x: 90, y: 250)
            
            VStack(spacing: 0) {
                Text("Mt. Anxiety: Level One")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .padding(.bottom, 40)

                ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
                    VStack {
                        SpriteKitUIView(scene: BreathingExerciseScene(size: CGSize(width: 300, height: 300)))
                            .frame(width: 300, height: 300)
                            .background(Color.clear)
                        
                        Button(action: {closeAction()}) {
                            Text("Continue")
                        }
                    }
                    .frame(width: 300, height: 380)
                    .background(Color("Dark Blue").opacity(0.75))
                    .cornerRadius(15)
                    .shadow(radius: 5)

                }
                Spacer()
            }
        }
    }
}

//struct MuscleRelaxationView_Previews: PreviewProvider {
//    static var previews: some View {
//        MuscleRelaxationView()
//    }
//}
