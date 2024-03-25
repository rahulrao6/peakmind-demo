import SwiftUI
import FirebaseFirestore

struct InventoryView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    @State private var inventory: [String] = []
    @State private var isLoading = false

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                if inventory.isEmpty {
                    Text("No items in inventory")
                        .padding()
                } else {
                    List {
                        ForEach(inventory, id: \.self) { item in
                            Text(item)
                        }
                    }
                }
            }
        }
        .onAppear {
            loadInventory()
        }
    }

    private func loadInventory() {
        guard let currentUser = viewModel.currentUser else {
            print("User not logged in.")
            return
        }
        
        let userId = currentUser.id
        let userRef = Firestore.firestore().collection("users").document(userId)
        
        isLoading = true
        userRef.getDocument { snapshot, error in
            isLoading = false
            if let error = error {
                print("Error fetching inventory: \(error.localizedDescription)")
                return
            }
            
            guard let userData = snapshot?.data() else {
                print("No user data found")
                return
            }
            
            if let userInventory = userData["inventory"] as? [String] {
                inventory = userInventory
            } else {
                print("No inventory found")
            }
        }
    }
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView()
    }
}
