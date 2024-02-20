//
//  MainScreenView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 2/19/24.
//

import SwiftUI

struct MainScreenView: View {
    var body: some View {
        ZStack {
            TabView {
                HomeScreenView()
                    .tabItem {
                        Image("MapTemp")
                    }
                WorldScreen()
                    .tabItem {
                        Image("GlobeTemp")
                    }
                ChecklistScreen()
                    .tabItem {
                        Image("ListTemp")
                    }
                CartScreen()
                    .tabItem {
                        Image("CartTemp")
                    }
                IglooScreen()
                    .tabItem {
                        Image("IglooTemp")
                    }
            }
            
            //.accentColor(.white)
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
