import SwiftUI
import FirebaseFirestore

struct AvatarScreen: View {
    let avatarOptions = ["Mikey", "Raj", "Trevor", "Girl1", "Girl2", "Girl3"]
    let backgroundOptions = ["Pink Igloo", "Orange Igloo", "Blue Igloo", "Navy Igloo"]
    @State private var selectedAvatar = "Mikey"
    @State private var selectedBackground = "Navy Igloo"
    @State private var showPicker = false
    @State private var username: String = ""
    @State private var newUsername = ""
    @State private var isEditingUsername = false
    @State private var isNavigatingToProfileView = false
    @State private var isNavigatingToAvatarEdit = false
    @State private var isNavigatingToIglooEdit = false
    @EnvironmentObject var EventKitManager1: EventKitManager
    @EnvironmentObject var healthKitManager: HealthKitManager

    @State private var isIglooMenuPresented = false
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        if let user = viewModel.currentUser {
            ZStack(alignment: .center) { // Align the ZStack content to the top
                Image("MainBG")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)

                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.black.opacity(0.5))
                    .padding(.horizontal, 20)
                    .frame(height: 650)
                    .overlay(
                        VStack {
                            Text("Your Profile")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.bottom, 20)

                            ZStack {
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
                            .padding(.bottom, 20)

                            HStack(spacing: 10) {
                                Button(action: {
                                    isNavigatingToProfileView = true
                                }) {
                                    VStack {
                                        Image(systemName: "gear")
                                            .frame(width: 24, height: 24) // Set to same size as other icons
                                        Text("General")
                                            .font(.system(size: 12)) // Adjust font size
                                    }
                                }
                                .padding()
                                .frame(width: 80, height: 60)
                                .background(Color.gray)
                                .foregroundColor(Color.white)
                                .cornerRadius(10)
                                .sheet(isPresented: $isNavigatingToProfileView) { // Present ProfileView as a sheet
                                    ProfileView().environmentObject(EventKitManager1).environmentObject(healthKitManager)
                                }

                                Button(action: {
                                    isNavigatingToAvatarEdit = true
                                }) {
                                    VStack {
                                        Image(systemName: "person.crop.circle")
                                            .frame(width: 24, height: 24) // Set to same size as other icons
                                        Text("Avatar")
                                            .font(.system(size: 12)) // Adjust font size
                                    }
                                }
                                .padding()
                                .frame(width: 80, height: 60)
                                .background(Color("Medium Blue"))
                                .foregroundColor(Color.white)
                                .cornerRadius(10)
                                .sheet(isPresented: $isNavigatingToAvatarEdit) {
                                    AvatarMenuSheet()
                                }

                                Button(action: {
                                    isNavigatingToIglooEdit = true
                                }) {
                                    VStack {
                                        Image("iglooIcon") // Use your igloo icon image name
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24, height: 24) // Set to same size as system image
                                        Text("Igloo")
                                            .font(.system(size: 12)) // Adjust font size
                                    }
                                }
                                .padding()
                                .frame(width: 80, height: 60)
                                .background(Color("Ice Blue"))
                                .foregroundColor(Color.white)
                                .cornerRadius(10)
                                .sheet(isPresented: $isNavigatingToIglooEdit) {
                                    IglooMenuSheet()
                                }
                            }
                            .frame(maxWidth: 300)
                        }
                        .padding()
                    )
                    .padding(.top, 20) // Adjust top padding to move the box closer to the top
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
