import SwiftUI

struct LevelOneMapView: View {
    // Tracks completed levels
    @State private var completedLevels: Set<String> = []

    // State to manage navigation
    @State private var activeLink: String?

    // To show an alert when trying to access the locked node
    @State private var showAlert = false

    // Background image name
    let backgroundName = "Level1Map"

    // List of node screen names in the correct order along with their positions
    let nodeScreens = [
        ("Module2", CGPoint(x: 300, y: 680)),
        ("AnxietyModuleView", CGPoint(x: 170, y: 600)),
        ("AnxietyQuiz", CGPoint(x: 260, y: 485)),
        ("HabitExplanation", CGPoint(x: 340, y: 360)),
        ("SetHabits", CGPoint(x: 220, y: 300)),
        ("Reflection", CGPoint(x: 170, y: 230)),
        ("SMARTGoalSettingView", CGPoint(x: 220, y: 150)),
        ("ScenarioPres", CGPoint(x: 315, y: 120)),
        ("ScenarioQuiz", CGPoint(x: 325, y: 50)),
        ("WellnessQ", CGPoint(x: 200, y: 10)) // This is the final node
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
                            .frame(width: 69, height: 69)
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
        case "Module2":
            Module2View()
        case "AnxietyModuleView":
            AnxietyModuleView()
        case "AnxietyQuiz":
            AnxietyQuiz()
        case "SetHabits":
            SetHabits()
        case "SMARTGoalSettingView":
            SMARTGoalSettingView()
        case "Level1Complete":
            Level1Complete()
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
