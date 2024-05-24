import SwiftUI

struct Level2MapView: View {

    // Tracks completed levels
    //@State private var completedLevels: Set<String> = []

    // State to manage navigation
    @State private var activeLink: String?

    // To show an alert when trying to access the locked node
    @State private var showAlert = false

    // Background image name
    let backgroundName = "Phase2"
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
                    let isUnlocked = index < nodeScreens.count - 1 || user.completedLevels2.count ?? 0 >= 6

                    Button(action: {
                        if index == nodeScreens.count - 1 && !isUnlocked {
                            showAlert = true
                        } else {
                            activeModal = Screen(screenName: screenName)
                        }
                    }) {
                        Image(user.completedLevels2.contains(screenName) ? "StoneComplete" : (isUnlocked ? "Stone" : "LockedStone"))
                            .resizable()
                            .frame(width: 70, height: 70)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Locked"), message: Text("You must complete 6 of the 9 prior levels to unlock this."), dismissButton: .default(Text("OK")))
                    }
                    .position(position)
                }
            }
            .fullScreenCover(item: $activeModal) { screen in
                destinationView(for: screen.screenName) {
                                                Task{
                                                    try await viewModel.markLevelCompleted2(levelID: screen.screenName)
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
            P2_1_Intro(closeAction: close)
        case "2":
            P2_1_AnxietyModule(closeAction: close)
        case "3":
            P2_3_DefiningAnxietyScenario(closeAction: close)
        case "4":
            P2_5_AnxietyWellnessQ(closeAction: close)
        case "5":
            P2_6_AnxietyModule(closeAction: close)
        case "6":
            P2_9_GoalSetting(closeAction: close)
        case "7":
            BreathingExerciseView(closeAction: close)
        case "8":
            P2_12_CopingModule(closeAction: close)
        case "9":
            P2_14_Reflection(closeAction: close)
        case "10":
            PacManGameView(closeAction: close).environmentObject(GameModel())
        default:
            Text("Unknown View").onTapGesture {
                close()
            }
        }
    }
}

