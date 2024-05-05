import SwiftUI

struct LevelOneMapView: View {
    // Tracks completed levels
    @State private var completedLevels: Set<String> = []

    // State to manage navigation
    @State private var activeLink: String?

    // To show an alert when trying to access the locked node
    @State private var showAlert = false

    // Background image name
    let backgroundName = "Mughees"

    // List of node screen names in the correct order along with their positions
    let nodeScreens = [
        ("P1_Intro", CGPoint(x: 285, y: 680)),
        ("P1_MentalHealthMod", CGPoint(x: 170, y: 600)),
        ("P1_3_EmotionsScenario", CGPoint(x: 120, y: 530)),
        ("P1_4_StressModule", CGPoint(x: 340, y: 400)),
        ("P1_5_StressTriggerMap", CGPoint(x: 230, y: 280)),
        ("P1_6_PersonalQuestion", CGPoint(x: 170, y: 235)),
        ("BoxBreathingView", CGPoint(x: 110, y: 130)),
        ("MuscleRelaxationView", CGPoint(x: 200, y: 100)),
        ("P1_14_Reflection", CGPoint(x: 300, y: 70)),
        ("Minigame2View", CGPoint(x: 340, y: 10)) // This is the final node
    ]
    
    

    var body: some View {
        NavigationView {
            ZStack {
                // Set the background
                Image(backgroundName)
                    .resizable()
                    .edgesIgnoringSafeArea(.all)

                // Layout for level buttons
                ForEach(Array(nodeScreens.enumerated()), id: \.element.0) { index, node in
                    let (screenName, position) = node
                    let isUnlocked = index < nodeScreens.count - 1 || completedLevels.count >= 6

                    Button(action: {
                        if index == nodeScreens.count - 1 && !isUnlocked {
                            // Show alert if the last node is locked and the condition isn't met
                            showAlert = true
                        } else {
                            // Navigate if the node is unlocked
                            activeLink = screenName
                        }
                    }) {
                        Image(completedLevels.contains(screenName) ? "StoneComplete" : (isUnlocked ? "Stone" : "LockedStone"))
                            .resizable()
                            .frame(width: 57, height: 57)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Locked"), message: Text("You must complete 6 of the 9 previous modules to unlock this."), dismissButton: .default(Text("OK")))
                    }
                    .position(position)

                    // Hidden NavigationLink to manage navigation
                    NavigationLink(
                        destination: destinationView(for: screenName).onDisappear {
                            completedLevels.insert(screenName) // Mark as complete when view disappears
                        },
                        tag: screenName,
                        selection: $activeLink
                    ) {
                        EmptyView()
                    }
                    .hidden() // Hide the navigation link as it is only used for triggering navigation
                }
            }
            .navigationBarTitle("", displayMode: .inline)
        }
    }

    // Function to return the destination view based on the screen name
    @ViewBuilder
    private func destinationView(for screenName: String) -> some View {
        switch screenName {
        case "P1_Intro":
            P1_Intro()
        case "P1_MentalHealthMod":
            P1_MentalHealthMod()
        case "P1_3_EmotionsScenario":
            P1_3_EmotionsScenario()
        case "P1_4_StressModule":
            P1_4_StressModule()
        case "P1_5_StressTriggerMap":
            P1_10_LifestyleModule()
        case "P1_6_PersonalQuestion":
            P1_6_PersonalQuestion()
        case "BoxBreathingView":
            BoxBreathingView()
        case "MuscleRelaxationView":
            MuscleRelaxationView()
        case "P1_14_Reflection":
            P1_14_Reflection()
        case "Minigame2View":
            Minigame2View()
        default:
            Text("Unknown View")
        }
    }
}

// Preview
struct LevelOneMapView_Previews: PreviewProvider {
    static var previews: some View {
        LevelOneMapView()
    }
}
