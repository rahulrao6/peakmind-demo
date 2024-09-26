import SwiftUI

struct DailyCheckInView: View {
    @State private var emotionalRating: Double = 3
    @State private var physicalRating: Double = 3
    @State private var socialRating: Double = 3
    @State private var cognitiveRating: Double = 3
    
    var body: some View {
        ZStack {
            // Background with Linear Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "452198")!, Color(hex: "1a1164")!]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                Spacer()
                
                // Title
                Text("Daily Check-In")
                    .font(.custom("SFProText-Heavy", size: 34))
                    .foregroundColor(.white)
                    .padding(.bottom, 0)
                    .padding(.top, 30)
                    .padding(.leading, 20) // Left-aligned
                
                // All questions on the same page
                VStack(alignment: .leading, spacing: 10) {
                    QuestionView(
                        question: "How would you rate your emotional well-being today?",
                        rating: $emotionalRating
                    )
                    QuestionView(
                        question: "How would you rate your physical well-being today?",
                        rating: $physicalRating
                    )
                    QuestionView(
                        question: "How would you rate your social well-being today?",
                        rating: $socialRating
                    )
                    QuestionView(
                        question: "How would you rate your cognitive abilities today?",
                        rating: $cognitiveRating
                    )
                }
                .padding(.horizontal, 20) // Equal padding on both sides
                
                Spacer()
                
                // Submit button
                Button(action: {
                    // Add logic for submission here
                }) {
                    Text("Submit")
                        .font(.custom("SFProText-Bold", size: 18))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "ca4c73")!)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .padding(.top, 5)
            }
        }
    }
}

// Question view with a slider
struct QuestionView: View {
    var question: String
    @Binding var rating: Double

    let descriptors = ["Poor", "Fair", "Average", "Good", "Great"]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Multi-line Question Text
            Text(question)
                .font(.custom("SFProText-Bold", size: 20))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(nil) // Allow multi-line
                .fixedSize(horizontal: false, vertical: true) // Prevent truncation and allow text to wrap
            
            // Custom slider with a smaller thumb
            CustomSlider(value: $rating, range: 1...5)
                .frame(height: 20) // Custom frame for better alignment
            
            // Descriptor Text
            Text(descriptors[Int(rating) - 1])
                .font(.custom("SFProText-Bold", size: 16))
                .foregroundColor(.white)
                .padding(.top, -15)
        }
        .padding() // Padding inside the background
        .background(Color(hex: "180b53")!) // Color-coded background behind the question block
        .cornerRadius(12) // Optional: Rounded corners for better appearance
    }
}

// Custom Slider View
struct CustomSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geometry in
            // Slider track
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 11)
                
                Capsule()
                    .fill(Color(hex: "ca4c73")!)
                    .frame(width: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width, height: 11)
                
                // Custom thumb circle
                Circle()
                    .fill(Color(hex: "ca4c73")!)                    
                    .frame(width: 18, height: 18) // Smaller circle for thumb
                    .offset(x: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width - 6) // Align thumb properly
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            let sliderValue = max(min(Double(gesture.location.x / geometry.size.width) * (range.upperBound - range.lowerBound) + range.lowerBound, range.upperBound), range.lowerBound)
                            value = sliderValue.rounded()
                        }
                    )
            }
        }
        .frame(height: 20) // Height of the whole slider
    }
}



struct DailyCheckInView_Previews: PreviewProvider {
    static var previews: some View {
        DailyCheckInView()
    }
}
