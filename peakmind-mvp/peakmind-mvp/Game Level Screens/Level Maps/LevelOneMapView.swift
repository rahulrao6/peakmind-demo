import SwiftUI

struct Screen: Identifiable {
    let id = UUID()
    let screenName: String
}

struct LevelOneMapView: View {
    // State to manage navigation
    @State private var activeLink: String?

    // To show alerts
    @State private var showLockedAlert = false
    @State private var showNoLevelsAlert = false

    // Background image name
    let backgroundName = "Level1Map"
    @EnvironmentObject var viewModel: AuthViewModel

    @State private var activeModal: Screen?

    // List of node screen names in the correct order along with their positions
    let nodeScreens = [
        ("1", CGPoint(x: 215, y: 660)),
        ("2", CGPoint(x: 270, y: 580)),
        ("3", CGPoint(x: 180, y: 530)),
        ("4", CGPoint(x: 105, y: 460)),
        ("5", CGPoint(x: 190, y: 390)),
        ("6", CGPoint(x: 320, y: 330)),
        ("7", CGPoint(x: 200, y: 200)),
        ("8", CGPoint(x: 105, y: 140)),
        ("9", CGPoint(x: 160, y: 60)),
        ("10", CGPoint(x: 300, y: 15)) // This is the final node
    ]

    var body: some View {
        if let user = viewModel.currentUser {
            ZStack {
                Image(backgroundName)
                    .resizable()
                    .edgesIgnoringSafeArea(.all)

                ForEach(Array(nodeScreens.enumerated()), id: \.element.0) { index, node in
                    let (screenName, position) = node
                    let isUnlocked = index < nodeScreens.count - 1 || user.completedLevels.count >= 6

                    Button(action: {
                        if index == nodeScreens.count - 1 && !isUnlocked {
                            showLockedAlert = true
                        } else {
                            activeModal = Screen(screenName: screenName)
                        }
                    }) {
                        Image(user.completedLevels.contains(screenName) ? "StoneComplete" : (isUnlocked ? "Stone" : "LockedStone"))
                            .resizable()
                            .frame(width: 70, height: 70)
                    }
                    .alert(isPresented: $showLockedAlert) {
                        Alert(title: Text("Locked"), message: Text("You must complete 6 of the 9 prior levels to unlock this."), dismissButton: .default(Text("OK")))
                    }
                    .position(position)
                }
                if (showNoLevelsAlert) {
                    SherpaTutorialBox(tutorialText: "Complete 6 of the 9 levels to unlock the locked one and go to the next phase.") {
                        showNoLevelsAlert.toggle();
                    }
                }
            }


            .onAppear(){
                if (user.completedLevels.isEmpty && user.hasCompletedInitialQuiz) {
                    showNoLevelsAlert = true
                }
            }

            .fullScreenCover(item: $activeModal) { screen in
                destinationView(for: screen.screenName) {
                    Task {
                        try await viewModel.markLevelCompleted(levelID: screen.screenName)
                    }
                    activeModal = nil
                }
            }
        }
    }

    // Function to return the destination view based on the screen name
    @ViewBuilder
    private func destinationView(for screenName: String, close: @escaping () -> Void) -> some View {
        switch screenName {
        case "1":
            P1_Intro(closeAction: close)
        case "2":
            P1_MentalHealthMod(closeAction: close)
        case "3":
            P1_3_EmotionsScenario(closeAction: close)
        case "4":
            BoxBreathingView(closeAction: close)
        case "5":
            P1_10_LifestyleModule(closeAction: close)
        case "6":
            P1_6_PersonalQuestion(closeAction: close)
        case "7":
            P1_4_StressModule(closeAction: close)
        case "8":
            MuscleRelaxationView(closeAction: close)
        case "9":
            P1_14_Reflection(closeAction: close)
        case "10":
            Minigame2View(closeAction: close)
        default:
            Text("Unknown View").onTapGesture {
                close()
            }
        }
    }
}

// Preview
struct LevelOneMapView_Previews: PreviewProvider {
    static var previews: some View {
        LevelOneMapView().environmentObject(AuthViewModel())
    }
}
