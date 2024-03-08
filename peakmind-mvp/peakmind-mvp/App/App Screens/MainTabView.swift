//
//  MainScreenView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 2/19/24.
//

import SwiftUI

struct MainScreenView: View {
    @State private var selectedTab = 2

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                ChatView()
                    .tabItem {
                        Image(systemName: "ellipsis.message")
                    }
                    .tag(0)
                
                JournalEntriesView()
                    .tabItem {
                        Label("Journal", systemImage: "note.text")
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

