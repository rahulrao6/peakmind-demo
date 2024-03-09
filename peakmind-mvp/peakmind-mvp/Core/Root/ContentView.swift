//
//  ContentView.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 2/12/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showingSplash = false // State to control splash screen visibility

    
    var body: some View {
        ZStack {
            // Main content conditionally displayed based on authentication status
            Group {
                if viewModel.userSession != nil && viewModel.currentUser  != nil {
                    if (viewModel.currentUser?.hasSetInitialAvatar == false) {
                        AvatarSettingsView()
                    } else if (viewModel.currentUser?.hasCompletedInitialQuiz == false && viewModel.currentUser?.hasSetInitialAvatar == true) {
                        QuestionsView()
                    } else {
                        HomeScreenView()
                    }
                } else {
                    LoginView()
                }
            }
            .zIndex(0) // Ensure main content is behind the splash screen in the ZStack

            // Splash screen displayed on top when showingSplash is true
            if showingSplash {
                SplashScreen()
                    .transition(.opacity) // Optional: add a transition effect when splash screen disappears
                    .zIndex(1) // Ensure splash screen is on top in the ZStack
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Adjust delay time as needed
                withAnimation {
                    showingSplash = false // Hide splash screen after delay
                }
            }
        }
    }
}
