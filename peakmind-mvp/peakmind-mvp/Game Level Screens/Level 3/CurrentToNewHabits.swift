//
//  CurrentToNewHabits.swift
//  peakmind-mvp
//
//  Created by James Wilson on 5/9/24.
//

import SwiftUI

struct CurrentToNewHabitsView: View {
    @State private var selectedPage = 0
    let pageTexts = [
        "Establishing and sticking to habits is a building block for reducing anxiety. Let’s build our first habit to add to your personalized plan.",
        "Let’s create a habit that you want to stick to over the next month. Write down the habit and exactly what it includes.",
    ]
    
    @State private var preHabit = ""
    @State private var newHabit = ""
    @State private var answerShown = false


    var body: some View {
        VStack {
            Text("Mt. Anxiety: Phase Three")
                .font(.system(size: 30, weight: .bold, design: .default))
                .foregroundColor(.white)
                .padding(.top, 40)
                .padding(.bottom, 40)
                
            ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
                TabView(selection: $selectedPage) {
                    ForEach(0..<pageTexts.count, id: \.self) { index in
                        VStack {
                            Text("Trigger Map")
                                .font(.system(size: 22, weight: .bold, design: .default))
                                .foregroundColor(.white)
                                .padding(.bottom, 5)
                            Text(pageTexts[index])
                                .font(.body)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.white)
                                .padding()
                        }
                        .frame(width: 320, height: 230)
                        .background(Color("Dark Blue").opacity(0.75))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .tag(index)
                        
                        
                    }
                    
                    
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
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
                .padding([.bottom], 20)
                .padding(.trailing, 50)
                
                

            }
            
            TextField(
                    "Old Habit",
                    text: $preHabit
                )
                .onSubmit {
                }
                .multilineTextAlignment(.center)
                .padding(30)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.white)
                                .stroke(Color.secondary, lineWidth: 3)
                        ).padding()
                .font(.system(size: 20))
                .padding([.leading, .trailing], 40)
            
            Image(systemName: "arrow.down")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(Color.white)

            TextField(
                    "New Habit",
                    text: $newHabit
                )
                .onSubmit {
                }
                .multilineTextAlignment(.center)
                .padding(30)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.white)
                                .stroke(Color.secondary, lineWidth: 3)
                        ).padding()
                .font(.system(size: 20))
                .padding(.bottom, 0)
                .padding([.leading, .trailing], 40)
            
            Button(action: {
                answerShown = true
            }) {
                Text("Continue")
                    .fontWeight(.light)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color(hex: "#080331"))
                    .cornerRadius(15)
            }
            .padding()
        }
        .background(Background())
        .overlay {
            Spacer()
            VStack(alignment: .center) {
                Text("Excellent job! Your habit can be found in your plan to hold yourself accountable.")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .animation(nil)
                    .padding(.top, 30)
                
                
                
                Button(action: {
                    // put action here
                }) {
                    Text("Continue")
                        .fontWeight(.light)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(Color(hex: "#080331"))
                        .cornerRadius(15)
                }
                .padding()
            }
            .background(Color(hex: "#0f075a"))
            .cornerRadius(15)
            .padding(.horizontal, 40)
            .padding([.top, .bottom], 300)
            .background {
                Color.clear
                    .background(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
            }
            .opacity(answerShown ? 1 : 0)
            .animation(.easeInOut)
            .edgesIgnoringSafeArea(.all)
        }
        
    }
}

#Preview {
    CurrentToNewHabitsView()
}
