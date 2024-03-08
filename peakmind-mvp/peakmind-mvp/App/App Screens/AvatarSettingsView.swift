//
//  AvatarSettingsView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/6/24.
//

import SwiftUI

struct AvatarSettingsView: View {
    let avatarOptions = ["Asian", "Indian", "White"]
    let backgroundOptions = ["Pink Igloo", "Orange Igloo", "Blue Igloo", "Navy Igloo"]
    @State private var selectedAvatar = "White"
    @State private var selectedBackground = "Navy Igloo"
    @State private var showPicker = false

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

                        Button(action: {
                            showPicker.toggle()
                        }) {
                            Text(showPicker ? "Confirm Choices" : "Change Avatar / Igloo")
                        }
                        .accentColor(.white)
                        .padding()

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
}

// Preview
struct AvatarSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarSettingsView()
    }
}

