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
    @State private var isNavigatingToAvatarEdit = false
    @State private var isNavigatingToIglooEdit = false

    @State private var isIglooMenuPresented = false
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        if let user = viewModel.currentUser {
            //NavigationView {
            ZStack(alignment: .top) { // Align the ZStack content to the top
                    Image("MainBG")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all)

                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.black.opacity(0.5))
                        .padding(.horizontal, 20)
                        .frame(height: 575)
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
                                
                                /*
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
                                 */

                                HStack(spacing: 10) {
//                                    Button(action: {}) {
//                                        HStack {
//                                            Image(systemName: "chart.bar")
//                                            Text("Analytics")
//                                        }
//                                    }
//                                    .padding()
//                                    .frame(maxWidth: .infinity)
//                                    .background(Color.blue)
//                                    .foregroundColor(Color.white)
//                                    .cornerRadius(10)

                                    Button(action: {
                                        isNavigatingToProfileView = true
                                    }) {
                                        HStack {
                                            Image(systemName: "gear")
                                            Text("General")
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
                                    
                                    HStack {
                                        
                                        Button(action: {
                                            isNavigatingToAvatarEdit = true
                                        }) {
                                            HStack {
                                                Image(systemName: "person.crop.circle")
                                            }
                                        }
                                        .padding()
                                        .frame(maxWidth: 60)
                                        .background(Color("Medium Blue"))
                                        .foregroundColor(Color.white)
                                        .cornerRadius(10)

                                       /// .background(
////                                            NavigationLink(destination: AvatarMenuSheet().navigationBarBackButtonHidden(true), isActive: $isNavigatingToAvatarEdit) {
////                                                    EmptyView()
////                                                }
//                                        )
                                        
                                        Button(action: {
                                            isNavigatingToIglooEdit = true
                                        }) {
                                            HStack {
                                                Image(systemName: "house.fill")
                                            }
                                        }
                                        .padding()
                                        .frame(maxWidth: 60)
                                        .background(Color("Ice Blue"))
                                        .foregroundColor(Color.white)
                                        .cornerRadius(10)
//                                        .background(
////                                            NavigationLink(destination: IglooMenuView().navigationBarBackButtonHidden(true), isActive: $isNavigatingToIglooEdit) {
////                                                    EmptyView()
////                                                }
//                                        )
                                        
                                    }
                                    

                                    
                                        .sheet(isPresented: $isNavigatingToAvatarEdit) {
                                            AvatarMenuSheet()
                                        }
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
                //.navigationBarHidden(true)
            //}
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
