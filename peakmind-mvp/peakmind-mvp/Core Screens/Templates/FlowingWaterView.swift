import SwiftUI

struct FlowingWaterView_Previews: PreviewProvider {
    static var previews: some View {
        FlowingWaterView()
    }
}

struct FlowingWaterView: View {
    @State private var gradientOffset: Double = 0
    @State private var answerText: String = ""

    var body: some View {
        ZStack {
            Color("Purple")
                .edgesIgnoringSafeArea(.all)
            
            // Flowing radial gradient blobs
            RadialGradient(gradient: Gradient(colors: [Color("Pink").opacity(0.6), Color("Pink").opacity(0.3)]),
                           center: .center,
                           startRadius: 50,
                           endRadius: 500)
                .scaleEffect(CGFloat(1 + gradientOffset))
                .animation(Animation.linear(duration: 10).repeatForever(autoreverses: true))
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    self.gradientOffset = 0.1
                }
            
            VStack {
                Spacer()
                
                // Title
                Text("Wellness Question")
                    .font(.system(size: 18, weight: .bold))  // Increase the font size and make it bold
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)  // Adjust padding for smaller screens
                
                // Question
                Text("What do you most enjoy when you have a day to yourself?")
                    .font(.system(size: 24, weight: .bold))  // Increase the font size and make it bold
                    .foregroundColor(.white)
                    .padding(.top, 0)
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)
                
                // Scrollable Text box
                ZStack(alignment: .topTrailing) {
                    TextEditor(text: $answerText)
                        .frame(height: 200) // Increase the height of the text box
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.9), Color.white.opacity(0.7)]),
                                           startPoint: .top,
                                           endPoint: .bottom)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.navyBlue, lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                    
                    // Character counter
                    Text("\(answerText.count)/250")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.trailing, 40)
                        .padding(.top, 8)
                }
                
                // Submit button
                Button(action: {
                    // Action for the submit button
                }) {
                    Text("Submit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.top, 20)
                }
                
                Spacer()
            }
        }
    }
}
