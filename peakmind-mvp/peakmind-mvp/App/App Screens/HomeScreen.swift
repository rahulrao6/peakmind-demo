//
//  HomeScreen.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 2/19/24.
//

import SwiftUI

struct HomeScreenView: View {
    @State private var navigateToPlayScreen = false
    @State private var navigateToPlanScreen = false
    @State private var navigateToChatScreen = false
    @State private var navigateToJournalScreen = false
    @State private var navigateToProfileScreen = false

    var body: some View {
        NavigationView {
            ZStack {
                Image("HomeScreenBG")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    Image("PM3DLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .padding(.vertical, -0)

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
                        NavigationLink(destination: PlayScreen(), isActive: $navigateToPlayScreen) {
                            EmptyView()
                        }
                    )
                    .padding(.vertical, -70)

                    
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
                        NavigationLink(destination: PersonalizedPlanView(), isActive: $navigateToPlanScreen) {
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
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
}

struct HomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreenView()
    }
}

