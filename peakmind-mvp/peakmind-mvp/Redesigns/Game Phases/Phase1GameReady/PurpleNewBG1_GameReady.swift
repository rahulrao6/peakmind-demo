import SwiftUI

struct P1_1: View {
    @State private var showNextScreen = false
    var closeAction: (String) -> Void
    
    var body: some View {
        ZStack {
            // Background image
            Image("PurpleNewBG")
                .resizable()
                .ignoresSafeArea(.all) // Ensure the image covers the whole screen including the sides and vertical space
            
            // Content
            VStack(spacing: 16) {
                Spacer()
                    .frame(height: 160)
                
                // Intro Text
                Text("Let's explore an educational module designed to delve into various aspects of mental health, equipping you with coping strategies along the way.")
                    .font(.custom("SFProText-Bold", size: 30))
                    .foregroundColor(Color("PurpleTitleColor"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 0)
                
                Spacer()
                
                // Next Button
                Button(action: {
                    showNextScreen = true
                    closeAction("You completed your first level!")
                    
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
                .background(
                    NavigationLink(
                        destination: MentalHealthFeatureView(),
                        isActive: $showNextScreen,
                        label: { EmptyView() }
                    )
                )
            }
            .padding(.horizontal)
        }
    }
}
