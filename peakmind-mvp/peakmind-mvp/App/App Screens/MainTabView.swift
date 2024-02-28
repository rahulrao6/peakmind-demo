//
//  MainScreenView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 2/19/24.
//

import SwiftUI

struct MainScreenView: View {
    @State private var selectedTab = 2  // Index for ChecklistScreen, assuming it's the middle tab

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                ChecklistScreen()
                    .tabItem {
                        Image(systemName: "ellipsis.message")
                    }
                    .tag(0)
                
                JournalView()
                    .tabItem {
                        Image(systemName: "note.text")
                    }
                    .tag(1)
                HomeScreenView()
                    .tabItem {
                        Image(systemName: "house")
                    }
                    .tag(2)
                
                WorldScreen()
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
            .accentColor(.white)
            .onAppear() {
                UITabBar.appearance().backgroundColor = UIColor.black.withAlphaComponent(0.8)
                UITabBar.appearance().unselectedItemTintColor = UIColor.lightGray
            }
        }
    }
}

#Preview {
    MainScreenView()
}
