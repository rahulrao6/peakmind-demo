import SwiftUI

struct OnboardingView2: View {
    @State private var currentIndex = 0
    
    let images = ["Onboarding1", "Onboarding2", "Onboarding3"]
    
    var body: some View {
        ZStack {
            // Image Slider
            TabView(selection: $currentIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    GeometryReader { geometry in
                                           Image(images[index])
                                               .resizable()
                                               .scaledToFill()
                                               .frame(width: geometry.size.width, height: geometry.size.height) // Use GeometryReader to fill the available space
                                               .clipped() // Ensure no overflow
                                       }
                                       .ignoresSafeArea() // Ignore the safe area to ensure full-screen effect
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hide default dots
            
            // Overlay: Dots and Button
            VStack {
                Spacer() // Push content to the bottom
                
                // Dots indicator
                HStack(spacing: 8) {
                    ForEach(0..<images.count, id: \.self) { index in
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(currentIndex == index ? Color(hex: "abdeff") : .gray)
                    }
                }
                .padding(.bottom, 20) // Padding between dots and button
                
                // Start Journey button
                Button(action: {
                    // Action for Start Journey
                }) {
                    Text("Start Journey")
                        .font(Font.custom("SFProText-Heavy", size: 18))
                        .foregroundColor(.black)
                        .padding()
                        .background(Color(hex: "abdeff"))
                        .cornerRadius(10)
                }
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea() // Covers entire screen
    }
}



struct OnboardingView2_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView2()
    }
}
