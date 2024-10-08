import SwiftUI

struct P2_1_1: View {
    var closeAction: (String) -> Void
    @State private var showNextScreen = false
    
    var body: some View {
        ZStack {
            // Background image
            Image("GreenNewBG")
                .resizable()
                .ignoresSafeArea(.all) // Ensure the image covers the entire screen
            
            // Content
            VStack(spacing: 16) {
                Spacer()
                    .frame(height: 120)
                
                // Intro Text
                Text("Buckle up for a quick and informative session on anxiety. We'll break down the different types and what it all means. By the end, you'll be an anxiety expert (well, almost!) Let's do this!")
                    .font(.custom("SFProText-Bold", size: 30))
                    .foregroundColor(Color("GreenTitleColor"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                
                Spacer()
                
                // Next Button
                Button(action: {
                    closeAction("")
                }) {
                    Text("Next")
                        .font(.custom("SFProText-Bold", size: 20))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("GreenButtonGradientColor1"), Color("GreenButtonGradientColor2")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(15)
                        .shadow(color: Color.white.opacity(1), radius: 10, x: 0, y: 0)
                }
                .padding(.bottom, 50)
            }
            .padding(.horizontal)
        }
    }
}
