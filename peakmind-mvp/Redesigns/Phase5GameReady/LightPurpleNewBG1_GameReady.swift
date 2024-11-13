import SwiftUI

struct P5_1_1: View {
    var closeAction: (String) -> Void
    @State private var showNextScreen = false
    
    var body: some View {
        ZStack {
            // Background image
            Image("LightPurpleNewBG")
                .resizable()
                .ignoresSafeArea(.all) // Ensure the image covers the entire screen
            
            // Content
            VStack(spacing: 16) {
                Spacer()
                    .frame(height: 160)
                
                // Intro Text
                Text("Welcome to the next phase of managing your anxiety, focused on building a support system. You'll engage in fun activities to explore the ongoing support around you.")
                    .font(.custom("SFProText-Bold", size: 30))
                    .foregroundColor(Color("LightPurpleTitleColor"))
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
                                gradient: Gradient(colors: [Color("LightPurpleButtonGradientColor1"), Color("LightPurpleButtonGradientColor2")]),
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
                        destination: P5MentalHealthFeatureView(),
                        isActive: $showNextScreen,
                        label: { EmptyView() }
                    )
                )
            }
            .padding(.horizontal)
        }
    }
}
