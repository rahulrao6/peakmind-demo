//
//  MentalModelView.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 9/15/24.
//

import Foundation
import SwiftUI

struct MentalModelView: View {
    var onBack: () -> Void // Back button callback
    var score: Int // Score passed from RectangleView
    @State private var animatedScore: CGFloat = 0 // State to track the animated score
    @State private var scoreChange: Int = 2
    @State private var showScoreText: Bool = false // State to show the score text
    @State private var showHistory = false
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var networkManager: NetworkManager
    var body: some View {
        NavigationView { // Ensure this view is inside NavigationView
            ZStack {
                // Set the background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "452198")!, Color(hex: "1a1164")!]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(alignment: .center, spacing: 20) {
                        // Custom Back button
                        HStack {
                            Button(action: onBack) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                                    .padding()
                            }
                            Spacer()
                        }

                        // Centered and custom font title
                        Text("Your Mental Model")
                            .font(.custom("SFProText-Heavy", size: 36))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.top, -10)

                        // Rectangular background for the gauge and the last change text
                        ZStack {
                            // Background rectangle with color 180b53
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: "180b53")!)
                                .frame(height: 380) // Increased height for better spacing
                                .padding(.horizontal, 25)

                            VStack {
                                // Centered Gauge with last change
                                VStack(spacing: 40) { // Added spacing between elements
                                    Text("Last change: \(scoreChange >= 0 ? "+" : "")\(scoreChange)")
                                        .font(.custom("SFProText-Bold", size: 18))
                                        .foregroundColor(.white)

                                    // Gauge with gradient progress bar and white glow
                                    ZStack {
                                        Circle()
                                            .trim(from: 0, to: animatedScore / 100) // Use animatedScore for smooth animation
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color(hex: "db437d")!, Color.white]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                            )
                                            .frame(width: 200, height: 200)
                                            .rotationEffect(.degrees(-90))
                                            .shadow(color: Color.white.opacity(0.3), radius: 10, x: 0, y: 0) // White glow effect

                                        // Show score text after gauge is filled
                                        if showScoreText {
                                            Text("\(Int(animatedScore))") // Display animated score
                                                .font(.custom("SFProText-Heavy", size: 70))
                                                .foregroundColor(.white)
                                        }
                                    }

                                    // View history as clickable text
                                    Text("View History")
                                        .font(.custom("SFProText-Bold", size: 18))
                                        .foregroundColor(.white)
                                        .onTapGesture {
                                            showHistory.toggle()
                                        }
                                        .sheet(isPresented: $showHistory) {
                                            HistoryView() // Show history in a new view
                                        }
                                }
                                .padding(.bottom, 20) // Spacing between VStack and bottom of the rectangle
                            }
                            .onAppear {
                                withAnimation(.easeInOut(duration: 1.5)) { // Animate the score over 1.5 seconds
                                    animatedScore = CGFloat(score) // Animate to the passed score
                                }
                                // Delay the score text until after the gauge fills up
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    withAnimation {
                                        showScoreText = true
                                    }
                                }
                            }
                        }
                        .padding(.bottom, -30) // Spacing between rectangle and View History

                        // Categories section
                        Text("Your Categories")
                            .font(.custom("SFProText-Heavy", size: 28))
                            .foregroundColor(.white)
                            .padding(.leading, 20) // Align left
                            .padding(.top, 40)

                        // 2x2 grid of categories using their specific icons
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 40), GridItem(.flexible(), spacing: 40)], spacing: 20) {
                            
                            ForEach(Category.allCases, id: \.self) { category in
                                if category != .cognitive && category != .social { // Exclude locked categories
                                    if let score = networkManager.wellbeingData?.categoryScores[category.rawValue],
                                       let factorScoresForCategory = networkManager.wellbeingData?.factorScores.filter({ $0.value.category == category.rawValue }) {
                                        
                                        // Reduce factorScoresForCategory into a dictionary of [String: Double]
                                        let factorScoresDictionary = factorScoresForCategory.reduce(into: [String: Double]()) { (result, item) in
                                            if let score = item.value.score { // Unwrap the optional score safely
                                                result[item.key] = score // Add the unwrapped score to the result
                                            }
                                        }

                                        
                                        NavigationLink(destination: FactorPage(category: category, score: Int(score ?? 0), factorScores: factorScoresDictionary)) { // Navigate to FactorPage
                                            VStack {
                                                Image(systemName: category.iconName)
                                                    .resizable()
                                                    .foregroundColor(.white)
                                                    .frame(width: 50, height: 50)
                                                    .padding()
                                                Text(category.rawValue)
                                                    .font(.custom("SFProText-Bold", size: 18))
                                                    .foregroundColor(.white)
                                            }
                                            .frame(width: 160, height: 160)
                                            .background(Color(hex: "180b53"))
                                            .cornerRadius(15)
                                        }
                                    }
                                }
                            }
                            
//                            ForEach([Category.emotional, Category.cognitive, Category.physical, Category.social], id: \.self) { category in
//                                NavigationLink(destination: FactorPage(category: category)) { // Navigate to FactorPage
//                                    VStack {
//                                        Image(systemName: category.iconName)
//                                            .resizable()
//                                            .foregroundColor(.white)
//                                            .frame(width: 50, height: 50)
//                                            .padding()
//                                        Text(category.rawValue)
//                                            .font(.custom("SFProText-Bold", size: 18))
//                                            .foregroundColor(.white)
//                                    }
//                                    .frame(width: 160, height: 160)
//                                    .background(Color(hex: "180b53"))
//                                    .cornerRadius(15)
//                                }
//                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, -20)
                        .padding()

                        // Suggested personalized suggestions section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Personalized Suggestions")
                                .font(.custom("SFProText-Heavy", size: 24))
                                .foregroundColor(.white)
                                .padding(.top, 20)
                                .padding(.leading, 20)

                            Text("Placeholder text for recommendations and personalized advice.")
                                .font(.custom("SFProText-Bold", size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            Text("Your Insights")
                                .font(.custom("SFProText-Heavy", size: 24))
                                .foregroundColor(.white)
                                .padding(.top, 20)
                                .padding(.leading, 20)

                            Text("Placeholder text for insights about your mental model performance.")
                                .font(.custom("SFProText-Bold", size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 40)
                        .padding(.horizontal, 10)
                        .padding(.top, -20)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        }
        .onAppear{
            networkManager.fetchWellbeingDataServer(for: viewModel.currentUser?.id ?? "")
            animatedScore = networkManager.wellbeingData?.overallProfileScore ?? 0
            print(networkManager.wellbeingData?.overallProfileScore)
            print(animatedScore)
            
        }
    }
        
}

// HistoryView to show score changes with dates
struct HistoryView: View {
    var historyData: [(date: String, score: Int)] = [
        ("2023-09-01", 75),
        ("2023-09-02", 78),
        ("2023-09-03", 74),
        ("2023-09-04", 80),
        ("2023-09-05", 82),
        ("2023-09-06", 77),
        ("2023-09-07", 79)
    ]

    var body: some View {
        NavigationView {
            List(historyData, id: \.date) { entry in
                HStack {
                    Text(entry.date)
                        .font(.custom("SFProText-Bold", size: 22)) // Set to SF Pro Bold
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(entry.score)")
                        .font(.custom("SFProText-Bold", size: 22)) // Set to SF Pro Bold
                        .foregroundColor(.white)
                }
                .listRowBackground(Color(hex: "180b53")!) // Set row background color
            }
            .listStyle(PlainListStyle()) // Style the list
            .background(Color(hex: "180b53")!.edgesIgnoringSafeArea(.all)) // Set background color for the list view
            .navigationTitle("Score History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { // Customizing the title appearance
                ToolbarItem(placement: .principal) {
                    Text("Score History")
                        .font(.custom("SFProText-Bold", size: 22)) // Set to SF Pro Bold
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// Preview for testing the MentalModelView
struct MentalModelView_Previews: PreviewProvider {
    static var previews: some View {
        MentalModelView(onBack: {}, score: 89)
    }
}
