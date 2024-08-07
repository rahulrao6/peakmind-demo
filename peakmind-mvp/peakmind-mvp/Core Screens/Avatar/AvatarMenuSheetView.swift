//
//  AvatarMenuView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/15/24.
//

import SwiftUI
import FirebaseFirestore

struct AvatarMenuSheet: View {
    let avatarIcons = ["RajIcon", "MikeyIcon", "TrevorIcon", "Girl1Icon", "Girl2Icon", "Girl3Icon"]
    let avatarImages = ["Raj", "Mikey", "Trevor", "Girl1", "Girl2", "Girl3"]
    @State private var selectedAvatarIndex = 0
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToIglooView = false
    @EnvironmentObject var viewModel: AuthViewModel
    @State var isUpdateSuccessful = false // Control the presentation of the sheet
    



    var body: some View {
        NavigationView {
            ZStack {
                Image("MainBG")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Select Your Avatar")
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
                            // Display avatar icons in rows of 3
                            ForEach(0..<avatarIcons.count/3 + (avatarIcons.count % 3 > 0 ? 1 : 0), id: \.self) { rowIndex in
                                HStack {
                                    ForEach(0..<3) { colIndex in
                                        let index = rowIndex * 3 + colIndex
                                        if index < avatarIcons.count {
                                            Button(action: {
                                                selectedAvatarIndex = index
                                            }) {
                                                Image(avatarIcons[index])
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 95, height: 85)
                                                    .clipShape(Circle())
                                                    .overlay(
                                                        Circle().stroke(Color.white, lineWidth: selectedAvatarIndex == index ? 3 : 0)
                                                    )
                                            }
                                        }
                                    }
                                }
                                .padding(.top, rowIndex == 0 ? 20 : 0)
                            }
                            
                            Image(avatarImages[selectedAvatarIndex])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .clipShape(Circle())
                                .padding(.top, 20)
                                .padding(.bottom, 30)
                            
                            HStack(spacing: 12) {
                                Button("Cancel") {
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                                .padding()
                                .frame(maxWidth: 140)
                                .foregroundColor(.white)
                                .background(Color("Pink"))
                                .cornerRadius(10)
                                
                                Button("Confirm") {
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
            .navigationBarHidden(true)

        }
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
                "selectedAvatar": avatarImages[selectedAvatarIndex],
            ], merge: true)

            print(avatarImages[selectedAvatarIndex])
            print("User fields updated successfully. Avatar!!!!!!!")
            isUpdateSuccessful = true // Set the update flag to true

            // Assuming fetchUser is also an asynchronous function
            await viewModel.fetchUser()
            
            navigateToIglooView = true // Set the state to trigger navigation

        } catch {
            print("Error updating user fields: \(error)")
        }
    }

    
}

// Preview
struct AvatarMenuView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarMenuView()
    }
}
