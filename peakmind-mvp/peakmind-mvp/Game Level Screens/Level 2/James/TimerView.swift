//
//  TimerView.swift
//  test23
//
//  Created by James Wilson on 5/8/24.
//

import SwiftUI
 
let timer = Timer
    .publish(every: 1, on: .main, in: .common)
    .autoconnect()
 
struct TimerView: View {
     
    @State var counter: Int = 0
    var countTo: Int = 120
     
    var body: some View {
        
        VStack{
            
            ZStack{
                Image("MainBG")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                Text("Mt. Anxiety: Level Two")
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.top, -350)
                    .padding(.horizontal)
                Image("Sherpa")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .padding()
                    .offset(x: 25, y: 20)
                
                ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
                    VStack {
                        Text("Lets practice identifying emotions. Write down what you are currently feeling and what its like.")
                            .font(.system(size: 22, weight: .regular, design: .default))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 5)
                    }
                    .frame(width: 350, height: 150)
                    .background(Color("Dark Blue").opacity(0.75))
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .padding(.top, -270)
                }
            
                ZStack {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 250, height: 250)
                        .overlay(
                            Circle().stroke(Color.white, lineWidth: 35)
                                .opacity(0.4)
                    )
                     
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 250, height: 250)
                        .overlay(
                            Circle().trim(from:0, to: progress())
                                .rotation(.degrees(-90))
                                .stroke(
                                    style: StrokeStyle(
                                        lineWidth: 35,
                                        lineCap: .round,
                                        lineJoin:.round
                                    )
                                )
                                .foregroundColor(
                                    (completed() ? Color.green : Color.white)
                                ).animation(
                                    .linear(duration: 1)
                                )
                        )
                     
                    Clock(counter: counter, countTo: countTo)
                        .foregroundColor(.white)
                }.padding(.top, 80)
                
            }
        }.onReceive(timer) { time in
            if (self.counter < self.countTo) {
                self.counter += 1
            }
        }
    }
     
    func completed() -> Bool {
        return progress() == 1
    }
     
    func progress() -> CGFloat {
        return (CGFloat(counter) / CGFloat(countTo))
    }
}
 
struct Clock: View {
    var counter: Int
    var countTo: Int
     
    var body: some View {
        VStack {
            Text(counterToMinutes())
                .font(.system(size: 50))
                .fontWeight(.bold)
        }
    }
     
    func counterToMinutes() -> String {
        let currentTime = countTo - counter
        let seconds = currentTime % 60
        let minutes = Int(currentTime / 60)
         
        return "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
    }
}
 
struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
