import SwiftUI

struct TabViewMain: View {
    @State private var selectedTab = 2  // Home tab is the default (index 2)
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        // Main content with tabs
        TabView(selection: $selectedTab) {
            HomeDashboard(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "square.grid.2x2")
                }
                .tag(2) // Default tab

            RoutineBuilderView()
                .tabItem {
                    Label("Routines", systemImage: "repeat")
                }
                .tag(1)

            JournalView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(0)

            YourQuestsView()
                .tabItem {
                    Label("Quests", systemImage: "flag")
                }
                .tag(3)

            JournalView()
                .tabItem {
                    Label("Profiles", systemImage: "brain")
                }
                .tag(4)
        }
        .accentColor(.white)
        .onAppear {
            setupTabBarAppearance()
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
            .environmentObject(AuthViewModel())  // Inject the necessary environment objects
    }
}
