import SwiftUI

struct TabViewMain: View {
    @State private var selectedTab = 2
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        if let user = viewModel.currentUser {
            ZStack {
                TabView(selection: $selectedTab) {
                    LevelOneMapView()
                        .environmentObject(viewModel)
                        .tabItem {
                            Image(systemName: "map.fill")
                        }
                        .tag(0)
                    
                    SelfCareHome()
                        .tabItem {
                            Image(systemName: "heart")
                        }
                        .tag(1)
                    
                    HomeDashboard()
                        .environmentObject(viewModel)
                        .tabItem {
                            Image(systemName: "house")
                        }
                        .tag(2)
                    
                    CommunitiesMainView()
                        .tabItem {
                            Image(systemName: "globe")
                        }
                        .tag(3)
                    
                    AvatarScreen()
                        .tabItem {
                            Image(systemName: "person.circle")
                        }
                        .tag(4)
                }
                .accentColor(.white) // Ensure icons are white
                .onAppear() {
                    let appearance = UITabBarAppearance()
                    appearance.backgroundColor = UIColor(Color.black) // Set background color
                    appearance.stackedLayoutAppearance.normal.iconColor = UIColor.lightGray
                    appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
                    appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
                    appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
                    
                    // Customize the size
                    appearance.inlineLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4) // Move title up to make the bar shorter
                    appearance.compactInlineLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4) // For smaller devices
                    
                    UITabBar.appearance().standardAppearance = appearance
                    if #available(iOS 15.0, *) {
                        UITabBar.appearance().scrollEdgeAppearance = appearance
                    }
                }
            }
        }
    }
}

#Preview {
    TabViewMain()
}
