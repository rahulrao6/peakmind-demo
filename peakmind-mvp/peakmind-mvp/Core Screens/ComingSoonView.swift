import SwiftUI

struct PeakMindProfileView: View {
    var body: some View {
        ZStack {
            // Background Gradient (top to bottom)
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "452198")!, Color(hex: "1a1164")!]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                // "Your PeakMind" Text at the top under the gradient
                Text("Your PeakMind")
                    .font(.custom("SFProText-Heavy", size: 36))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.top, 40)

                
                //Spacer()
                
                // Rectangular Box with "Coming Soon" slices in a 2x2 grid
                VStack {
                    HStack {
                        Text("0")
                            .font(.custom("SFProText-Bold", size: 14))
                            .foregroundColor(.white)
                        
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "db437d")!, Color.white]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(height: 20)
                        .cornerRadius(10)
                        
                        Text("100")
                            .font(.custom("SFProText-Bold", size: 14))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 10)
                    .padding(.horizontal, 10)

                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "180b53")!)
                            .frame(width: 360, height: 510)
                            .padding(.horizontal, -100)
                        
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 20),  // First column
                                GridItem(.flexible(), spacing: 20)   // Second column
                            ],
                            spacing: 10
                        ) {
                            // Display 4 Coming Soon Boxes with top and side padding
                            ForEach(0..<4, id: \.self) { _ in
                                ComingSoonSliceView()
                                    .padding(10)  // Added padding around each gray box
                            }
                        }
                        .padding(.horizontal, 40)  // Side padding for the grid
                        .padding(.top, 0)         // Top padding for the grid
                    }
                }
                .padding(.top, 0)
                
                Spacer()
            }
        }
    }
}

struct ComingSoonSliceView: View {
    var body: some View {
        VStack {
            // Icon at the top
            Image(systemName: "clock.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.white)
            
            // "Coming Soon" text
            Text("Coming Soon")
                .font(.custom("SFProText-Heavy", size: 20))
                .foregroundColor(.white)
        }
        .frame(width: 154, height: 220)
        .background(Color.gray)
        .cornerRadius(15)
    }
}

struct PeakMindProfileView_Previews: PreviewProvider {
    static var previews: some View {
        PeakMindProfileView()
    }
}
