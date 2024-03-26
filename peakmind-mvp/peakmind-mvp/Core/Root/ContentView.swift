//
//  ContentView.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 2/12/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showingSplash = true // State to control splash screen visibility
    @State private var navigateToStoreScreen = false // State to control splash screen visibility
    @State private var navigateToInventoryScreen = false // State to control splash screen visibility

    
    var body: some View {
        ZStack {
            // Main content conditionally displayed based on authentication status
            Group {
                if $viewModel.userSession != nil && viewModel.currentUser  != nil {
                    //logged in
                    if (viewModel.currentUser?.hasCompletedInitialQuiz == true) {
                        HomeScreenView()
                            .environmentObject(viewModel)
                        //StoreView()
                        //TentPurchase()
                    } else {
                        if (viewModel.currentUser?.hasSetInitialAvatar == false) {
                            AvatarMenuView()
                                .environmentObject(viewModel)
                        } else {
                            HomeScreenView()
                                .environmentObject(viewModel)
                            //AnxietyQuiz()
                            //TentPurchase()
                        }
                    }
                } else {
                    LoginView()
                }
            }
            .zIndex(0) // Ensure main content is behind the splash screen in the ZStack
            .environment(\.colorScheme, .light) // Force light mode for the entire app


            // Splash screen displayed on top when showingSplash is true
            if showingSplash {
                SplashScreen()
                    .transition(.opacity) // Optional: add a transition effect when splash screen disappears
                    .zIndex(1) // Ensure splash screen is on top in the ZStack
                
                
            }


                  // Button to display current balance - Show only when the user is logged in
//            if viewModel.userSession != nil && viewModel.currentUser != nil {
//                VStack {
//                    HStack {
//                        Spacer()
//
//                        Button(action: {
//                            navigateToInventoryScreen = true
//                        }) {
//                            if let currentBalance = viewModel.currentUser?.currencyBalance {
//                                Text("$\(currentBalance)")
//                                    .font(.headline)
//                                    .foregroundColor(.white)
//                                    .padding(8)
//                                    .background(Color.blue)
//                                    .cornerRadius(8)
//                            }
//                        }
//       
//                        .sheet(isPresented: $navigateToInventoryScreen) {
//                            InventoryView()
//                        }
//                         // Place button at the top of the screen
//                         // Adjust padding
//                        
//                        Button(action: {
//                            navigateToStoreScreen = true
//                        }) {
//                            Image(systemName: "cart.fill") // Marketplace icon
//                                .resizable()
//                                .frame(width: 24, height: 24) // Smaller size
//                                .padding(8) // Add padding
//                                .background(Color.darkBlue) // Dark blue background
//                                .foregroundColor(.white)
//                                .clipShape(Circle())
//                        }
//                        // Adjust padding
//                        .shadow(radius: 5)
//                        .background(
//                            NavigationLink(destination: StoreView(), isActive: $navigateToStoreScreen) {
//                                EmptyView()
//                            }
//                        )
//                        
//                        
//                    }
//                    Spacer()
//                }
//                .padding()
//            }
            

            
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

    

