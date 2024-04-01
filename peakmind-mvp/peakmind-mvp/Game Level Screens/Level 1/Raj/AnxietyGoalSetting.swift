//
//  AnxietyGoalSetting.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/26/24.
//


import SwiftUI
import FirebaseFirestore

struct AnxietyGoalSetting: View {
    @EnvironmentObject var viewModel: AuthViewModel

    let titleText = "Mt. Anxiety: Level One"
    let narrationText = "Time to make you first goal. Goals are used to help you see your improvement!"
    @State private var goalText = ""
    @State private var animatedText = ""
    @State private var showAlert = false
    @State private var isButtonVisible = false
    @State private var selectedDate = Date()
    @State var navigateToNext = false
    @State var showPopup = false



    var body: some View {
        if let user = viewModel.currentUser {
            ZStack {
                Image("MainBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .aspectRatio(contentMode: .fill)
                
<<<<<<< HEAD
                AvatarAndSherpaView()

=======
                HStack {
                    Image("Sherpa")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140)
                        .padding()
                    
                    Spacer()
                    
                    Image(user.selectedAvatar)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, alignment: .bottomTrailing)
                        .scaleEffect(2)

                        //.frame(width: 220)
                        .padding()
                    
                }
>>>>>>> main
                .frame(/*maxWidth: .infinity,*/ maxHeight: .infinity, alignment: .bottom)
                .padding(.top)
                .padding(.horizontal)
                //.offset(x: 25, y: 20)
                
                VStack(spacing: 20) {
                    Text(titleText)
                        .font(.system(size: 34, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .padding(.top, 50)
                        .padding(.horizontal)
                    
                    
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
                    
                    VStack() {
                        TextField("", text: $goalText, prompt: Text("Set your goal here!").foregroundColor(.gray))
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            //.multilineTextAlignment(.center)
                            .padding()
                            .onChange(of: goalText) { newValue in
                                withAnimation {
                                    isButtonVisible = !newValue.isEmpty
                                }
                            }
                        
                    }
                    .background(Color("Dark Blue"))
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .padding(.horizontal, 40)
                    
                    
                    VStack {
                        DatePicker("When do you want this goal?", selection: $selectedDate, displayedComponents: .date)
                            .colorScheme(.dark) // or .light to get black text
                            .accentColor(.white) // Set accent color
                            .padding()
                            .background(Color("Dark Blue"))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .background(Color("Dark Blue"))
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .padding(.horizontal, 40)
                    
                    if isButtonVisible {
                        Button(action: {
                            
                            showPopup = true

                            
                            Task {
                                try await saveDataToFirebase()
                                
                            }
                            
                            
                        }) {
                            Text("Set Goal")
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.darkBlue)
                                .cornerRadius(8)
                        }
                        .transition(.opacity)
                    }
                    
                    Spacer()
                    
                }
            }
            .sheet(isPresented: $showPopup) {
                // Content of the popup
                VStack {
                    Text("Goal Pop Up")
                        .font(.title)
                        .padding()
                    Text("Pop up to describe where to access goal, also tells user about goals being tracked for future use.")
                        .multilineTextAlignment(.center)
                        .padding()
                    Button {
                        showPopup = false
                        navigateToNext = true
                        //addCash(amount: 100)
                    } label: {
                        Text("Close")

                    }
                }
            }
            .background(
            NavigationLink(destination: TentPurchase().navigationBarBackButtonHidden(true).environmentObject(viewModel), isActive: $navigateToNext) {
                EmptyView()
            })
        }
    }
        
    func addCash(amount: Double) {
        guard let currentUser = viewModel.currentUser else {
            print("User not logged in.")
            return
        }
        
        let userId = currentUser.id
        let userRef = Firestore.firestore().collection("users").document(userId)

        Firestore.firestore().document(userRef.path).getDocument { snapshot, error in
            if let error = error {
                return
            }
            
            guard var userData = snapshot?.data() else {
                return
            }
            
            guard var balance = userData["currencyBalance"] as? Double else {
                return
            }
            
                balance += amount
                
                userData["currencyBalance"] = balance
                
                Firestore.firestore().document(userRef.path).setData(userData) { error in
                    if let error = error {
                        print("Error setting data: \(error)")
                    } else {
                        print("added successfully!")
                        showAlert(message: "$100 added to your account!")
                    }
                }
             
        }
    }
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "Account Update!", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    

    private func animateText() {
        var charIndex = 0.0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
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
    
    func saveDataToFirebase() async throws {
        guard let user = viewModel.currentUser else {
            print("No authenticated user found.")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("goals").document(user.id).collection("user_goals").document()

        let data: [String: Any] = [
            "goalText": goalText,
            "expectedDate": selectedDate,
            "actualDateCompleted": "", // Set to nil initially, it will be updated when the habit is completed
            "isCompleted": false
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

struct AnxietyGoalSetting_Previews: PreviewProvider {
    static var previews: some View {
        AnxietyGoalSetting()
    }
}
