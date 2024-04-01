import SwiftUI
import FirebaseFirestore

enum ItemType: String, CaseIterable {
    case pen, boots, sword

    var description: String {
        switch self {
        case .pen: return "This pen is mightier than the sword. Use it to script your victory over anxiety."
        case .boots: return "These sturdy boots will carry you safely through rocky terrains."
        case .sword: return "Wield this sword to cut through the darkness and conquer your fears."
        }
    }
}

struct Module3View: View {
    @State var selectedItem: ItemType
    @State private var showDetail = false
    @State var navigateToNext = false
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        ZStack {
            Image("MainBG")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("Mt. Anxiety Level One")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 30)
                    .padding(.bottom, 40)


                CircleSelectionView(selectedItem: $selectedItem, showDetail: $showDetail)

                Spacer()
                AvatarAndSherpaView()
            }
        }
        NavigationLink(destination: AnxietyQuiz().navigationBarBackButtonHidden(true).environmentObject(viewModel), isActive: $navigateToNext) {
            EmptyView()
        }
        .sheet(isPresented: $showDetail) {
            // Ensure `selectedItem` is unwrapped before passing it to `ItemDetailView`
            ItemDetailView(item: self.selectedItem, navigateToNext: self.$navigateToNext)
            
        }
    }
    

}
struct CircleSelectionView: View {
    @Binding var selectedItem: ItemType
    @Binding var showDetail: Bool
    let diameter: CGFloat = UIScreen.main.bounds.width * 0.8

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 3)
                .foregroundColor(.white.opacity(0.4))
                .frame(width: diameter, height: diameter)

            ForEach(ItemType.allCases, id: \.self) { item in
                Button(action: {
                    withAnimation {
                        print("Selected item: \(item.rawValue)")
                        selectedItem = item
                        DispatchQueue.main.async {
                            showDetail = true
                        }
                    }
                }) {
                    Image(item.rawValue.lowercased())
                        .resizable()
                        .scaledToFit()
                        .frame(width: diameter / 3, height: diameter / 3)
                        .background(selectedItem == item ? Color("Ice Blue").opacity(0.8)
 : Color.clear)
                        .clipShape(Circle())
                }
                .offset(x: self.offsetForItem(item, totalItems: ItemType.allCases.count, in: diameter).width,
                        y: self.offsetForItem(item, totalItems: ItemType.allCases.count, in: diameter).height)
            }
        }
    }

    private func offsetForItem(_ item: ItemType, totalItems: Int, in diameter: CGFloat) -> CGSize {
        let itemIndex = CGFloat(ItemType.allCases.firstIndex(of: item) ?? 0)
        let angle = (2 * .pi / CGFloat(totalItems)) * itemIndex - .pi / 2
        let radius = (diameter / 2) * 0.85
        let itemX = radius * cos(angle)
        let itemY = radius * sin(angle)

        return CGSize(width: itemX, height: itemY)
    }
}

struct ItemDetailView: View {
    let item: ItemType
    @Binding var navigateToNext: Bool
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
            VStack(spacing: 20) {
                Image(item.rawValue)
                    .resizable()
 

                Text(item.rawValue.capitalized)
                    .font(.largeTitle)


                Text(item.description)
                    .font(.title3)


                Button("Confirm") {
                    // This can navigate to another view or simply dismiss the current view.
                    Task {
                        try await saveDataToFirebase(selectedItem:item)
                        navigateToNext = true

                    }
                    presentationMode.wrappedValue.dismiss()
                    
                }
                .padding()

                
                Button("Back") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()


                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        
      
    }
    
    func saveDataToFirebase(selectedItem: ItemType) async throws {
        guard let user = viewModel.currentUser else {
            print("No authenticated user found.")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("anxiety_peak").document(user.id).collection("Level_One").document("Screen_Three")

        let data: [String: Any] = [
            "selectedItem": selectedItem.rawValue,
            "selectedItemDescription": selectedItem.description,
            "timeCompleted": FieldValue.serverTimestamp()
        ]

        userRef.setData(data) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
            }
        }
    }
}


//struct ItemDetailView: View {
//    let item: ItemType
//    @Environment(\.presentationMode) var presentationMode
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Image(item.rawValue)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 200, height: 200)
//                .shadow(radius: 10)
//
//            Text(item.rawValue.capitalized)
//                .font(.largeTitle)
//                .foregroundColor(.white)
//
//            Text(item.description)
//                .font(.title3)
//                .foregroundColor(.white)
//                .multilineTextAlignment(.center)
//                .padding()
//                .frame(maxWidth: 300)
//                .background(Color.black.opacity(0.5))
//                .cornerRadius(12)
//
//            Button("Confirm") {
//                // This can navigate to another view or simply dismiss the current view.
//                presentationMode.wrappedValue.dismiss()
//            }
//            .padding()
//            .background(Color.green)
//            .foregroundColor(.white)
//            .cornerRadius(10)
//
//            Button("Back") {
//                presentationMode.wrappedValue.dismiss()
//            }
//            .padding()
//            .background(Color.red)
//            .foregroundColor(.white)
//            .cornerRadius(10)
//
//            Spacer()
//        }
//        .padding()
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.blue)
//        .edgesIgnoringSafeArea(.all)
//    }
//}

struct ConfirmationView: View {
    let item: ItemType

    var body: some View {
        VStack {
            Text("You have picked \(item.rawValue)")
                .font(.largeTitle)
                .padding()
                .foregroundColor(.white)

            Text(item.description)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.white)
                .background(Color.black.opacity(0.5))
                .cornerRadius(12)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blue.edgesIgnoringSafeArea(.all))
    }
}
struct AvatarAndSherpaView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        if let user = viewModel.currentUser {
            HStack {
                Image(user.selectedAvatar) // Ensure this image is in your asset catalog
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .padding(.leading)
                    .offset(x: -30) // Move Sherpa image 20 points down
                    .offset(y: 10) // Move Sherpa image 20 points down
                
                Spacer()
                
                Image("Sherpa") // Ensure this image is in your asset catalog
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)
                    .padding(.trailing)
                    .offset(x: -10) // Move Sherpa image 20 points down
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Module3View(selectedItem: .pen)
    }
}
