//
//  CheckIn.swift
//  peakmind-mvp
//
//  Created by Katharina Reimer on 3/30/24.
//

import SwiftUI

struct CheckIn: View {
    @StateObject var viewModel = CheckInViewModel()
    
    var body: some View {
        ScrollView {
           
            // widgets
            VStack {
                // mood tracker
                LargeCheckInWidget(viewModel: viewModel,
                    title: "What moods were you in today?",
                    height: 250.0,
                    content:
                    VStack {
                    List(viewModel.moodOptions, id: \.self, selection: $viewModel.moodSelected) {
                        // TODO: enable multi-selection
                        Text($0.name)
                    }
                    .scrollContentBackground(.hidden)
                    .padding(.top, -10)
                    
                    
                    Text("Mood Score: \(viewModel.moodScore())")
                        .foregroundStyle(.white)
                        .bold()
                        .padding(.top, 10)
                }
                )
                .padding(.top, 70)
                // end mood tracker
                
                // first row
                HStack {
                    // meal count tracker
                    SmallCheckInWidget(viewModel: viewModel,
                                       title: "How many meals did you have today?",
                                       content:
                                        VStack {
                        Slider(value: $viewModel.mealCount,
                               in: 1...10,
                               step: 1.0)
                        .tint(.iceBlue)
                        .background(.iceBlue)
                        .cornerRadius(15)
                        Text("\(Int(viewModel.mealCount))")
                            .bold()
                            .foregroundColor(.white)
                            .shadow(radius: 3)
                    }
                                       
                    ).padding(.top, 70)
                    
                    // wash face tracker
                    SmallCheckInWidget(viewModel: viewModel,
                                       title: "Have you washed you face today?",
                                       content:
                                        HStack {
                        VStack(alignment: .center) {
                            Toggle("no",
                                   isOn: $viewModel.washFace)
                            .foregroundColor(.white)
                            .tint(.iceBlue)
                        }
                        .padding(.horizontal, 2)
                        
                        Text("yes").padding(.horizontal, 10)
                            .foregroundColor(.white)
                    }
                                       
                    ).padding(.top, 70)
                }
                // end first row
                
                // second row
                HStack {
                    // water tracker
                    SmallCheckInWidget(viewModel: viewModel,
                                       title: "How much water did you have today?",
                                       content:
                                        VStack {
                        Slider(value: $viewModel.glassesWater,
                               in: 1...30,
                               step: 1.0)
                        .tint(.iceBlue)
                        .background(.iceBlue)
                        .cornerRadius(15)
                        Text("\(Int(viewModel.glassesWater)) (8 oz) glasses")
                            .bold()
                            .foregroundColor(.white)
                            .shadow(radius: 3)
                    }
                                       
                    ).padding(.top, 70)
                    // stress level tracker
                    SmallCheckInWidget(viewModel: viewModel,
                                       title: "How was your stress today?",
                                       content:
                                        VStack {
                        Slider(value: $viewModel.stressLevel,
                               in: 1...5,
                               step: 1.0)
                        .tint(.iceBlue)
                        .background(.iceBlue)
                        .cornerRadius(15)
                        if (viewModel.stressLevel == 1) {
                            Text("HORRIBLE!")
                                .bold()
                                .foregroundColor(.white)
                                .shadow(radius: 3)
                        } else if (viewModel.stressLevel == 2) {
                            Text("ruining my day")
                                .bold()
                                .foregroundColor(.white)
                                .shadow(radius: 3)
                        } else if (viewModel.stressLevel == 3) {
                            Text("manageable")
                                .bold()
                                .foregroundColor(.white)
                                .shadow(radius: 3)
                        } else if (viewModel.stressLevel == 4) {
                            Text("low impact")
                                .bold()
                                .foregroundColor(.white)
                                .shadow(radius: 3)
                        } else if (viewModel.stressLevel == 5) {
                            Text("none at all")
                                .bold()
                                .foregroundColor(.white)
                                .shadow(radius: 3)
                        }
                    }
                    ).padding(.top, 70)
                    
                }
                // end second row
                
                // sleep tracker
                LargeCheckInWidget(viewModel: viewModel,
                                   title: "How much sleep did you get last night?",
                                   height: 150,
                                   content:
                                    VStack {
                    Slider(value: $viewModel.sleepDuration,
                           in: 0...16,
                           step: 0.25)
                    .tint(.iceBlue)
                    .background(.iceBlue)
                    .cornerRadius(15)
                    Text(String(format: "%.2f", viewModel.sleepDuration)+" hours")
                        .bold()
                        .foregroundColor(.white)
                        .shadow(radius: 3)
                }
                                   
                )
                .padding(.top, 70)
                
                // reflective question
                LargeCheckInWidget(viewModel: viewModel,
                                   title: "What is a goal you want to work on?",
                                   height: 200,
                                   content:
                                    TextField("Enter your response here", text: $viewModel.goalResponse)
                    .frame(width: UIScreen.main.bounds.width-40, height:120)
                    .background(.white)
                    .cornerRadius(10)
                                   
                )
                .padding(.top, 70)
                
                // next button
                NavigationLink(destination: HabitTracker()) {
                    VStack {
                        Text("NEXT")
                            .bold()
                            .padding()
                            .foregroundColor(.white)
                    }
                    .frame(width: UIScreen.main.bounds.width/2-10, height: 50)
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
        }
        .background(Image("MainBG"))
    }
}


struct LargeCheckInWidget<Content: View, ViewModel: ObservableObject>: View {
    var viewModel: ViewModel
    let title: String
    let height: CGFloat
    let content: Content
    
    var body: some View {
        VStack {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 10)
                .padding(.horizontal, 10)
            
            content.padding(.horizontal).padding(.bottom)
            
        }
        .frame(width: UIScreen.main.bounds.width-20, height: height)
        .background( LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .top, endPoint: .center) )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 2)
        )
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct SmallCheckInWidget<Content: View, ViewModel: ObservableObject>: View {
    var viewModel: ViewModel
    var title: String
    let content: Content
    
    var body: some View {
        VStack {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 10)
                .padding(.horizontal, 10)
            
            content.padding(.horizontal).padding(.bottom)
            
        }
        
        .frame(width: UIScreen.main.bounds.width/2-10, height: 130)
        .background( LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .top, endPoint: .center) )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 2)
        )
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

#Preview {
    CheckIn()
}
