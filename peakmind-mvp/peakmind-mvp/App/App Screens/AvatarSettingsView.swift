//
//  AvatarSettingsView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/6/24.
//

import SwiftUI
import FirebaseFirestore

struct AvatarSettingsView: View {
    let avatarOptions = ["Mikey", "Raj", "Trevor"]
    let backgroundOptions = ["Pink Igloo", "Orange Igloo", "Blue Igloo", "Navy Igloo"]
    @State private var selectedAvatar = "Mikey"
    @State private var selectedBackground = "Navy Igloo"
    @State private var showPicker = false
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        ZStack {
            Image("ChatBG2")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: -50) {
                Text("Select your avatar and igloo")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)


                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.black.opacity(0.8))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 100)


                    VStack(spacing: 20) {
                        ZStack {
                            Image(selectedBackground)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 300, height: 300)
                                .cornerRadius(15)
                                .clipped()

                            Image(selectedAvatar)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 280, height: 280)
                        }

                        if showPicker {
                            Button(action: {
                                Task {
                                    showPicker.toggle()
                                    do {
                                        try await updateBackgroundAvatar()
                                    } catch {
                                        print("Error updating background avatar: \(error)")
                                    }
                                }
                            }) {
                                Text("Confirm Choices")
                            }
                            .accentColor(.white)
                            .padding()
                        } else {
                            Button(action: {
                                showPicker.toggle()
                            }) {
                                Text("Change Avatar / Igloo")
                            }
                            .accentColor(.white)
                            .padding()
                        }
                        
//                        Button(action: {
//                            showPicker.toggle()
//                            Task {
//                                try await updateBackgroundAvatar()
//                            }
//                        }) {
//                            Text(showPicker ? "Confirm Choices" : "Change Avatar / Igloo")
//                        }
//                        .accentColor(.white)
//                        .padding()

                        if showPicker {
                            HStack { // Pickers side by side within an HStack
                                Picker("Avatar", selection: $selectedAvatar) {
                                    ForEach(avatarOptions, id: \.self) { option in
                                        Text(option).tag(option)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .accentColor(.white)

                                Picker("Background", selection: $selectedBackground) {
                                    ForEach(backgroundOptions, id: \.self) { option in
                                        Text(option).tag(option)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .accentColor(.white)
                            }
                            .padding() // Add padding around the HStack for visual spacing
                        }
                    }
                    .padding() // Padding for the contents inside the rounded rectangle
                }
            }
            .padding() // Padding for the entire VStack content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarHidden(true)
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
                "selectedAvatar": selectedAvatar,
                "selectedBackground": selectedBackground,
                "hasSetInitialAvatar": true
            ], merge: true)

            print("User fields updated successfully.")

            // Assuming fetchUser is also an asynchronous function
            await viewModel.fetchUser()
        } catch {
            print("Error updating user fields: \(error)")
        }
    }
}

// Preview
struct AvatarSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarSettingsView()
    }
}

