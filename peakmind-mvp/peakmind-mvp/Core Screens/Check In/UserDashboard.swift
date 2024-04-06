//
//  UserDashboard.swift
//  peakmind-mvp
//
//  Created by Katharina Reimer on 4/2/24.
//

import SwiftUI
import Charts

struct UserDashboard: View {
    @StateObject var viewModel = UserDashboardViewModel()
    @State var showCheckIn = false
    @State var showChat = false
    @State var showSettings = false
    
    var body: some View {
        ScrollView {
            Text("User Dashboard")
                .font(.system(size: 34, weight: .bold, design: .default))
                .foregroundStyle(.white)
                .frame(alignment: .center)
            
            
            LargeCheckInWidget(viewModel: viewModel,
                               title: "Weekly Mood",
                               height: 150.0,
                               content:
           VStack {
                Chart {
                    ForEach(viewModel.weeklyMood, id: \.self) { item in
                        AreaMark(
                            x: .value("Date", item.day),
                            y: .value("Score", item.score)
                        )
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.cyan, .white, .cyan]), startPoint: .top, endPoint: .bottom))
                    }
                }
                .foregroundStyle(.white)
            })
            
            HStack {
                SmallCheckInWidget(viewModel: viewModel,
                                   title: "What's most negatively affecting your mood is:", content:
                                    VStack {
                    // TODO: make variable
                    Text("Eating Habits")
                        .foregroundStyle(.iceBlue)
                        .bold()
                        .shadow(radius: 5)
                })
                
                SmallCheckInWidget(viewModel: viewModel,
                                   title: "What's most positively affecting your mood is:", content:
                                    VStack {
                    // TODO: make variable
                    Text("Drinking Habits")
                        .foregroundStyle(.iceBlue)
                        .bold()
                        .shadow(radius: 5)
                })
            }
            
            LargeCheckInWidget(viewModel: viewModel,
                               title: "Weekly Habit Completion",
                               height: 150.0,
                               content:
           VStack {
                Chart {
                    ForEach(viewModel.weeklyHabits, id: \.self) { item in
                        BarMark(
                            x: .value("Date", item.day),
                            y: .value("Score", item.score)
                        )
                        .foregroundStyle(.white)
                    }
                }
                .foregroundStyle(.white)
            })
            
            // sherpa chatboxes
            HStack {
                Image("Sherpa")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140)
                
                VStack(alignment: .trailing) {
                    Button {
                        showChat = true
                    } label: {
                        HStack {
                            Text("Click here for recommendations!")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                                .frame(height: 80)
                        }
                        .foregroundColor(.white)
                        .background(Color.darkBlue)
                        .cornerRadius(10)
                    }
                    Button {
                        showCheckIn = true
                    } label: {
                        HStack {
                            Text("Click here for your daily check-in!")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                                 .frame(height: 80)
                        }
                        .foregroundColor(.white)
                        .background(Color.darkBlue)
                        .cornerRadius(10)
                    }
                    
                    // settings icon
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50)
                            .padding(.horizontal)
                            .foregroundColor(.iceBlue)
                    }
                    
                }
            }
            .padding(.top, 20)
        } // end ScrollView
        .background(Image("MainBG"))
        .sheet(isPresented: $showCheckIn, content: {
            CheckIn()
        })
        .sheet(isPresented: $showChat, content: {
            CheckInChat()
        })
        .sheet(isPresented: $showSettings, content: {
            CheckInSettings()
        })
        
    }
}

#Preview {
    UserDashboard()
}
