//
//  PhysImpactsAnxietyView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/17/24.
//

import SwiftUI

// Screen 1 - Level 2 
struct PhysImpactsAnxietyView: View {
    @State private var selectedPage = 0
   let pageTexts = [
        "• When experiencing anxiety, it's very common to feel physical symptoms as a result of your emotions.\n• These physical responses are your body's way of coping with what your mind identifies as a “dangerous situation”.",
        "• Regular anxiety leads to muscles tensing up and experiencing pain, often causing irregular, panicked breathing.\n• More severe anxiety episodes can lead to shortness of breath, which can be mediated with long deep breaths.",
        "• Some other physical impacts include shaking or trembling during anxious periods as the body responds to stress.\n• Before breathing is under control, it's normal to start to sweat as a result of anxiety.",
        "• During more severe windows of anxiety, it's regular to feel symptoms of nausea and increased heart rate.\n• In situations like this, it's important to be in tune with your surroundings, drink water, and breathe deep.",
        "• For physical anxiety response…\n• Breathe in for 4 seconds, hold for 4 seconds, and exhale for 4 seconds to effectively control breathing.\n• Flexing and unflexing muscles and reminding yourself you’re safe helps to control your emotions."
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
                    .padding(.top, 20) // Reduced padding to position the title higher
                    .padding(.bottom, 40)

                ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
                    TabView(selection: $selectedPage) {
                        ForEach(0..<pageTexts.count, id: \.self) { index in
                            VStack {
                                Text("Physical Impacts of Anxiety")
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
                        NavigationLink(destination: PhysicalAnxietyQuiz().navigationBarBackButtonHidden(true).environmentObject(viewModel), isActive: $navigateToNext) {
                            EmptyView()
                        })
            }
        }
    }
}

struct PhysImpactsAnxietyView_Previews: PreviewProvider {
    static var previews: some View {
        PhysImpactsAnxietyView()
    }
}
