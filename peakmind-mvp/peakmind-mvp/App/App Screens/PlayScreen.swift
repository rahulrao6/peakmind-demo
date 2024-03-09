import SwiftUI

struct PlayScreen: View {
    @State private var animateImage = false
    @State private var showTopText = false
    @State private var showBottomText = false
    @State private var tapToContinueOpacity = 0.0
    @State private var tapCount = 0  // State variable to count taps
    @State private var navigateToQuestions = false  // State variable to control navigation

    var body: some View {
        ZStack {
            Image("ChatBG2")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("Mt. Anxiety")
                    .font(.system(size: 50, weight: .bold, design: .default))
                     .foregroundColor(.white)
                     .padding(.top, 40)

                Spacer()
            }

            if showTopText {
                Text("Welcome to Base Camp! I will be your Sherpa through your journey.")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 340, height: 150)

                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.5)))
                    .padding(.horizontal)
                    .offset(y: -170)

            }

            if showBottomText {
                Text("Are you ready to conquer Mt. Anxiety? Take our following quiz.")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 310, height: 130)

                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.5)))
                    .padding(.horizontal)
            }
            
            Spacer()

            
            Text("Tap to continue")
                .foregroundColor(.white)
                .opacity(tapToContinueOpacity)
                .animation(.easeInOut(duration: 1), value: tapToContinueOpacity)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding()
                .offset(x: -55, y: -30)

            
            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(width: 140)
                .opacity(animateImage ? 1 : 0)
                .animation(.easeInOut(duration: 1), value: animateImage)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
                .offset(x: 25, y: 20)
            NavigationLink(destination: QuestionsView(), isActive: $navigateToQuestions) {
                EmptyView()
            }
        }
        .onAppear {
            animateImage = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                 tapToContinueOpacity = 1.0
             }
        }
        .onTapGesture {
            tapCount += 1
            
            if !showTopText {
                showTopText = true
            } else if !showBottomText {
                showBottomText = true
            } else if tapCount == 3 {
                navigateToQuestions = true  // Trigger navigation on the third tap
            }
        }
    }
}

struct PlayScreen_Previews: PreviewProvider {
    static var previews: some View {
        PlayScreen()
    }
}
