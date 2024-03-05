import SwiftUI

struct AvatarScreen: View {
    let avatarOptions = ["Asian", "Indian", "White"]
    let backgroundOptions = ["Pink Igloo", "Orange Igloo", "Blue Igloo", "Navy Igloo"]
    @State private var selectedAvatar = "Asian"
    @State private var selectedBackground = "Blue Igloo"
    @State private var showPicker = false
    @State private var username: String = "DefaultUsername"
    @State private var isEditingUsername = false
    @State private var isNavigatingToProfileView = false // State to manage navigation

    var body: some View {
        NavigationView {
            VStack {
                Text("Your Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)

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
                .padding(.bottom, 20)

                Button(action: {
                    showPicker.toggle()
                }) {
                    Text(showPicker ? "Confirm Choices" : "Change Avatar / Igloo")
                }
                .accentColor(.blue)
                .padding()

                if showPicker {
                    HStack {
                        Picker("Avatar", selection: $selectedAvatar) {
                            ForEach(avatarOptions, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .accentColor(.blue)

                        Picker("Background", selection: $selectedBackground) {
                            ForEach(backgroundOptions, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .accentColor(.blue)
                    }
                    .padding()
                }

                TextField("Enter your username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: 300)
                    .disabled(!isEditingUsername)

                Text(isEditingUsername ? "Confirm" : "Change Username")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .onTapGesture {
                        isEditingUsername.toggle()
                    }
                    .padding(.bottom, 15)

                HStack(spacing: 10) {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "chart.bar")
                            Text("Analytics")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(10)

                    Button(action: {
                        isNavigatingToProfileView = true
                    }) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
                }
                .frame(maxWidth: 300)

                NavigationLink(destination: ProfileView(), isActive: $isNavigatingToProfileView) {
                    EmptyView()
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationBarHidden(true)
        }
    }
}

// Preview
struct AvatarScreen_Previews: PreviewProvider {
    static var previews: some View {
        AvatarScreen()
    }
}
