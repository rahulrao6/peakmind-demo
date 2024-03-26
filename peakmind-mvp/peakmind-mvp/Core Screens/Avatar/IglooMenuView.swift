//
//  IglooMenuView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/15/24.
//

import SwiftUI
import FirebaseFirestore

struct IglooMenuView: View {
    let iglooIcons = ["BlueIcon", "PinkIcon", "OrangeIcon"]
    let iglooImages = ["Blue Igloo", "Pink Igloo", "Orange Igloo"]
    @State private var selectedIglooIndex = 0
    @State private var isIglooSelection = true
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isUpdateSuccessful = false // Control the presentation of the sheet



    var body: some View {
        NavigationView{
            ZStack {
                Image("MainBG")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Select Your Igloo")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    ZStack {
                        Color.black.opacity(0.6)
                            .cornerRadius(20)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 40)
                        
                        VStack(spacing: 10) {
                            HStack {
                                ForEach(0..<iglooIcons.count, id: \.self) { index in
                                    Button(action: {
                                        selectedIglooIndex = index
                                    }) {
                                        Image(iglooIcons[index])
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 95, height: 85)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle().stroke(Color.white, lineWidth: selectedIglooIndex == index ? 3 : 0)
                                            )
                                    }
                                }
                            }
                            .padding(.top, 20)
                            
                            Image(iglooImages[selectedIglooIndex])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                                .padding(.top, 20)
                                .padding(.bottom, 30)
                            
                            HStack(spacing: 12) {
                                Button("Back") {
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                                .padding()
                                .frame(maxWidth: 140)
                                .foregroundColor(.white)
                                .background(Color("Pink"))
                                .cornerRadius(10)
                                
                                Button("Confirm") {
                                    // Confirm action: FIREBASE CONNECTION PLZ and make it navigate to the avatar screen after selected
                                    Task {
                                        try await updateBackgroundAvatar()
                                    }
                                }
                                .padding()
                                .frame(maxWidth: 140)
                                .foregroundColor(.white)
                                .background(Color("Medium Blue"))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal, 10)
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onReceive(viewModel.$currentUser) { currentUser in
            if isUpdateSuccessful {
                self.presentationMode.wrappedValue.dismiss() // Dismiss the sheet after successful update
            }
        }
    }
    func updateBackgroundAvatar() async throws {
        guard let user = viewModel.currentUser else {
            print("No authenticated user found.")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.id)

        do {
            try await userRef.setData([
                "selectedBackground": iglooIcons[selectedIglooIndex],
                "hasSetInitialAvatar": true
            ], merge: true)

            print("User fields updated successfully.")
            isUpdateSuccessful = true // Set the update flag to true


            // Assuming fetchUser is also an asynchronous function
            await viewModel.fetchUser()
        } catch {
            print("Error updating user fields: \(error)")
        }
    }

}

// Preview
struct IglooMenuView_Previews: PreviewProvider {
    static var previews: some View {
        IglooMenuView()
    }
}
