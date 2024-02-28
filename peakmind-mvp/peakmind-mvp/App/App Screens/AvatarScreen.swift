//
//  AvatarScreen.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 2/27/24.
//

import SwiftUI

struct AvatarScreen: View {
    let avatarOptions = ["Asian", "Indian", "White"]
    @State private var selectedAvatar = "Asian"
    @State private var showPicker = false
    @State private var username: String = "DefaultUsername"
    @State private var isEditingUsername = false  // Track whether the username is being edited

    var body: some View {
        NavigationView {
            VStack {
                Text("Your Profile") // Change this to [NAME]'s Profile from Firebase first name
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)

                ZStack {
                       Image("AvatarBG") // Background image
                           .resizable()
                           .scaledToFill()
                           .frame(width: 300, height: 300)
                           .cornerRadius(15)
                           .clipped()

                       Image(selectedAvatar) // Foreground avatar image
                           .resizable()
                           .scaledToFit()
                           .frame(width: 300, height: 300)
                   }
                   .padding(.bottom, 20)
                Button(action: {
                    showPicker.toggle()
                }) {
                    Text(showPicker ? "Confirm" : "Change Avatar")
                }
                .padding()

                if showPicker {
                    // Save avatar info to Firebase
                    Picker("Select your avatar", selection: $selectedAvatar) {
                        ForEach(avatarOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                }

                // Display the username in a TextField
                // Update this from what's actually in Firebase
                TextField("Enter your username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: 300)
                    .disabled(!isEditingUsername)  // Disable editing unless the user is in edit mode

                // Text button for toggling username editing state
                // When confirm button is clicked, update username in Firebase
                Text(isEditingUsername ? "Confirm" : "Change Username")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .onTapGesture {
                        if isEditingUsername {
                            self.isEditingUsername = false
                        } else {
                            // Open the TextField for editing
                            self.isEditingUsername = true
                        }
                    }
                    .padding(.bottom, 15)
                Button("Analytics") {
                    // Action for Analytics button
                }
                .padding()
                .frame(maxWidth: 300)
                .background(Color.blue)
                .foregroundColor(Color.white)
                .cornerRadius(10)

                NavigationLink(destination: ProfileView()) {
                    Text("Settings")
                        .padding()
                        .frame(maxWidth: 300)
                        .background(Color.green)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarHidden(true)
    }
    
}

#Preview {
    AvatarScreen()
}







