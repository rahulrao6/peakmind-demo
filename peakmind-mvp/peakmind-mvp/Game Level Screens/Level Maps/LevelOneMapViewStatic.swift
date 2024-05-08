import SwiftUI

struct LevelOneMapViewStatic: View {
    // Background image name
    let backgroundName = "Level1Map"

    // List of node screen names in the correct order along with their positions
    let nodeScreens = [
        ("P1_Intro", CGPoint(x: 215, y: 660)),
        ("P1_MentalHealthMod", CGPoint(x: 270, y: 580)),
        ("P1_3_EmotionsScenario", CGPoint(x: 180, y: 530)),
        ("P1_4_StressModule", CGPoint(x: 105, y: 460)),
        ("P1_5_StressTriggerMap", CGPoint(x: 190, y: 390)),
        ("BoxBreathingView", CGPoint(x: 320, y: 330)),
        ("P1_6_PersonalQuestion", CGPoint(x: 200, y: 200)),
        ("MuscleRelaxationView", CGPoint(x: 105, y: 140)),
        ("P1_14_Reflection", CGPoint(x: 160, y: 60)),
        ("Minigame2View", CGPoint(x: 300, y: 15))
    ]

    var body: some View {
        ZStack {
            // Set the background
            Image(backgroundName)
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            // Layout for level buttons (static display)
            ForEach(nodeScreens, id: \.0) { node in
                let (screenName, position) = node
                Image("Stone")  // Use a generic icon to represent each node
                    .resizable()
                    .frame(width: 70, height: 70)
                    .position(position)
            }
        }
    }
}

// Preview
struct LevelOneMapViewStatic_Previews: PreviewProvider {
    static var previews: some View {
        LevelOneMapViewStatic()
    }
}
