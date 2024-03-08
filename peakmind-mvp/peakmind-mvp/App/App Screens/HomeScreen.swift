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
    @State private var navigateToJournal = false


    var body: some View {
        NavigationView {
            ZStack {
                Image("GameScreenTemp")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                ZStack {
                    Rectangle()
                        .fill(Color.white.opacity(1))
                        .frame(width: 330, height: 120)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                    Text("What struggles are you facing today?")
                        .font(.title)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(width: 300)
                }
                .offset(y: 75)
                
                Button(action: {
                    navigateToPlayScreen = true
                }) {
                    Image("play")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 130)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                }
                .offset(y: 240)
                .offset(x: -80)
                .background(
                    NavigationLink(destination: PlayScreen(), isActive: $navigateToPlayScreen) {
                        EmptyView()
                    }
                )
                Button(action: {
                    navigateToPlanScreen = true
                }) {
                    Image("plan")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 130)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                }
                .offset(y: 240)
                .offset(x: 80)
                .background(
                    NavigationLink(destination: PersonalizedPlanView(), isActive: $navigateToPlanScreen) {
                        EmptyView()
                    }
                )
                
                Image("Sherpa")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .offset(y: -70)
                
                ZStack {
                    Rectangle()
                        .fill(Color.yellow.opacity(0.7))
                        .frame(width: 150, height: 60)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                    Text("Current Peak: Anxiety")
                        .font(.body)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(width: 125)
                }
                .offset(y: -185)
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

