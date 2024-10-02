//
//  TriangleView.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 9/15/24.
//

import Foundation
import SwiftUI

import Foundation

struct WellbeingResponse: Codable {
    let emotionalResilience: EmotionalResilience
    let mood: Mood
    let overallEmotionalWellBeing: OverallEmotionalWellBeing
    let stress: Stress

    // Custom coding keys to match JSON keys with special characters
    enum CodingKeys: String, CodingKey {
        case emotionalResilience = "Emotional Resilience"
        case mood = "Mood"
        case overallEmotionalWellBeing = "Overall Emotional Well-being"
        case stress = "Stress"
    }
}

struct EmotionalResilience: Codable {
    let result: String
    let score: Int
}

struct Mood: Codable {
    let result: String
    let score: Int
}

struct OverallEmotionalWellBeing: Codable {
    let category: String
    let score: Double
}

struct Stress: Codable {
    let result: String
    let score: Int
}

import Foundation

class NetworkManager: ObservableObject {
    @Published var wellbeingData: WellbeingResponse?

    func fetchWellbeingData(for userID: String) {
        guard let url = URL(string: "http://34.134.8.212:5100/analyze_emotional_wellbeing") else {
            print("Invalid URL")
            return
        }

        // Prepare the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Set the request body
        let body: [String: Any] = ["user_id": userID]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        // Create the data task
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle errors
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }

            // Ensure data is not nil
            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(WellbeingResponse.self, from: data)
                print("Decoded Response: \(response)")
                DispatchQueue.main.async {
                    self.wellbeingData = response
                    print("wellbeingData set: \(self.wellbeingData)")
                }
            } catch let DecodingError.dataCorrupted(context) {
                print("Data corrupted: \(context.debugDescription)")
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found: \(context.debugDescription)")
            } catch let DecodingError.typeMismatch(type, context) {
                print("Type mismatch for type '\(type)': \(context.debugDescription)")
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found: \(context.debugDescription)")
            } catch {
                print("General decoding error: \(error.localizedDescription)")
            }
        }.resume()
    }
}




struct RectangleView: View {
    @State private var selectedCategory: Category? = nil
    @State private var selectedScore: Int = 0 // Track the score of the selected category
    @State private var showCategoryPage = false
    @State private var showMentalModelView = false
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var networkManager: NetworkManager // Add this line
    @State private var isPrioritySet: Bool = false
    @State private var showQuizOnboarding: Bool = false
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
                                CategorySliceView(
                                    category: .emotional,
                                    score: networkManager.wellbeingData?.emotionalResilience.score ?? 70,
                                    onTap: { showCategoryPage(.emotional, score: networkManager.wellbeingData?.emotionalResilience.score ?? 0) }
                                )
                                CategorySliceView(
                                    category: .cognitive,
                                    score: networkManager.wellbeingData?.mood.score ?? 0,
                                    onTap: { showCategoryPage(.cognitive, score: networkManager.wellbeingData?.mood.score ?? 0) }
                                )
//                                CategorySliceView(category: .emotional, score: 45, onTap: { showCategoryPage(.emotional, score: 45) }) // Example score: 45
//                                CategorySliceView(category: .cognitive, score: 85, onTap: { showCategoryPage(.cognitive, score: 85) }) // Example score: 85
//                                CategorySliceView(category: .physical, score: 20, onTap: { showCategoryPage(.physical, score: 20) }) // Example score: 20
//                                CategorySliceView(category: .social, score: 65, onTap: { showCategoryPage(.social, score: 65) }) // Example score: 65
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .padding(.bottom, 20)

                    }
                    .padding(.top, -10)
                    .onAppear {
                        networkManager.fetchWellbeingData(for: viewModel.currentUser?.id ?? "")
                        print("tjis is the main")
                        print(networkManager.wellbeingData?.emotionalResilience.score)
                        Task {
                            do {
                                isPrioritySet = try await viewModel.checkIfPriorityExists()
                                showQuizOnboarding = !isPrioritySet
                            } catch {
                                print("Failed to check priority existence: \(error.localizedDescription)")
                            }
                        }
                    }
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
                CategoryPageView(category: category, score: selectedScore, onBack: resetPage)
                    .environmentObject(networkManager)// Pass the selected score to CategoryPageView
                    .transition(.opacity)
                    .animation(.easeInOut, value: showCategoryPage)
            }
        }
        .sheet(isPresented: $showQuizOnboarding) {
            QuizOnboardingView().environmentObject(viewModel)
        }
        
    }

    // Function to show the category page with score
    private func showCategoryPage(_ category: Category, score: Int) {
        print(score);
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
import Firebase
import FirebaseCore

extension AuthViewModel {
    func checkIfPriorityExists() async throws -> Bool {
        guard let userId = currentUser?.id else { throw NSError(domain: "AuthError", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."]) }
        
        let db = Firestore.firestore()
        let docSnapshot = try await db.collection("priority").document(userId).getDocument()
        return docSnapshot.exists
    }
}

struct CategoryPageView: View {
    var category: Category
    var score: Int // Add score parameter
    var onBack: () -> Void
    @EnvironmentObject var networkManager: NetworkManager // Add this line

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
//                        ProgressCircle(progress: CGFloat(from: networkManager.wellbeingData?.emotionalResilience ?? 0/100), iconName: "heart.fill") // 75% filled with heart icon
//                        ProgressCircle(progress:  CGFloat(from: networkManager.wellbeingData?.mood ?? 0/100), iconName: "brain.head.profile")  // 50% filled with brain icon
//                        ProgressCircle(progress:  CGFloat(from: networkManager.wellbeingData?.stress ?? 0/100), iconName: "bolt.fill") // 25% filled with bolt icon
//                        ProgressCircle(progress: 0.9, iconName: "person.fill")  // 90% filled with person icon
                        ProgressCircle(progress: 0.9, iconName: "heart.fill")  // 90% filled with person icon
                        ProgressCircle(progress: 0.7, iconName: "brain.head.profile")  // 90% filled with person icon
                        ProgressCircle(progress: 0.8, iconName: "bolt.fill")  // 90% filled with person icon
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
                .onAppear{
                    print(score)
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
    //@Binding private var animatedProgress: CGFloat
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







struct AnalyticsView21: View {
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
