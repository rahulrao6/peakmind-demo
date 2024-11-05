import SwiftUI

struct P9_1: View {
    var closeAction: (String) -> Void
    @State private var showNextScreen = false
    
    var body: some View {
        ZStack {
            // Background image
            Image("PurpleNewBG")
                .resizable()
                .ignoresSafeArea(.all) // Ensure the image covers the whole screen
            
            // Main content
            VStack(spacing: 16) {
                Spacer()
                    .frame(height: 160)
                
                // Intro Text
                Text("Feeling ready for more? Let's dive deeper with another wellness question. These questions are designed to unlock your personal goals and strategies for mental well-being.")
                    .font(.custom("SFProText-Bold", size: 30))
                    .foregroundColor(Color("PurpleTitleColor"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                
                Spacer()
                
                // Next Button
                Button(action: {
                    showNextScreen = true
                }) {
                    Text("Next")
                        .font(.custom("SFProText-Bold", size: 20))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("PurpleButtonGradientColor1"), Color("PurpleButtonGradientColor2")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(15)
                        .shadow(color: Color.white.opacity(1), radius: 10, x: 0, y: 0)
                }
                .padding(.bottom, 50)
                .fullScreenCover(isPresented: $showNextScreen) {
                    P9_2(closeAction: closeAction)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct IntroView_Previews2: PreviewProvider {
    static var previews: some View {
        NavigationView {
            IntroView2()
        }
    }
}
