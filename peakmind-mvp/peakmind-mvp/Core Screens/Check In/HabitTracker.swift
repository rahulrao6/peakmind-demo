//
//  HabitTracker.swift
//  peakmind-mvp
//
//  Created by Katharina Reimer on 3/31/24.
//

import Foundation
import SwiftUI

struct HabitTracker: View {
    @StateObject var viewModel = HabitTrackerViewModel()
    
    var body: some View {
        VStack {
            List {
                Text("Habit Tracker")
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .foregroundStyle(.white)
                    .frame(alignment: .center)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                
                ForEach(viewModel.dailyHabits, id: \.self) { habit in
                    LargeCheckInWidget(viewModel: viewModel,
                                       title: habit.name,
                                       height: 50,
                                       content: VStack{})
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    .swipeActions(edge: .leading) {
                        Button {
                            // TODO: remove item
                        } label: {
                            Text("Done")
                        }
                        .tint(.iceBlue)
                    }
                }.onDelete { indexSet in
                    viewModel.dailyHabits.remove(atOffsets: indexSet)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .scrollContentBackground(.hidden)
            
            HStack {
                // back button
                NavigationLink(destination: CheckIn()) {
                    VStack {
                        Text("BACK")
                            .bold()
                            .padding()
                            .foregroundColor(.white)
                    }
                    .frame(width: UIScreen.main.bounds.width/2-50, height: 50)
                    .background(.blue)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 2)
                    )
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .padding(.top, 20)
                }.simultaneousGesture(TapGesture().onEnded {
                    viewModel.submit()
                })
                
                // next button
                NavigationLink(destination: UserDashboard()) {
                    VStack {
                        Text("NEXT")
                            .bold()
                            .padding()
                            .foregroundColor(.white)
                    }
                    .frame(width: UIScreen.main.bounds.width/2-50, height: 50)
                    .background(.blue)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 2)
                    )
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .padding(.top, 20)
                }.simultaneousGesture(TapGesture().onEnded {
                    viewModel.submit()
                })
            }
            Spacer()
        }
        .background(Image("MainBG"))
    }
}



#Preview {
    HabitTracker()
}
