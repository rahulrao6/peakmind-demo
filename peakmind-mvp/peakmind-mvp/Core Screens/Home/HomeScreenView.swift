//
//  HomeScreen.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 2/19/24.
//

import SwiftUI


struct HomeScreenView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    @State private var navigateToPlayScreen = false
    @State private var navigateToPlanScreen = false
    @State private var navigateToChatScreen = false
    @State private var navigateToJournalScreen = false
    @State private var navigateToProfileScreen = false
    @State private var navigateToStoreScreen = false // State to control splash screen visibility
    @State private var navigateToInventoryScreen = false // State to control splash screen visibility
    
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    var body: some View {
        NavigationView {
            ZStack {
                Image("HomeScreenBG")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        Spacer()

                        Button(action: {
                            navigateToInventoryScreen = true
                        }) {
//                            if let currentBalance = viewModel.currentUser?.currencyBalance {
//                                Text(currencyFormatter.string(from: NSNumber(value: currentBalance)) ?? "")
//                                    .font(.headline)
//                                    .foregroundColor(.white)
//                                    .padding(8)
//                                    .background(Color.darkBlue)
//                                    .cornerRadius(8)
//                            }
                        }
       
                        .sheet(isPresented: $navigateToInventoryScreen) {
                            InventoryView()
                        }
                         // Place button at the top of the screen
                         // Adjust padding
                        
                        Button(action: {
                            navigateToStoreScreen = true
                        }) {
                            Image(systemName: "cart.fill") // Marketplace icon
                                .resizable()
                                .frame(width: 24, height: 24) // Smaller size
                                .padding(8) // Add padding
                                .background(Color.darkBlue) // Dark blue background
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        // Adjust padding
                        
                        .shadow(radius: 5)
                        .background(
                            NavigationLink(destination: StoreView(), isActive: $navigateToStoreScreen) {
                                EmptyView()
                            }
                        )
                        
                        
                    }
                    .padding(.trailing,8)
                    Spacer()
                }
                
                .padding()
                
                VStack(spacing: 0) {
                    Image("PM3DLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .padding(.vertical, -0)
                    
                    
                    if (viewModel.currentUser?.hasCompletedInitialQuiz == false) {
                        Button(action: {
                            navigateToPlayScreen = true
                        }) {
                            Image("PlayButton")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 200)
                                .shadow(radius: 10)
                        }
                        .background(
                            NavigationLink(destination: IntroPlayView(), isActive: $navigateToPlayScreen) {
                                EmptyView()
                            }
                        )
                        .padding(.vertical, -70)
                    } else {
                        
                        Button(action: {
                            navigateToPlayScreen = true
                        }) {
                            Image("PlayButton")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 200)
                                .shadow(radius: 10)
                        }
                        .background(
          
                            NavigationLink(destination: PlayScreen2().navigationBarBackButtonHidden(true), isActive: $navigateToPlayScreen) {
                                    EmptyView()
                                }
                        )
                        .padding(.vertical, -70)
                    }

                    
                    Button(action: {
                        navigateToPlanScreen = true
                    }) {
                        Image("YourPlan")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 200)
                            .shadow(radius: 10)
                    }
                    .background(
                        NavigationLink(destination: PersonalizedPlanNew(), isActive: $navigateToPlanScreen) {
                            EmptyView()
                        }
                    )

                    HStack(spacing: 20) {
                                          Button(action: {
                                              navigateToChatScreen = true
                                          }) {
                                              Image("ChatButton")
                                                  .resizable()
                                                  .scaledToFit()
                                                  .frame(width: 60, height: 60)
                                          }
                                          .background(
                                              NavigationLink(destination: ChatView(), isActive: $navigateToChatScreen) {
                                                  EmptyView()
                                              }
                                          )

                                          Button(action: {
                                              navigateToJournalScreen = true
                                          }) {
                                              Image("JournalButton")
                                                  .resizable()
                                                  .scaledToFit()
                                                  .frame(width: 60, height: 60)
                                          }
                                          .background(
                                              NavigationLink(destination: JournalEntriesView(), isActive: $navigateToJournalScreen) {
                                                  EmptyView()
                                              }
                                          )

                                          Button(action: {
                                              navigateToProfileScreen = true
                                          }) {
                                              Image("ProfileButton")
                                                  .resizable()
                                                  .scaledToFit()
                                                  .frame(width: 60, height: 60)
                                          }
                                          .background(
                                              NavigationLink(destination: AvatarScreen(), isActive: $navigateToProfileScreen) {
                                                  EmptyView()
                                              }
                                          )
                                      }
                    .offset(x: 50)

                }
                .offset(y: -30)

                .fixedSize(horizontal: true, vertical: true)

                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                
            }
            

        }
    }
}

struct HomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreenView()
    }
}
