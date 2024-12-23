//
//  BreathingExerciseView.swift
//  peakmind-mvp
//
//  Created by James Wilson on 3/26/24.
//

import SwiftUI
import AVFoundation
import AVKit
import SpriteKit

//
final class SpriteKitScene: SKScene {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        let player = AVPlayer(url: Bundle.main.url(forResource: "pkmdTriangleEncoded", withExtension: "mov")!)
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


struct BreathingExerciseView: View {
    var closeAction: (String) -> Void

    var body: some View {
        ZStack {
            // Background
            Image("MainBG")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            // Content
            VStack {
                // Title
                Text("Mt. Anxiety: Phase Two")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.bottom, 40)
                
                // First textbox
                VStack {
                    Text("Breathing for Stress")
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .padding()
                    Text("Let’s practice the 4/7/8 breathing mechanism. This helps to relax your body and allows you to disconnect from stressful situations.")
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .foregroundColor(.white)
                        .padding(.leading, 40)
                        .padding(.trailing, 40)
                        .padding(.bottom, 20)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 350, height: 200)
                .background(Color("Dark Blue").opacity(0.75))
                .cornerRadius(30)
                .shadow(radius: 5)
                
                // SpriteKit implementation for the transparent video
                SpriteKitUIView(scene: SpriteKitScene(size: CGSize(width: 200, height: 200)))
                    .frame(width: 250, height: 200)
                    .background(Color.clear)
                
                Spacer()
                
                // Instruction Text
                
                Button(action: {
                    closeAction("")
                }) {
                    Text("Tap to Continue")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .padding()
                        .offset(x: -120, y: 200)
                }
                
                // Sherpa Image and Prompt
                HStack {
                    Image("Sherpa")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 150)
                    
                    Text("It’s time for a breathing exercise!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color("Medium Blue"))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .padding()
        }
    }
}



// Other struct definitions (SubmitButton, ThankYouMessage, TruthfulPrompt, and Text extensions) remain unchanged...

/*struct BreathingExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        BreathingExerciseView().environmentObject(AuthViewModel())
    }
}
*/
