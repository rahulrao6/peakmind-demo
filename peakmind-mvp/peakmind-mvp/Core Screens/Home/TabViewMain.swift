import SwiftUI
struct TabViewMain: View {
  @State private var selectedTab = 2 // Home tab is the default (index 2)
  @EnvironmentObject var viewModel: AuthViewModel
  @EnvironmentObject var healthKitManager: HealthKitManager
  var body: some View {
    // Main content with tabs
    TabView(selection: $selectedTab) {
      HomeDashboard(selectedTab: $selectedTab)
        .tabItem {
          Label("Home", systemImage: "square.grid.2x2")
        }
        .tag(2) // Default tab
      RoutineBuilderView().environmentObject(viewModel)
        .tabItem {
          Label("Routines", systemImage: "repeat")
        }
        .tag(1)
        TestView().environmentObject(viewModel)
            .tabItem {
                Label("Map", systemImage: "map.fill")
            }
        .tag(0)
      YourQuestsView().environmentObject(viewModel)
        .tabItem {
          Label("Quests", systemImage: "flag")
        }
        .tag(3)
        RectangleView().environmentObject(viewModel).environmentObject(NetworkManager())
        .tabItem {
          Label("Profiles", systemImage: "brain")
        }
        .tag(4)
    }
    .accentColor(.white)
    .onAppear {
      setupTabBarAppearance()
      let now = Date()
      let startOfDay = Calendar.current.startOfDay(for: now)
      guard let startDate = Calendar.current.date(byAdding: .day, value: -8, to: startOfDay) else { return }
        guard let endDate = Calendar.current.date(byAdding: .day, value: -1, to: startOfDay) else { return }
      let userId = viewModel.currentUser?.id ?? "";
        healthKitManager.fetchStepCount(for: userId, startDate: startDate, endDate: endDate)
        healthKitManager.fetchSleepAnalysis(for: userId, startDate: startDate, endDate: endDate)
        healthKitManager.fetchActiveCalories(for: userId, startDate: startDate, endDate: endDate)
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
}
struct TabViewMain_Previews: PreviewProvider {
  static var previews: some View {
    TabViewMain()
      .environmentObject(AuthViewModel()) // Inject the necessary environment objects
  }
}
