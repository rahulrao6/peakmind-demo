//
//  Level1Eduacation.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/23/24.
//

import SwiftUI

struct Level1Eduacation: View {
    @State private var selectedPage = 0
    let pageTexts = [
         "• Anxiety is your body's natural response to stress.\n\n• Historically, anxiety played a role in triggering life-saving reactions for our ancestors\n\n• Anxiety can be temporary or become recurring over long periods of time.",
         "• Anxiety can cause a variety of effects on your mental health.\n\n• You deserve to live with your anxiety at a manageable level.\n\n• Each age experiences anxiety differently, with different brain chemicals formulating at different points within your life.",
         "• Believe it or not, anxiety is more normal than you think.\n\n• Over a third of all teenagers and young adults will experience struggles with anxiety.\n\n• Always remember that you’re not alone on your journey to getting through anxiety.",
         "• Your perception of anxiety is largely based on your cultural upbringing.\n\n• Where and how you grew up can influence you to be more or less prone to trying different coping strategies out.\n\n• You may feel a stigma around anxiety, but understand its fading every day.",
         "• Anxiety comes in many different forms, from general anxiety, panic disorders, to social anxiety.\n\n• Anxiety disorders often occur after there’s been recurring anxiety for a long enough time.\n\n• At the end of the day, anxiety is best controlled through your breathing. Take it one step at a time."
     ]
    @State var navigateToNext = false
    @State var firstCycleCompleted = false
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        ZStack {
            Image("MainBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(width: 140)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
                .offset(x: 25, y: 20)
            VStack(spacing: 0) {
                Text("Mt. Anxiety: Level One")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .padding(.bottom, 40)

                ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
                    TabView(selection: $selectedPage) {
                        ForEach(0..<pageTexts.count, id: \.self) { index in
                            VStack {
                                Text("Understanding Anxiety")
                                    .font(.system(size: 22, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                                    .padding(.bottom, 5)

                                Text(pageTexts[index])
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.white)
                                    .padding()
                            }
                            .frame(width: 340, height: 330) // Increased width for wider text background
                            .background(Color("Dark Blue").opacity(0.75))
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(width: 360, height: 350) // Increased width for wider tab view

                    Button(action: {
                        withAnimation {
                            selectedPage = (selectedPage + 1) % pageTexts.count
                            if selectedPage == 0 && firstCycleCompleted {
                                navigateToNext.toggle()
                            } else if selectedPage == pageTexts.count - 1 {
                                firstCycleCompleted = true
                            }
                        }
                    }) {
                        Image(systemName: "arrow.right")
                            .resizable()
                            .frame(width: 25, height: 20)
                            .foregroundColor(Color("Ice Blue"))
                            .padding(10)
                    }
                    .padding([.bottom, .trailing], 10)
                }
                Spacer()
                    .background(
                        NavigationLink(destination: SMARTGoalSettingView().navigationBarBackButtonHidden(true).environmentObject(viewModel), isActive: $navigateToNext) {
                            EmptyView()
                        })
            }
        }
    }
}

struct Level1Eduacation_Previews: PreviewProvider {
    static var previews: some View {
        Level1Eduacation().environmentObject(AuthViewModel())
    }
}
