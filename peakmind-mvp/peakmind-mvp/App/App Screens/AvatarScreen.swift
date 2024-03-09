import SwiftUI
import FirebaseFirestore

struct AvatarScreen: View {
    let avatarOptions = ["Mikey", "Raj", "Trevor"]
    let backgroundOptions = ["Pink Igloo", "Orange Igloo", "Blue Igloo", "Navy Igloo"]
    @State private var selectedAvatar = "Mikey"
    @State private var selectedBackground = "Navy Igloo"
    @State private var showPicker = false
    @State private var username: String = ""
    @State private var newUsername = ""
    @State private var isEditingUsername = false
    @State private var isNavigatingToProfileView = false


    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        if let user = viewModel.currentUser {
            NavigationView {
                ZStack {
                    Image("ChatBG2")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all)

                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.black.opacity(0.5))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20) 
                        .overlay(
                            VStack {
                                Text("Your Profile")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.bottom, 20)

                                ZStack {
                                    if showPicker {
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
                                    } else {
                                        Image(user.selectedBackground)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 300, height: 300)
                                            .cornerRadius(15)
                                            .clipped()

                                        Image(user.selectedAvatar)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 280, height: 280)
                                    }
                                }
                                .padding(.bottom, 20)

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

                                if showPicker {
                                    HStack {
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
                                    .padding()
                                }
                                
                                if (!isEditingUsername) {
                                    Text(user.username)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                } else {
                                    TextField("Change your username", text: $username)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(maxWidth: 300)
                                }

//                                TextField("Change your username", text: $username)
//                                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                                    .frame(maxWidth: 300)
//                                    .disabled(!isEditingUsername)
                                

                                if (!isEditingUsername) {
                                    Button(action: {
                                        isEditingUsername.toggle()
                                    }) {
                                        Text("Change your username")
                                    }
                                } else {
                                    Button(action: {
                                        Task {
                                            try await updateUsername()
                                        }
                                        isEditingUsername.toggle()
                                    }) {
                                        Text("Confirm")
                                    }
                                }

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
                                    .sheet(isPresented: $isNavigatingToProfileView) { // Present ProfileView as a sheet
                                        ProfileView()
                                    }
                                }
                                .frame(maxWidth: 300)
                            }
                            .padding()
                        )

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .navigationBarHidden(true)
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
                "selectedAvatar": selectedAvatar,
                "selectedBackground": selectedBackground
            ], merge: true)

            print("User fields updated successfully.")

            // Assuming fetchUser is also an asynchronous function
            await viewModel.fetchUser()
        } catch {
            print("Error updating user fields: \(error)")
        }
    }
    
    func updateUsername() async throws {
        guard let user = viewModel.currentUser else {
            print("No authenticated user found.")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.id)

        do {
            try await userRef.setData([
                "username": username,
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
struct AvatarScreen_Previews: PreviewProvider {
    static var previews: some View {
        AvatarScreen().environmentObject(AuthViewModel())
    }
}
