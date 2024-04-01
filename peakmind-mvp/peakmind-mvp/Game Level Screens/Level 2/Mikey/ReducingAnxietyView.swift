//
//  ReducingAnxietyView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/23/24.
//

import SwiftUI

// Screen eight - level 2

struct ReducingAnxietyView: View {
    @State private var selectedPage = 0
    let pageTexts = [
         "• There are many ways to reduce anxiety from meditation to exercise.\n• The first step is figuring out where your main sources of anxiety come from.",
         "• During anxious episodes, focus on box breathing - 4 seconds in, 4 seconds hold, 4 seconds out.\n• Starting a 3 minute meditation can be great. It’s short, easy to start, and gives you one time a day to feel “calm”.",
         "• Relaxing your muscles is another way to reduce anxiety.\n• Progressive muscle relaxation is flexing different muscles and un-flexing them.\n• This focuses your anxiety on muscle movement. Give it a try!",
         "• Another way to reduce anxiety is through journaling and affirmations.\n• Journaling at your desired pace allows you to fully realize everything happening with you.",
         "• Affirmations are repeating positive statements to yourself regularly. This keeps you in life’s positives.\n• Lastly, food, water, and sleep are the basics. Without those, it's hard to control any anxiety."
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
                Text("Mt. Anxiety: Level Two")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .padding(.bottom, 40)

                ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
                    TabView(selection: $selectedPage) {
                        ForEach(0..<pageTexts.count, id: \.self) { index in
                            VStack {
                                Text("Reducing Anxiety")
                                    .font(.system(size: 22, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                                    .padding(.bottom, 5)

                                Text(pageTexts[index])
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.white)
                                    .padding()
                            }
                            .frame(width: 300, height: 330)
                            .background(Color("Dark Blue").opacity(0.75))
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(width: 320, height: 350)

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

struct ReducingAnxietyView_Previews: PreviewProvider {
    static var previews: some View {
        ReducingAnxietyView()
    }
}
