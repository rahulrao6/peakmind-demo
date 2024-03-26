
//
//  NightfallFlavorView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/17/24.
//

import SwiftUI
import FirebaseFirestore

struct Level1Complete: View {
    @EnvironmentObject var viewModel: AuthViewModel

    let titleText = "Mt. Anxiety: Level One"
    let narrationText = "Congratulations! You have completed the first level!"
    @State private var animatedText = ""
    @State var navigateToNext = false


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
            VStack(spacing: 20) {
                Text(titleText)
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.top, 50)
                    .padding(.horizontal)
                
                VStack(alignment: .center) {
                    Text(animatedText)
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .onAppear {
                            animateText()
                        }
                }
                .background(Color("Dark Blue"))
                .cornerRadius(15)
                .padding(.horizontal, 40) // Increase horizontal padding to prevent background from extending to the sides

                Spacer()
                
                
            }
        }
        .background(
            NavigationLink(destination: HomeScreenView().navigationBarBackButtonHidden(true).environmentObject(viewModel), isActive: $navigateToNext) {
            EmptyView()
        })
        .onAppear() {
            Task {
                try await updateLevel1()
            }
        }
        .onTapGesture {
            navigateToNext = true
        }
    }
    
    private func animateText() {
        var charIndex = 0.0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            let roundedIndex = Int(charIndex)
            if roundedIndex < narrationText.count {
                let index = narrationText.index(narrationText.startIndex, offsetBy: roundedIndex)
                animatedText.append(narrationText[index])
            }
            charIndex += 1
            if roundedIndex >= narrationText.count {
                timer.invalidate()
            }
        }
        timer.fire()
    }
    
    func updateLevel1() async throws {
        guard let user = viewModel.currentUser else {
            print("No authenticated user found.")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.id)

        do {
            try await userRef.setData([
                "LevelOneCompleted": true,
            ], merge: true)

            print("User fields updated successfully.")

            // Assuming fetchUser is also an asynchronous function
            await viewModel.fetchUser()
        } catch {
            print("Error updating user fields: \(error)")
        }
    }
}

struct Level1Complete_Previews: PreviewProvider {
    static var previews: some View {
        Level1Complete().environmentObject(AuthViewModel())
    }
}
