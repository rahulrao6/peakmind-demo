import SwiftUI
import FirebaseFirestore

struct StoreItem: Identifiable {
    let id = UUID()
    let name: String
    let price: Double
    let imageName: String
}

// Sample data for store items
let sampleItems: [StoreItem] = [
    StoreItem(name: "Blue Tent", price: 200, imageName: "BlueTent"),
    StoreItem(name: "Red Tent", price: 250, imageName: "RedTent"),
    StoreItem(name: "Green Tent", price: 300, imageName: "GreenTent"),
    StoreItem(name: "Yellow Tent", price: 350, imageName: "YellowTent"),
]
import SwiftUI
import FirebaseFirestore

struct StoreView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    @State private var isGridMode = false
    @State private var selectedStoreItem: StoreItem?
    @State private var showAlert = false
    @State private var showInventory = false

    var body: some View {
        VStack {
            Text("PeakMind Store")
                .font(.title)
            
            if isGridMode {
                StoreGridView(items: sampleItems, didSelectItem: { item in
                    selectedStoreItem = item
                    showAlert = true
                })
            } else {
                StoreListView(items: sampleItems, didSelectItem: { item in
                    selectedStoreItem = item
                    showAlert = true
                })
            }

            Spacer()

            HStack {
                Button(action: {
                    showInventory.toggle()
                }) {
                    Text("View Inventory")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()

                Spacer()

                CustomToggleButton(isOn: $isGridMode, label: "Grid Mode")
                    .padding()
            }
        }
        .sheet(isPresented: $showInventory) {
            InventoryView()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Confirm Purchase"),
                message: Text("Are you sure you want to buy \(selectedStoreItem?.name ?? "") for \(selectedStoreItem?.price ?? 0) VC?"),
                primaryButton: .default(Text("Yes")) {
                    if let item = selectedStoreItem {
                        buyItem(item: item)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func buyItem(item: StoreItem) {
        guard let currentUser = viewModel.currentUser else {
            print("User not logged in.")
            return
        }
        
        let userId = currentUser.id
        let userRef = Firestore.firestore().collection("users").document(userId)

        Firestore.firestore().document(userRef.path).getDocument { snapshot, error in
            if let error = error {
                showAlert(message: error.localizedDescription)
                return
            }
            
            guard var userData = snapshot?.data() else {
                showAlert(message: "Failed to fetch user data.")
                return
            }
            
            guard var balance = userData["currencyBalance"] as? Double else {
                showAlert(message: "Failed to retrieve currency balance.")
                return
            }
            
            if balance >= item.price {
                balance -= item.price
                var inventory = userData["inventory"] as? [String] ?? []
                inventory.append(item.name)
                
                userData["currencyBalance"] = balance
                userData["inventory"] = inventory
                
                Firestore.firestore().document(userRef.path).setData(userData) { error in
                    if let error = error {
                        showAlert(message: error.localizedDescription)
                        print("Error setting data: \(error)")
                    } else {
                        showAlert(message: "\(item.name) purchased successfully!")
                        print("\(item.name) purchased successfully!")
                    }
                }
            } else {
                showAlert(message: "You don't have enough VC to purchase \(item.name).")
            }
        }
    }

    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "Purchase Alert!", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
}

struct CustomToggleButton: View {
    @Binding var isOn: Bool
    let label: String

    var body: some View {
        Button(action: {
            isOn.toggle()
        }) {
            HStack {
                Text(label)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                Image(systemName: isOn ? "square.grid.2x2.fill" : "list.dash")
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.blue)
            .cornerRadius(8)
        }
    }
}
struct StoreListView: View {
    let items: [StoreItem]
    let didSelectItem: (StoreItem) -> Void
    
    var body: some View {
        List(items) { item in
            StoreItemRow(item: item, didSelectItem: didSelectItem)
        }
    }
}

struct StoreGridView: View {
    let items: [StoreItem]
    let didSelectItem: (StoreItem) -> Void
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(items) { item in
                    StoreItemGridCell(item: item, didSelectItem: didSelectItem)
                }
            }
            .padding()
        }
    }
}

struct StoreItemRow: View {
    let item: StoreItem
    let didSelectItem: (StoreItem) -> Void
    
    var body: some View {
        HStack {
            Image(item.imageName)
                .resizable()
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                Text("$\(item.price)")
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                didSelectItem(item)
            }) {
                Text("Buy")
                    .padding(8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

struct StoreItemGridCell: View {
    let item: StoreItem
    let didSelectItem: (StoreItem) -> Void
    
    var body: some View {
        VStack {
            Image(item.imageName)
                .resizable()
                .frame(width: 100, height: 100)
            
            Text(item.name)
                .font(.headline)
            
            Text("$\(item.price)")
                .foregroundColor(.gray)
            
            Button(action: {
                didSelectItem(item)
            }) {
                Text("Buy")
                    .padding(8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView()
    }
}
