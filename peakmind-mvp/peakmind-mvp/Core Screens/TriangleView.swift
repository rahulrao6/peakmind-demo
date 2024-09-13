import SwiftUI

struct RectangleView: View {
    @State private var selectedCategory: Category? = nil
    @State private var selectedScore: Int = 0 // Track the score of the selected category
    @State private var showCategoryPage = false
    @State private var showMentalModelView = false

    var body: some View {
        ZStack {
            // Background Gradient (top to bottom)
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "452198")!, Color(hex: "1a1164")!]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            if showMentalModelView {
                MentalModelView(onBack: {
                    withAnimation {
                        showMentalModelView = false
                    }
                }, score: selectedScore) // Correct order of arguments
                .transition(.move(edge: .trailing)) // Slide in from the right
                .animation(.easeInOut(duration: 0.6), value: showMentalModelView) // Smooth sliding animation
            } else if !showCategoryPage {
                VStack {
                    // PeakMind Profile Title, centered
                    HStack {
                        Spacer()
                        Text("Your PeakMind")
                            .font(.custom("SFProText-Heavy", size: 36))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.top)
                        Spacer()
                    }
                    .padding(.top, 50)

                    // Category Slices with Gradient Bar above them (Left to Right Gradient)
                    VStack {
                        // Gradient Legend (Horizontal) and Labels "Low" and "High"
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
                        .padding(.bottom, 20)

                        // Rectangular Box with Category Slices
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: "180b53")!)
                                .frame(width: 360, height: 490)
                                .padding(.horizontal, -70)

                            VStack(spacing: 20) {
                                CategorySliceView(category: .emotional, score: 45, onTap: { showCategoryPage(.emotional, score: 45) }) // Example score: 45
                                CategorySliceView(category: .cognitive, score: 85, onTap: { showCategoryPage(.cognitive, score: 85) }) // Example score: 85
                                CategorySliceView(category: .physical, score: 20, onTap: { showCategoryPage(.physical, score: 20) }) // Example score: 20
                                CategorySliceView(category: .social, score: 65, onTap: { showCategoryPage(.social, score: 65) }) // Example score: 65
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .padding(.bottom, 20)

                    }
                    .padding(.top, -10)

                    // "View Summary" button with updated style (wider and smaller font)
                    Button(action: {
                        withAnimation {
                            selectedScore = 75 // Example score passed to MentalModelView
                            showMentalModelView = true
                        }
                    }) {
                        Text("View Summary")
                            .font(.custom("SFProText-Heavy", size: 18)) // Smaller font size
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 300) // Wider button
                            .background(Color(hex: "180b53")!)
                            .cornerRadius(10)
                    }
                    .padding(.bottom)
                }
                .padding()
            } else if let category = selectedCategory {
                CategoryPageView(category: category, score: selectedScore, onBack: resetPage) // Pass the selected score to CategoryPageView
                    .transition(.opacity)
                    .animation(.easeInOut, value: showCategoryPage)
            }
        }
    }

    // Function to show the category page with score
    private func showCategoryPage(_ category: Category, score: Int) {
        selectedCategory = category
        selectedScore = score
        withAnimation {
            showCategoryPage = true
        }
    }

    // Function to reset and go back
    private func resetPage() {
        withAnimation {
            showCategoryPage = false
            showMentalModelView = false
        }
    }
}


struct CategoryPageView: View {
    var category: Category
    var score: Int // Add score parameter
    var onBack: () -> Void

    @State private var showFactorPage = false // Add state to trigger navigation

    var body: some View {
        ZStack {
            getColorForScore(score) // Set background color based on score
                .edgesIgnoringSafeArea(.all) // Full screen background color

            VStack {
                // Back button at the top left with an arrow
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "arrow.left") // Using SF Symbol for the arrow
                            .font(.system(size: 24, weight: .bold)) // Adjust size and weight
                            .foregroundColor(score > 70 ? .black : .white) // Change arrow color based on score
                            .padding() // Add some padding
                            .background(Color.black.opacity(0.2)) // Add semi-transparent background
                            .cornerRadius(10) // Rounded edges for the button
                    }
                    Spacer() // Pushes the back button to the left
                }
                .padding([.leading, .top], 20) // Add padding to position the button in the top left corner

                Spacer() // Move title closer to the middle
                Text("\(category.rawValue)")
                    .font(.custom("SFProText-Heavy", size: 45)) // Font changed to SFProText-Heavy
                    .foregroundColor(score > 70 ? .black : .white) // Set title color based on score
                    .padding(.top, -60)

                // Add a single rectangle around all progress circles
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.2)) // Set background color and opacity
                        .frame(width: 340, height: 330)

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: -30),
                            GridItem(.flexible(), spacing: 20)
                        ],
                        spacing: 30 // Adjust vertical spacing between rows
                    ) {
                        // Example of varying progress amounts (replace with actual data)
                        ProgressCircle(progress: 0.75, iconName: "heart.fill") // 75% filled with heart icon
                        ProgressCircle(progress: 0.5, iconName: "brain.head.profile")  // 50% filled with brain icon
                        ProgressCircle(progress: 0.25, iconName: "bolt.fill") // 25% filled with bolt icon
                        ProgressCircle(progress: 0.9, iconName: "person.fill")  // 90% filled with person icon
                    }
                    .padding()
                }
                .padding(.bottom, 20)

                Button(action: {
                    showFactorPage = true
                }) {
                    Text("View Factors")
                        .font(.custom("SFProText-Heavy", size: 18))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(score > 70 ? .black : .white, lineWidth: 4)
                        )
                        .foregroundColor(score > 70 ? .black : .white)
                        .padding(.horizontal, 40)
                }
                .fullScreenCover(isPresented: $showFactorPage) {
                    FactorPage(category: category)
                }

                Spacer()
            }
        }
    }
}

// Define the ProgressCircle view first
struct ProgressCircle: View {
    @State private var animatedProgress: CGFloat = 0
    var progress: CGFloat
    var iconName: String

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(hex: "dddddd")!, lineWidth: 12)
                .frame(width: 120, height: 120)

            // Progress circle (colored)
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(Color(hex: "180b53")!, lineWidth: 12)
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.0), value: animatedProgress)

            // Icon in the center
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(Color(hex: "180b53")!)
        }
        .onAppear {
            withAnimation {
                animatedProgress = progress
            }
        }
    }
}







struct AnalyticsView2: View {
    var body: some View {
        Text("Analytics Page")
            .font(.largeTitle)
            .padding()
            .foregroundColor(.black)
    }
}
func getColorForScore(_ score: Int) -> Color {
    switch score {
    case 0...10:
        return Color(hex: "db437d")!
    case 11...20:
        return Color(hex: "df5285")!
    case 21...30:
        return Color(hex: "e77097")!
    case 31...40:
        return Color(hex: "ef8daa")!
    case 41...50:
        return Color(hex: "f39bb4")!
    case 51...60:
        return Color(hex: "f8b4c6")!
    case 61...70:
        return Color(hex: "f8b4c6")!
    case 71...80:
        return Color(hex: "fde0e7")!
    case 81...90:
        return Color(hex: "fde0e7")!
    case 91...100:
        return Color(hex: "ffffff")!
    default:
        return Color.white
    }
}

struct CategorySliceView: View {
    var category: Category
    var score: Int
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(category.rawValue)
                    .font(.custom("SFProText-Heavy", size: 25))
                    .foregroundColor(score > 70 ? .black : .white)
                Image(systemName: category.iconName)
                    .foregroundColor(score > 70 ? .black : .white)
                    .padding(.trailing, 10)

            
            }
            .frame(width: 300, height: 85)
            .background(getColorForScore(score))
            .cornerRadius(10)
            .padding(.horizontal, 10)
        }
    }
}






enum Category: String {
    case emotional = "Emotional"
    case cognitive = "Cognitive"
    case physical = "Physical"
    case social = "Social"

    var color: Color {
        switch self {
        case .emotional: return Color(hex: "ea7a9d")!
        case .cognitive: return Color(hex: "f4a1b8")!
        case .physical: return Color(hex: "fee6eb")!
        case .social: return Color(hex: "db437d")!
        }
    }
    
    var iconName: String {
        switch self {
        case .emotional: return "heart.fill"
        case .cognitive: return "brain.head.profile"
        case .physical: return "bolt.fill"
        case .social: return "person.2.fill"
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RectangleView()
    }
}
