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
        ("P1_Intro", CGPoint(x: 215, y: 660)),
        ("P1_MentalHealthMod", CGPoint(x: 270, y: 580)),
        ("P1_3_EmotionsScenario", CGPoint(x: 180, y: 530)),
        ("P1_4_StressModule", CGPoint(x: 105, y: 460)),
        ("P1_5_StressTriggerMap", CGPoint(x: 190, y: 390)),
        ("BoxBreathingView", CGPoint(x: 320, y: 330)),
        ("P1_6_PersonalQuestion", CGPoint(x: 200, y: 200)),
        ("MuscleRelaxationView", CGPoint(x: 105, y: 140)),
        ("P1_14_Reflection", CGPoint(x: 160, y: 60)),
        ("Minigame2View", CGPoint(x: 300, y: 15)) // This is the final node
    ]

//    var body: some View {
//        if let user = viewModel.currentUser { NavigationView {
//            ZStack {
//                // Set the background
//                Image(backgroundName)
//                    .resizable()
//                    .edgesIgnoringSafeArea(.all)
//
//                // Layout for level buttons
//                ForEach(Array(nodeScreens.enumerated()), id: \.element.0) { index, node in
//                    let (screenName, position) = node
//                    let isUnlocked = index < nodeScreens.count - 1 || user.completedLevels.count ?? 0 >= 6
//
//                    Button(action: {
//                        if index == nodeScreens.count - 1 && !isUnlocked {
//                            // Show alert if the last node is locked and the condition isn't met
//                            showAlert = true
//                        } else {
//                            // Navigate if the node is unlocked
//                            activeLink = screenName
//                        }
//                    }) {
//                        Image(user.completedLevels.contains(screenName) ? "StoneComplete" : (isUnlocked ? "Stone" : "LockedStone"))
//                            .resizable()
//                            .frame(width: 70, height: 70)
//                    }
//                    .alert(isPresented: $showAlert) {
//                        Alert(title: Text("Locked"), message: Text("You must complete 6 of the 9 previous modules to unlock this."), dismissButton: .default(Text("OK")))
//                    }
//                    .position(position)
//
//                    // Hidden NavigationLink to manage navigation
//                    NavigationLink(
//                        destination: destinationView(for: screenName).onDisappear {
//                            Task{
//                                try await viewModel.markLevelCompleted(levelID: screenName)
//                            }
//                            //completedLevels.insert(screenName) // Mark as complete when view disappears
//                        },
//                        tag: screenName,
//                        selection: $activeLink
//                    ) {
//                        EmptyView()
//
//                    }
//                    .hidden()
//                    // Hide the navigation link as it is only used for triggering navigation
//                }
//            }
//            .navigationBarTitle("", displayMode: .inline)
//            .onAppear {
//                Task {
//                    // await viewModel.fetchCompletedLevels()
//                }
//            }
//        }
//        }
//    }
    
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
                        Alert(title: Text("Locked"), message: Text("You must complete 6 of the 9 previous modules to unlock this."), dismissButton: .default(Text("OK")))
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
        case "P1_Intro":
            P1_Intro(closeAction: close)
        case "P1_MentalHealthMod":
            P1_MentalHealthMod(closeAction: close)
        case "P1_3_EmotionsScenario":
            P1_3_EmotionsScenario(closeAction: close)
        case "P1_4_StressModule":
            P1_4_StressModule(closeAction: close)
        case "P1_5_StressTriggerMap":
            P1_10_LifestyleModule(closeAction: close)
        case "P1_6_PersonalQuestion":
            P1_6_PersonalQuestion(closeAction: close)
        case "BoxBreathingView":
            BoxBreathingView(closeAction: close)
        case "MuscleRelaxationView":
            MuscleRelaxationView(closeAction: close)
        case "P1_14_Reflection":
            P1_14_Reflection(closeAction: close)
        case "Minigame2View":
            Minigame2View(closeAction: close)
        default:
            Text("Unknown View").onTapGesture {
                close()
            }
        }
    }
}
