import SwiftUI
import FirebaseFirestore

struct SetHabits: View {
    @EnvironmentObject var viewModel: AuthViewModel

    let titleText = "Mt. Anxiety: Level One"
    let narrationText = "Let's set your first habit. A habit is a task that you will do everything until it is second nature for you."
    @State private var habitText = ""
    @State private var animatedText = ""
    @State private var showAlert = false
    @State private var isButtonVisible = false
    @State private var selectedDate = Date()


    var body: some View {
        if let user = viewModel.currentUser {
            ZStack {
                Image("ChatBG2")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .aspectRatio(contentMode: .fill)
                
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
                        //.frame(width: 220)
                        .padding()
                    
                }
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
                        TextField("", text: $habitText, prompt: Text("Set your habit here!").foregroundColor(.gray))
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            //.multilineTextAlignment(.center)
                            .padding()
                            .onChange(of: habitText) { newValue in
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
                        DatePicker("When do you want this habit?", selection: $selectedDate, displayedComponents: .date)
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

                        }) {
                            Text("Set Habit")
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
}

struct SetHabits_Previews: PreviewProvider {
    static var previews: some View {
        SetHabits()
    }
}
