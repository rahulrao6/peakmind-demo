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
    let categoryScores: [String: Double?]  // "Emotional": null, "Physical": 25.0
    let factorScores: [String: FactorScore]  // Maps to each factor (e.g. "Emotional_Emotional Resilience": {...})
    let overallProfileScore: Double  // Overall profile score

    // Custom coding keys to match JSON keys
    enum CodingKeys: String, CodingKey {
        case categoryScores = "category_scores"
        case factorScores = "factor_scores"
        case overallProfileScore = "overall_profile_score"
    }
}

struct FactorScore: Codable {  // Represents each factor's score and weight
    let category: String
    let factor: String
    let score: Double?  // Some scores can be null
    let weight: Double
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

struct WellbeingData: Codable {
    let categoryScores: [String: Double]
    let factorScores: [String: FactorScore]
}

import SwiftUI

enum Factor: String, CaseIterable, Identifiable {
    case Mood = "Mood"
    case Stress = "Stress"
    case EmotionalResilience = "Emotional Resilience"
    case Energy = "Energy"
    case Sleep = "Sleep"
    
    var id: String { rawValue }
    
    var category: String {
        switch self {
        case .Mood, .Stress, .EmotionalResilience:
            return "Emotional"
        case .Energy, .Sleep:
            return "Physical"
        }
    }
    
    @ViewBuilder
    func quizView() -> some View {
        switch self {
        case .Mood:
            PHQ9QuizView()
        case .Stress:
            PSSQuizView()
        case .EmotionalResilience:
            NMRQQuizView()
        case .Energy:
            EnergyQuizView()
        case .Sleep:
            ISIQuizView()
        }
    }
}

//struct FactorScore: Codable {
//    let category: String
//    let factor: String
//    let score: Double?
//    let weight: Double
//}
import Firebase
import FirebaseFirestore

class NetworkManager: ObservableObject {
    @Published var wellbeingData: WellbeingResponse?

    // Fetch the wellbeing data from the API
    func fetchWellbeingData(for userID: String) {
        guard let url = URL(string: "http://34.28.198.191:5010/analyze_profile") else {
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
                    // Save the data to Firebase
                    self.saveProfileDataToFirebase(userID: userID, wellbeingData: response)
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }

    // Save the fetched profile data to Firebase
    func saveProfileDataToFirebase(userID: String, wellbeingData: WellbeingResponse) {
        let db = Firestore.firestore()
        
        // Prepare the data for Firebase
        let profileData: [String: Any] = [
            "category_scores": [
                "Emotional": wellbeingData.categoryScores["Emotional"] ?? nil,
                "Physical": wellbeingData.categoryScores["Physical"] ?? nil
            ],
            "factor_scores": wellbeingData.factorScores.mapValues { factor in
                [
                    "category": factor.category,
                    "factor": factor.factor,
                    "score": factor.score ?? nil,
                    "weight": factor.weight
                ]
            },
            "overall_profile_score": wellbeingData.overallProfileScore
        ]

        // Save the data under the 'profile_data' collection
        db.collection("profile_data").document(userID).setData(profileData) { error in
            if let error = error {
                print("Error saving profile data to Firebase: \(error.localizedDescription)")
            } else {
                print("Profile data successfully saved to Firebase.")
            }
        }
    }
}


import SwiftUI

struct RectangleView: View {
    @State private var selectedCategory: Category? = nil
    @State private var selectedScore: Int = 0 // Track the score of the selected category
    @State private var showCategoryPage = false
    @State private var showMentalModelView = false
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var networkManager: NetworkManager
    @State private var isPrioritySet: Bool = false
    @State private var showQuizOnboarding: Bool = true
    
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
                }, score: selectedScore)
                .transition(.move(edge: .trailing))
                .animation(.easeInOut(duration: 0.6), value: showMentalModelView)
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
                                // Display Category Scores
                                ForEach(Category.allCases, id: \.self) { category in
                                    if let score = networkManager.wellbeingData?.categoryScores[category.rawValue] {
                                        CategorySliceView(category: category, score: Int(score ?? 0)) {
                                            showCategoryPage(category, score: Int(score ?? 0))
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.top, -10)
                    
                    .onAppear {
                        networkManager.fetchWellbeingData(for: viewModel.currentUser?.id ?? "")
                        Task {
                            do {
                                print("cehckign priority")
                                isPrioritySet = try await viewModel.checkIfPriorityExists()
                                print("tihsohfdi if it exis ")
                                
                                print(isPrioritySet)
                            } catch {
                                print("Failed to check priority existence: \(error.localizedDescription)")
                            }
                            showQuizOnboarding = !isPrioritySet
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
                    .environmentObject(networkManager) // Pass the selected score to CategoryPageView
                    .transition(.opacity)
                    .animation(.easeInOut, value: showCategoryPage)
            }
        }
    }
        
        // MARK: - Functions
        
        // Function to show the category page with score
         func showCategoryPage(_ category: Category, score: Int) {
            selectedCategory = category
            selectedScore = score
            withAnimation {
                showCategoryPage = true
            }
        }
        
        // Function to reset and go back
         func resetPage() {
            withAnimation {
                showCategoryPage = false
                showMentalModelView = false
            }
        }
    }
//struct RectangleView: View {
//    @State private var selectedCategory: Category? = nil
//    @State private var selectedScore: Int = 0 // Track the score of the selected category
//    @State private var showCategoryPage = false
//    @State private var showMentalModelView = false
//    @EnvironmentObject var viewModel: AuthViewModel
//    @EnvironmentObject var networkManager: NetworkManager
//    @State private var isPrioritySet: Bool = false
//    @State private var showQuizOnboarding: Bool = true
//    
//    var body: some View {
//        ZStack {
//            // Background Gradient (top to bottom)
//            LinearGradient(
//                gradient: Gradient(colors: [Color(hex: "452198")!, Color(hex: "1a1164")!]),
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .edgesIgnoringSafeArea(.all)
//
//            if showMentalModelView {
//                MentalModelView(onBack: {
//                    withAnimation {
//                        showMentalModelView = false
//                    }
//                }, score: selectedScore) // Correct order of arguments
//                .transition(.move(edge: .trailing)) // Slide in from the right
//                .animation(.easeInOut(duration: 0.6), value: showMentalModelView) // Smooth sliding animation
//            } else if !showCategoryPage {
//                VStack {
//                    // PeakMind Profile Title, centered
//                    HStack {
//                        Spacer()
//                        Text("Your PeakMind")
//                            .font(.custom("SFProText-Heavy", size: 36))
//                            .multilineTextAlignment(.center)
//                            .foregroundColor(.white)
//                            .padding(.top)
//                        Spacer()
//                    }
//                    .padding(.top, 50)
//
//                    // Category Slices with Gradient Bar above them (Left to Right Gradient)
//                    VStack {
//                        // Gradient Legend (Horizontal) and Labels "Low" and "High"
//                        HStack {
//                            Text("0")
//                                .font(.custom("SFProText-Bold", size: 14))
//                                .foregroundColor(.white)
//
//                            LinearGradient(
//                                gradient: Gradient(colors: [Color(hex: "db437d")!, Color.white]),
//                                startPoint: .leading,
//                                endPoint: .trailing
//                            )
//                            .frame(height: 20)
//                            .cornerRadius(10)
//
//                            Text("100")
//                                .font(.custom("SFProText-Bold", size: 14))
//                                .foregroundColor(.white)
//                        }
//                        .padding(.bottom, 20)
//
//                        // Rectangular Box with Category Slices
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 20)
//                                .fill(Color(hex: "180b53")!)
//                                .frame(width: 360, height: 490)
//                                .padding(.horizontal, -70)
//
//                            VStack(spacing: 20) {
//                                // Display Category Scores
//                                ForEach(Category.allCases, id: \.self) { category in
//                                    if let score = networkManager.wellbeingData?.categoryScores[category.rawValue] {
//                                        CategorySliceView(category: category, score: Int(score ?? 0)) {
//                                            showCategoryPage(category, score: Int(score ?? 0))
//                                        }
//                                    }
//                                }
//                            }
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                        }
//                        .padding(.bottom, 20)
//                    }
//                    .padding(.top, -10)
//                    .onAppear {
//                        networkManager.fetchWellbeingData(for: viewModel.currentUser?.id ?? "")
//                        Task {
//                            do {
//                                isPrioritySet = try await viewModel.checkIfPriorityExists()
//                                showQuizOnboarding = !isPrioritySet
//                            } catch {
//                                print("Failed to check priority existence: \(error.localizedDescription)")
//                            }
//                        }
//                    }
//                    // "View Summary" button with updated style (wider and smaller font)
//                    Button(action: {
//                        withAnimation {
//                            selectedScore = 75 // Example score passed to MentalModelView
//                            showMentalModelView = true
//                        }
//                    }) {
//                        Text("View Summary")
//                            .font(.custom("SFProText-Heavy", size: 18)) // Smaller font size
//                            .foregroundColor(.white)
//                            .padding()
//                            .frame(maxWidth: 300) // Wider button
//                            .background(Color(hex: "180b53")!)
//                            .cornerRadius(10)
//                    }
//                    .padding(.bottom)
//                }
//                .padding()
//            } else if let category = selectedCategory {
//                CategoryPageView(category: category, score: selectedScore, onBack: resetPage)
//                    .environmentObject(networkManager) // Pass the selected score to CategoryPageView
//                    .transition(.opacity)
//                    .animation(.easeInOut, value: showCategoryPage)
//            }
//        }
//        .sheet(isPresented: $showQuizOnboarding) {
//            QuizOnboardingView().environmentObject(viewModel)
//        }
//    }
//
//    // Function to show the category page with score
//    private func showCategoryPage(_ category: Category, score: Int) {
//        selectedCategory = category
//        selectedScore = score
//        withAnimation {
//            showCategoryPage = true
//        }
//    }
//
//    // Function to reset and go back
//    private func resetPage() {
//        withAnimation {
//            showCategoryPage = false
//            showMentalModelView = false
//        }
//    }
//}

// Define the CategoryPageView to show factors dynamically
//struct CategoryPageView: View {
//    var category: Category
//    var score: Int
//    var onBack: () -> Void
//    @EnvironmentObject var networkManager: NetworkManager
//    @State private var showFactorPage = false // Trigger for navigation
//
//    var body: some View {
//        ZStack {
//            getColorForScore(score)
//                .edgesIgnoringSafeArea(.all)
//
//            VStack {
//                // Back button
//                HStack {
//                    Button(action: onBack) {
//                        Image(systemName: "arrow.left")
//                            .font(.system(size: 24, weight: .bold))
//                            .foregroundColor(score > 70 ? .black : .white)
//                            .padding()
//                            .background(Color.black.opacity(0.2))
//                            .cornerRadius(10)
//                    }
//                    Spacer()
//                }
//                .padding([.leading, .top], 20)
//
//                Spacer()
//
//                // Category Title
//                Text(category.rawValue)
//                    .font(.custom("SFProText-Heavy", size: 45))
//                    .foregroundColor(score > 70 ? .black : .white)
//                    .padding(.top, -60)
//
//                // Factor Circles
//                ZStack {
//                    RoundedRectangle(cornerRadius: 20)
//                        .fill(Color.black.opacity(0.2))
//                        .frame(width: 340, height: 330)
//
//                    LazyVGrid(
//                        columns: [
//                            GridItem(.flexible(), spacing: -30),
//                            GridItem(.flexible(), spacing: 20)
//                        ],
//                        spacing: 30
//                    ) {
//                        if let factorScores = networkManager.wellbeingData?.factorScores {
//                            ForEach(factorScores.keys.sorted(), id: \.self) { factorKey in
//                                if factorScores[factorKey]?.category == category.rawValue,
//                                   let factorScore = factorScores[factorKey]?.score {
//                                    ProgressCircle(progress: CGFloat(factorScore / 100), iconName: factorKey)
//                                }
//                            }
//                        }
//                    }
//                    .padding()
//                }
//                .padding(.bottom, 20)
//
//                Spacer()
//            }
//        }
//    }
//}
import SwiftUI

struct CategoryPageView: View {
    var category: Category
    var score: Int
    var onBack: () -> Void
    @EnvironmentObject var networkManager: NetworkManager
    @State private var selectedFactor: Factor? = nil // Track the selected factor for quiz
    
    var body: some View {
        ZStack {
            getColorForScore(score)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Back Button
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(score > 70 ? .black : .white)
                            .padding()
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(10)
                    }
                    Spacer()
                }
                .padding([.leading, .top], 20)
                
                Spacer()
                
                // Category Title
                Text(category.rawValue)
                    .font(.custom("SFProText-Heavy", size: 45))
                    .foregroundColor(score > 70 ? .black : .white)
                    .padding(.top, -60)
                
                // Factor Circles or Quiz Buttons
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.2))
                        .frame(width: 340, height: 330)
                    
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 30),
                            GridItem(.flexible(), spacing: 30)
                        ],
                        spacing: 30
                    ) {
                        if let factorScores = networkManager.wellbeingData?.factorScores {
                            // Iterate through all factors
                            ForEach(Factor.allCases, id: \.self) { factor in
                                if factor.category == category.rawValue {
                                    if let factorScore = factorScores[factor.rawValue]?.score {
                                        // Display ProgressCircle if score exists
                                        ProgressCircle(progress: CGFloat(factorScore) / 100, iconName: factor.rawValue)
                                            .onTapGesture {
                                                // Optionally, navigate to a detailed view
                                            }
                                    } else {
                                        // Display a button to take the quiz if score doesn't exist
                                        Button(action: {
                                            selectedFactor = factor
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(hex: "180b53")!)
                                                    .frame(width: 80, height: 80)
                                                Image(systemName: "plus.circle")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 40, height: 40)
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                .padding(.bottom, 20)
                
                Spacer()
            }
        }
        .sheet(item: $selectedFactor) { factor in
            factor.quizView()
                .environmentObject(networkManager) // Pass environment objects if needed
        }
    }
    
    // Helper method to get color based on score
    private func getColorForScore(_ score: Int) -> Color {
        switch score {
        case 0..<50:
            return Color.red
        case 50..<80:
            return Color.orange
        default:
            return Color.green
        }
    }
}
// Function to generate colors based on score
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
import Firebase
import FirebaseCore

extension AuthViewModel {
    func checkIfPriorityExists() async throws -> Bool {
        guard let userId = currentUser?.id else { throw NSError(domain: "AuthError", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."]) }
        
        let db = Firestore.firestore()
        let docSnapshot = try await db.collection("priority").document(userId).getDocument()
        print("this si if the fsoifd exists")
        print(docSnapshot.exists)
        return docSnapshot.exists
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






enum Category: String, CaseIterable, Identifiable {
    case emotional = "Emotional"
    case cognitive = "Cognitive"
    case physical = "Physical"
    case social = "Social"

    var id: String { rawValue }  // Make the rawValue the unique identifier

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
