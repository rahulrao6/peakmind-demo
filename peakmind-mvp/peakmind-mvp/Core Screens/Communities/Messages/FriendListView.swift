import SwiftUI
import FirebaseFirestore

struct FriendListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var users: [UserData] = []
    private let db = Firestore.firestore()

    var body: some View {
        VStack {
            List(users) { user in
                if user.id != authViewModel.currentUser?.id {  // Check to avoid showing the current user
                    HStack {
                        Text(user.username)
                        Spacer()
                        if !(authViewModel.currentUser?.friends.contains(user.id ?? "") ?? false) {
                            Button(action: {
                                authViewModel.addFriend(friendId: user.id ?? "")
                            }) {
                                Text("Follow")
                                    .foregroundColor(.blue)
                            }
                        } else {
                            Text("Following")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchAllUsers()
        }
        .navigationBarTitle("Users", displayMode: .inline)
    }
    
    func fetchAllUsers() {
        print("Starting to fetch all users")
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("No user documents found")
                return
            }
            let fetchedUsers = documents.compactMap { document -> UserData? in
                print("Document data: \(document.data())")  // Debugging statement
                var user: UserData?
                do {
                    user = try document.data(as: UserData.self)
                    user?.id = document.documentID  // Ensure the ID is correctly assigned
                } catch {
                    print("Error decoding user data: \(error.localizedDescription)")
                }
                return user
            }
            print("Fetched users before filtering: \(fetchedUsers)")  // Debugging statement
            self.users = fetchedUsers.filter { $0.id != authViewModel.currentUser?.id }  // Exclude the current user
            print("Fetched users after filtering: \(self.users)")  // Debugging statement
        }
    }
}

struct FriendListView_Previews: PreviewProvider {
    static var previews: some View {
        FriendListView()
            .environmentObject(AuthViewModel())
    }
}
