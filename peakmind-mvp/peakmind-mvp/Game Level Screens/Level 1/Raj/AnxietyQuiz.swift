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
    @State private var buttonOpacities = [0.0,0.0,0.0,0.0]


    var body: some View {
        ZStack {
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
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .animation(nil)
                        .onAppear {
                            animateText()
                        }
                    
                    
                }
                .background(Color(hex: "#0f075a"))
                .cornerRadius(15)
                .animation(.easeInOut)
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
                                        .fontWeight(.light)
                                        .padding(.top, 30)
                                        .padding(.bottom, 30)
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.white)
                                        .background(Color(hex: "#080331"))
                                        .cornerRadius(15)
                                        .opacity(buttonOpacities[index])
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
        }.background(Background())
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        buttonOpacities[0] = 1
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        buttonOpacities[1] = 1
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        buttonOpacities[2] = 1
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        buttonOpacities[3] = 1
                    }
                }
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
