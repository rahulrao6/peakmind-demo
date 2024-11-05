//
//  MountainSelect.swift
//  peakmind-mvp
//
//  Created by James Wilson on 7/16/24.
//

import SwiftUI

struct GameHistory: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var closeAction: () -> Void

    var body: some View {
        ZStack {
            Color.init(hex: "40A3FF")
                            .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: {
                                            closeAction()
                                        }) {
                                            Image(systemName: "xmark.circle") // Button icon
                                                .font(.system(size: 50)) // Icon size
                                                .foregroundStyle(.black) // Icon color
                                                .opacity(0.4) // Icon opacity
                                                .frame(width: 60, height: 60) // Button size
                                                .background(Color.white) // Button background color
                                                .clipShape(Circle()) // Make button round
                                                .shadow(radius: 4) // Add slight shadow
                                                .padding([.leading, .bottom]) // Custom padding for leading and bottom
                                        }
                    Spacer()
                }
                ScrollView {
                    VStack {
                        
                    }
                }
            }.padding(.top)
        }
        .onAppear {
            viewModel.getAllGameData { gameDataList in
                for gameData in gameDataList {
                    print("Phase: \(gameData.phase), Level: \(gameData.level), Data: \(gameData.data), Timestamp: \(gameData.timestamp)")
                }
            }
        }
    }
}

