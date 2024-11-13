import SwiftUI

struct Tutorial6: View {
    var closeAction: (String) -> Void
    
    var body: some View {
        ZStack {
            JournalView()
                .padding(.top, 50) // Add padding at the top of JournalView

            VStack {
                Spacer()
                
                Text("Tap to Continue")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(.white)
                    .padding(.bottom, 5) // Space between Tap text and the footer
                
                // Footer-like rectangle for the description
                VStack {
                    Text("This is your journal, come here to spark your creativity.")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .padding()
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity) // Full width footer
                .frame(height: 160) // Adjust height as needed
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.white)
                        .opacity(0.9)
                )
            }
        }
        .ignoresSafeArea(.all) // Ensure the footer reaches the bottom
        .onTapGesture {
            closeAction("")
        }
    }
}
