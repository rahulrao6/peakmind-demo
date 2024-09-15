import SwiftUI

struct TabViewMain: View {
    @State private var selectedTab = 2
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showingTutorial = false  // Manage the tutorial display based on user state
    @State private var showingQuizPrompt = false // State to manage quiz prompt overlay
    @State private var level2 = false // State to manage quiz prompt overlay
    @EnvironmentObject var CommunitiesViewModel : CommunitiesViewModel

    var body: some View {
        if let user = viewModel.currentUser {
            ZStack {
                // Main content with tabs
                TabView(selection: $selectedTab) {
                    TestView().environmentObject(viewModel)
                            .tabItem {
                                Label("Map", systemImage: "map.fill")
                            }
                            .tag(0)
                            .overlay {
                                if !user.hasCompletedInitialQuiz {
                                    quizPromptOverlay
                                }
                            }
                    
                    

                    SelfCareHome()
                        .tabItem {
                            Label("Self Care", systemImage: "heart")
                        }
                        .tag(1)
                    
                    HomeDashboard(selectedTab: $selectedTab)
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                        .tag(2)
                    
                    CommunitiesMainView2().environmentObject(viewModel).environmentObject(CommunitiesViewModel)
                        .tabItem {
                            Label("Communities", systemImage: "globe")
                        }
                        .tag(3)
                    
                    AvatarScreen()
                        .tabItem {
                            Label("Avatar", systemImage: "person.circle")
                        }
                        .tag(4)
                    
                }
                .accentColor(.white)
                .onAppear {
                    setupTabBarAppearance()
                    // Show tutorial if it hasn't been completed
                    showingTutorial = !user.hasCompletedTutorial
                }

                // Overlay Tutorial View
                if showingTutorial {
                    TutorialScene(isShowingTutorial: $showingTutorial)
                        .environmentObject(viewModel)
                        .transition(.opacity)
                        .zIndex(2)
                    /*
                    TutorialView(isShowingTutorial: $showingTutorial)
                        .environmentObject(TutorialViewModel())
                        .environmentObject(viewModel)
                        .transition(.opacity)
                        .zIndex(2)
                     */
                }
            }
        } else {
            Text("Loading...")
        }
    }

    private func setupTabBarAppearance() {
          let appearance = UITabBarAppearance()
          appearance.backgroundColor = UIColor(Color.black) // Set background color
          appearance.stackedLayoutAppearance.normal.iconColor = UIColor.lightGray
          appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
          appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
          appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

          appearance.inlineLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
          appearance.compactInlineLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)

          UITabBar.appearance().standardAppearance = appearance
          if #available(iOS 15.0, *) {
              UITabBar.appearance().scrollEdgeAppearance = appearance
          }
      }
  

        private var quizPromptOverlay: some View {
            VStack {
                Spacer()
                Text("Please complete the initial quiz to unlock this feature.")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(10)
                    .padding()
                Spacer()
            }
            .background(Color.black.opacity(0.5))
            .onTapGesture {
                showingQuizPrompt = true
            }
            .alert("Initial Quiz Required", isPresented: $showingQuizPrompt) {
                Button("Complete Quiz", action: {
                    // Navigate to quiz or perform an action to complete the quiz
                    selectedTab = 1 // Assuming quiz is on tab 1
                })
            } message: {
                Text("You need to complete the initial quiz to access this feature.")
            }
        }
}

struct TabViewMain_Previews: PreviewProvider {
    static var previews: some View {
        TabViewMain().environmentObject(AuthViewModel())
    }
}
