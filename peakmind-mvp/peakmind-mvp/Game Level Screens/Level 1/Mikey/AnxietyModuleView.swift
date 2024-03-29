//
//  AnxietyModuleView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/17/24.
//

import SwiftUI

struct AnxietyModuleView: View {
    @State private var selectedPage = 0
    let pageTexts = [
        "• Anxiety is your body's natural response to stress.\n• Historically, anxiety played a role in triggering life-saving reactions for our ancestors.\n• Anxiety can be temporary or become recurring over long periods of time.",
        "• Anxiety can cause a variety of effects on your mental health.\n• You deserve to live with your anxiety at a manageable level.\n• Each age experiences anxiety differently, with different brain chemicals formulating at different points within your life.",
        "• Believe it or not, anxiety is more normal than you think.\n• Over a third of all teenagers and young adults will experience struggles with anxiety.\n• Always remember that you’re not alone on your journey to getting through anxiety.",
        "• Your perception of anxiety is largely based on your cultural upbringing.\n• Where and how you grew up can influence you to be more or less prone to trying different coping strategies out.\n• You may feel a stigma around anxiety, but understand it's fading every day.",
        "• Anxiety comes in many different forms, from general anxiety, panic disorders, to social anxiety.\n• Anxiety disorders often occur after there’s been recurring anxiety for a long enough time.\n• At the end of the day, anxiety is best controlled through your breathing. Take it one step at a time."
    ]

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
            }
        }
    }
}

struct AnxietyModuleView_Previews: PreviewProvider {
    static var previews: some View {
        AnxietyModuleView()
    }
}
