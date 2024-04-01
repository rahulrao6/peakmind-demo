import SwiftUI
import FirebaseFirestore
//SCREEN FOUR
struct AnxietyQuiz: View {
    @EnvironmentObject var viewModel: AuthViewModel
    let titleText = "Mt. Anxiety: Level One"
    let narrationText = "What are ways that you currently manage your anxiety?"
    @State private var animatedText = ""
    let options = [
        "Talk to a friend",
        "Go for a walk",
        "Go for a bike ride",
        "Find a hobby"
    ]
    @State private var selectedOption: Int? = nil
    @State var navigateToNext = false



    var body: some View {
        ZStack {
            Image("MainBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(width: 140)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
                .offset(x: 25, y: 20)
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

                VStack(spacing: 20) {
                    ForEach(0..<2, id: \.self) { row in
                        HStack(spacing: 20) {
                            ForEach(0..<2, id: \.self) { col in
                                let index = row * 2 + col
                                Button(action: {
                                    selectedOption = index
                                    
                                    Task {
                                        try await saveDataToFirebase()
                                        navigateToNext = true
                                    }
                                    
                                    
                                }) {
                                    Text(options[index])
                                        .fontWeight(.semibold)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.white)
                                        .background(Color("Dark Blue"))
                                        .cornerRadius(15)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
                .padding(.top, 20)

                
                NavigationLink(destination: SetHabits().navigationBarBackButtonHidden(true).environmentObject(viewModel), isActive: $navigateToNext) {
                    EmptyView()
                }

                
                Spacer()
            }
        }
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
    
    func saveDataToFirebase() async throws{
        guard let user = viewModel.currentUser else {
            print("No authenticated user found.")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("anxiety_peak").document(user.id).collection("Level_One").document("Screen_Four")

        let data: [String: Any] = [
            "question": narrationText,
            "userAnswer": options[selectedOption ?? 0],
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

struct AnxietyQuiz_Previews: PreviewProvider {
    static var previews: some View {
        AnxietyQuiz()
    }
}
