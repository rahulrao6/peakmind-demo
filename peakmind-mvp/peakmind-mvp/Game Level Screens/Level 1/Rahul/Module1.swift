import SwiftUI

struct Module1: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var animateImage = false
    @State private var navigateToNext = false
    @State private var currentDialogueIndex = 0
    @State private var tapToContinueOpacity = 0.0
    @State private var dialogueHistory: [String] = []

    let dialogues = [
        "I’m your sherpa and welcome to anxiety mountain. Here you’ll learn about everything anxiety.",
        "Your mental health improves every leg up the mountain. Your journey will go across 10 different levels, each teaching you more and more about anxiety.",
        "As your sherpa, I’ll serve as your guide every step of the way. Remember, your personal plan will have all of your current habits, tasks, and goals.",
        "We’ll go through anxiety education, wellness questions, minigames, item collection, journaling, and more as you advance on your quest.",
        "Take one big deep breath… you’re doing a great thing for your mental health. Let’s make it to the top."
    ]

    var body: some View {
        ZStack {
            Image("MainBG")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                
                ScrollViewReader { scrollView in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                            ForEach(Array(dialogueHistory.enumerated()), id: \.element) { index, dialogue in
                                dialogueText(dialogue, id: index)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .onChange(of: dialogueHistory.count) { _ in
                        scrollView.scrollTo(dialogueHistory.count - 1, anchor: .bottom)
                    }
                }

                Spacer()

                tapToContinueText
                NavigationLink(destination: Module2View().navigationBarBackButtonHidden(true).environmentObject(viewModel), isActive: $navigateToNext) {
                    EmptyView()
                }
            }

            sherpaImage
        }
        .onAppear(perform: setupView)
        .onTapGesture(perform: advanceDialogue)
    }

    private var tapToContinueText: some View {
        Text("Tap to continue")
            .foregroundColor(.white)
            .opacity(tapToContinueOpacity)
            .animation(.easeInOut(duration: 1), value: tapToContinueOpacity)
            .frame(maxWidth: .infinity, maxHeight: 200, alignment: .bottomTrailing)
            .padding()
            .offset(x: -55, y: -30)
    }

    private var sherpaImage: some View {
        Image("Sherpa")
            .resizable()
            .scaledToFit()
            .frame(width: 140)
            .opacity(animateImage ? 1 : 0)
            .animation(.easeInOut(duration: 1), value: animateImage)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            .padding()
            .offset(x: 25, y: 20)
    }

    private func dialogueText(_ dialogue: String, id: Int) -> some View {
        Text(dialogue)
            .id(id)
            .font(.title)
            .foregroundColor(.white)
            .padding(30) // Adjust the padding value as needed
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.5)))
            .padding(.horizontal, 30) // Increased side padding for the dialogue box
    }

    private func setupView() {
        animateImage = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            tapToContinueOpacity = 1.0
        }
    }

    private func advanceDialogue() {
        if currentDialogueIndex < dialogues.count {
            dialogueHistory.append(dialogues[currentDialogueIndex])
            currentDialogueIndex += 1
        }
        if currentDialogueIndex == dialogues.count {
            navigateToNext = true
        }
    }
}

// Preview provider for SwiftUI Canvas
struct Module1_Previews: PreviewProvider {
    static var previews: some View {
        Module1().environmentObject(AuthViewModel())
    }
}
