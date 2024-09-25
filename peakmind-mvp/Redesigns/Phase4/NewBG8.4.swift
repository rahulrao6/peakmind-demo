//
//  NewBG8.4.swift
//  peakmind-mvp
//
//  Created by ZA on 9/24/24.
//

import SwiftUI

struct RoutineBuilderView4: View {
    @State private var navigateToNextView = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer() // Moves the content to the center vertically

            // Text message in the middle of the screen
            Text("Excellent job! This is a great quick routine to practice daily.")
                .font(.custom("SFProText-Bold", size: 24))
                .foregroundColor(Color("QuestionHeaderColor"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Spacer()

            // Next button
            Button(action: {
                navigateToNextView = true // Navigate to the next view
            }) {
                Text("Next")
                    .font(.custom("SFProText-Bold", size: 20))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color("ButtonGradient1"), Color("ButtonGradient2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(15)
                    .shadow(color: Color.white.opacity(1), radius: 10, x: 0, y: 0)
            }
            .padding(.bottom, 50)

            // NavigationLink to P2QuizPageView
            NavigationLink(destination: P4QuizPageView(), isActive: $navigateToNextView) {
                EmptyView()
            }
        }
        .background(
            Image("NewBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
        )
    }
}

// Preview
struct RoutineBuilderView4_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RoutineBuilderView4()
        }
    }
}




