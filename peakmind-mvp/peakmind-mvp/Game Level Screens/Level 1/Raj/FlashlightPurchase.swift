//
//  NightfallFlavorView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/17/24.
//

import SwiftUI
import FirebaseFirestore

struct FlashlightPurchase: View {
    @EnvironmentObject var viewModel: AuthViewModel

    let titleText = "Mt. Anxiety: Level One"
    let narrationText = "At this point, you can choose to buy a flashlight for better visibility!"
    @State private var animatedText = ""
    @State private var showAlert = false
    @State var navigateToNext = false


    var body: some View {
        ZStack {
            Image("MainBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
            
            HStack {
                Image("Sherpa")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140)
                
                Spacer()
                
                Button {
                    showAlert = true
                    
                } label: {
                    HStack {
                        Text("-200 VC")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(width: 100)
                    }
                    .padding(.vertical, 15)
                    .foregroundColor(.white)
                    .background(Color.darkBlue)
                    .cornerRadius(10)
                }
                .padding(.trailing, 75)
                .frame(alignment: .trailing)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding()
            .offset(x: 25, y: 20)
            
            VStack(spacing: 20) {
                Text(titleText)
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.top, 50)
                    .padding(.horizontal)
                
                ZStack {
                    Circle()
                        .foregroundColor(Color.blue.opacity(0.5))
                        .frame(width: 225, height: 225)
                    
                    Image("Flashlight")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                }
                
                VStack(alignment: .center) {
                    Text(animatedText)
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .onAppear {
                            animateText()
                        }
                }
                .background(Color("Dark Blue"))
                .cornerRadius(15)
                .padding(.horizontal, 40)

                Spacer()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Confirm Purchase"),
                message: Text("Are you sure you want to buy this flashlight for 200 VC?"),
                primaryButton: .default(Text("Yes")) {
                    buyItem()
                    navigateToNext = true
                },
                secondaryButton: .cancel()
            )
        }
        .background(
        NavigationLink(destination: DangersOfNightfallView().navigationBarBackButtonHidden(true).environmentObject(viewModel), isActive: $navigateToNext) {
            EmptyView()
        })
    }
    
    private func buyItem() {
        let price = 200.0
        guard let currentUser = viewModel.currentUser else { return }
        let userId = currentUser.id
        let userRef = Firestore.firestore().collection("users").document(userId)

        Firestore.firestore().document(userRef.path).getDocument { snapshot, error in
            if let error = error {
                // Show alert for error
                showAlert(message: error.localizedDescription)
                return
            }
            
            guard var userData = snapshot?.data() else {
                // Show alert for data error
                showAlert(message: "Failed to fetch user data.")
                return
            }
            
            guard var balance = userData["currencyBalance"] as? Double else {
                // Show alert for balance error
                showAlert(message: "Failed to retrieve currency balance.")
                return
            }
            
            guard var inventory = userData["inventory"] as? [String] else {
                // Show alert for inventory error
                showAlert(message: "Failed to retrieve inventory.")
                return
            }
            
            // Check if user has enough balance to buy the tent
            if balance >= price {
                balance -= price
                inventory.append("Flashlight")
                userData["currencyBalance"] = balance
                userData["inventory"] = inventory
                
                Firestore.firestore().document(userRef.path).setData(userData) { error in
                    if let error = error {
                        // Show alert for setData error
                        showAlert(message: error.localizedDescription)
                        print("Error setting data: \(error)")
                    } else {
                        // Show success alert
                        showAlert(message: "Flashlight purchased successfully!")
                        print("Tent purchased successfully!")
                    }
                }
            } else {
                // Show alert for insufficient balance
                showAlert(message: "You don't have enough VC to purchase the tent.")
            }
        }
    }


    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "Purchase Alert!", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
    }

    private func animateText() {
        var charIndex = 0.0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            let roundedIndex = Int(charIndex)
            if roundedIndex < narrationText.count {
                let index = narrationText.index(narrationText.startIndex, offsetBy: roundedIndex)
                animatedText.append(narrationText[index])
            }
            charIndex += 1
            if roundedIndex >= narrationText.count {
                timer.invalidate()
            }
        }
        timer.fire()
    }
}

struct FlashPurchase_Previews: PreviewProvider {
    static var previews: some View {
        TentPurchase()
    }
}
