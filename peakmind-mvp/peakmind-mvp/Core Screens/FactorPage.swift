//
//  File.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 9/15/24.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import SwiftUI

enum FactorQuiz: String, CaseIterable, Identifiable {
    case mood = "PHQ9"
    case stress = "PSS"
    case resilience = "NMRQ"
    case energy = "Energy"
    case sleep = "ISI"

    var id: String { self.rawValue }

    @ViewBuilder
    var quizView: some View {
        switch self {
        case .mood:
            PHQ9QuizView()
        case .stress:
            PSSQuizView()
        case .resilience:
            NMRQQuizView()
        case .energy:
            EnergyQuizView()
        case .sleep:
            ISIQuizView()
        }
    }
}

// Example Views for demonstration. Replace with your actual view implementations.


struct FactorPage: View {
    var category: Category // Pass the category for contextual use
    @Environment(\.presentationMode) var presentationMode // For dismissing the view
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var surveyScores: [String: Int] = [:]
    @State private var surveyScoresPhysical: [String: Int] = [:]
    @State private var selectedFactor2: FactorQuiz? = nil // Track the selected factor for quiz
    @State private var selectedFactor3: String? = nil // Track the selected factor for quiz

    @State private var isDataLoaded = false

    @EnvironmentObject var healthKitManager: HealthKitManager

    @EnvironmentObject var networkManager: NetworkManager
    var score: Int
    var factorScores: [String: Double]
    // State to track whether to show the FactorDetailView
    @State private var showFactorDetail = false
    @State private var selectedNodeIndex: Int? = nil // To track the selected node
    @State private var selectedFactor: Int = 0// To track the selected node

    // Static positions for the nodes, adjusted for centering and longer lines
    @State private var nodePositions: [CGSize] = [
        CGSize(width: -80, height: -50), // Top-left
        CGSize(width: 80, height: -50),  // Top-right
        CGSize(width: -80, height: 50),  // Bottom-left
        CGSize(width: 80, height: 50)    // Bottom-right
    ]

    var body: some View {
        ZStack {
            // Set the background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "452198")!, Color(hex: "1a1164")!]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Back button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss() // Dismiss the view
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(10)
                    }
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.top, 40)

                // Top label
                Text("\(category.rawValue) Factors")
                    .font(.custom("SFProText-Heavy", size: 36))
                    .foregroundColor(.white)

                // Node graph background rectangle
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "180b53")!)
                        .frame(height: 250)
                        .padding(.horizontal, 20)
                        .padding(.top, 25)
                        .padding(.bottom, 0)

                    // Draw line connecting nodes
                    Path { path in
                        let nodeCenters = getNodeCenters()
                        path.move(to: nodeCenters[0])
                        for center in nodeCenters.dropFirst() {
                            path.addLine(to: center)
                        }
                    }
                    .stroke(Color.white, lineWidth: 2)
                    VStack{
                        ForEach(factorScores.sorted(by: { $0.key < $1.key }), id: \.key) { factorName, score in
                            //if factor.category == category.rawValue {
                            //if let factorScore = factorScores[factor.rawValue] {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: getIconName(for: 1)) // Use index as the parameter
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(Color(hex: "180b53")!)
                                )
                                .onTapGesture {
                                    //selectedNodeIndex = factorName
                                    Task{
                                        selectedFactor = Int(score)
                                        selectedFactor3 = factorName
                                        await MainActor.run {
                                            if let _ = selectedFactor3 {
                                                showFactorDetail = true // Trigger navigation only if selectedFactor3 is set
                                            }
                                        }
                                    }
                                    //showFactorDetail = true // Trigger navigation
   
                                }
                            //                            } else {
                            //                                Text("t")
                            //                            }
                            //}
                        }
                    }
                }

                // Label above the percentage tiles
                Text("Your Analytics")
                    .font(.custom("SFProText-Heavy", size: 28))
                    .foregroundColor(.white)
                    .padding(.top, 10)

                // 2x2 grid of percentage tiles
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(surveyScores.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(hex: "180b53")!)
                                .frame(height: 100)

                            VStack {
                                Text(key)
                                    .font(.custom("SFProText-Heavy", size: 18))
                                    .foregroundColor(.white)

                                Text("\(value)")
                                    .font(.custom("SFProText-Heavy", size: 24))
                                    .foregroundColor(.white)
                            }
                        }
                        .onTapGesture {
                            // Navigate to the factor detail view
                            selectedFactor2 = FactorQuiz(rawValue: key)

                        }
                    }
                    if (category == .physical) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(hex: "180b53")!)
                                .frame(height: 100)

                            VStack {
                                Text("Steps")
                                    .font(.custom("SFProText-Heavy", size: 18))
                                    .foregroundColor(.white)

                                Text("\(Int(healthKitManager.liveStepCount))")
                                    .font(.custom("SFProText-Heavy", size: 24))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    
                }
                .padding(.horizontal, 20)

                Spacer()

                // "Add Factor" button at the bottom right
                HStack {
                    Spacer()
                    Button(action: {
                        // No action currently
                    }) {
                        Text("Add Factor")
                            .font(.custom("SFProText-Bold", size: 18))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(hex: "180b53")!)
                            .cornerRadius(10)
                    }
                    .padding(.trailing, 20)
                }
            }
            .onAppear {
                fetchDataBasedOnCategory()
                print(factorScores)
                print(category)
                print(score)
            }
            // Present FactorDetailView when a node is tapped
            .fullScreenCover(isPresented: Binding(get: {
                showFactorDetail && selectedFactor3 != nil
            }, set: { newValue in
                showFactorDetail = newValue
            })) {
                FactorDetailView(factorScore: selectedFactor, selectedFactor: selectedFactor3 ?? "").environmentObject(viewModel) // Present detail view when node is tapped
            }
            .sheet(item: $selectedFactor2) { factor in
                factor.quizView
                    .environmentObject(networkManager)
                    .onDisappear {
                        // Update factor scores once quiz is completed (mocking score for now)
                        // Example: factorScores[factor.rawValue] = Double.random(in: 60...100)
                    }
            }
        }
    }

    private func fetchDataBasedOnCategory() {
        switch category {
        case .emotional:
            fetchSurveyScores()
        case .physical:
            print("phy")
            fetchSurveyScoresPhysical()
            //healthKitManager.fetchLiveStepCount()
            //fetchPhysicalData()
        default:
            print("No specific data fetching setup for this category")
        }
    }
    
    private func fetchSurveyScores() {
        guard let userId = viewModel.currentUser?.id else { return }
        let db = Firestore.firestore()

        db.collection("users").document(userId).collection("profiles")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching survey scores: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else { return }
                for document in documents {
                    let data = document.data()
                    if (document.documentID == "PHQ9" || document.documentID == "NMRQ" || document.documentID == "PSS" ){
                        let score = data["score"] as? Int ?? 0
                        surveyScores[document.documentID] = score
                    }
                }
                print(surveyScores)
                isDataLoaded = true
            }
    }
    
    private func fetchSurveyScoresPhysical() {
        guard let userId = viewModel.currentUser?.id else { return }
        let db = Firestore.firestore()

        db.collection("users").document(userId).collection("profiles")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching survey scores: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else { return }
                for document in documents {
                    let data = document.data()
                    if (document.documentID == "Energy" || document.documentID == "ISI" ){
                        let score = data["score"] as? Int ?? 0
                        surveyScores[document.documentID] = score
                    }
                }
                print(surveyScores)
                isDataLoaded = true
            }
    }
    
    // Helper function to return the icon name for each node
    private func getIconName(for index: Int) -> String {
        let icons = ["heart.fill", "brain.head.profile", "bolt.fill", "person.fill", ""]
        return icons[index]
    }

    // Helper function to return the percentage change for each tile
    private func getPercentageChange(for index: Int) -> String {
        let changes = ["+5%", "-10%", "+8%", "-3%"]
        return changes[index]
    }

    // Helper function to get the centers of each node based on current positions
    private func getNodeCenters() -> [CGPoint] {
        let startX: CGFloat = UIScreen.main.bounds.width / 2 // Center of the screen
        let startY: CGFloat = 150 // Adjusted Y point within the rectangle for centering

        return nodePositions.map { position in
            CGPoint(x: startX + position.width, y: startY + position.height)
        }
    }
}

struct ScoreEntry: Identifiable {
    var id: String
    var score: Double
    var date: Date
}
import FirebaseFirestore


// Detail view for the selected factor (Mood Detail)
struct FactorDetailView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    @Environment(\.presentationMode) var presentationMode // For dismissing the view
    var factorScore: Int // Pass the category for contextual use
    var selectedFactor: String
    var sampleData: [Double] = [0.4, 0.6, 0.5, 0.8, 0.75, 0.6, 0.85] // Example data
    @State private var scoreEntries: [ScoreEntry] = []
    

    var body: some View {
        ZStack {
            // Set the same background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "452198")!, Color(hex: "1a1164")!]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Progress circle for the factor's score
                ZStack {
                    Circle()
                        .trim(from: 0, to: 0.75) // Example progress of 75%
                        .stroke(Color.white, lineWidth: 20)
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90)) // Start from top
                    Text("\(factorScore)") // Example score
                        .font(.custom("SFProText-Heavy", size: 36))
                        .foregroundColor(.white)
                }
                .padding(.top, 40)

                // Line graph for score history
                VStack {
                    Text("Score Over the Last Month")
                        .font(.custom("SFProText-Bold", size: 24))
                        .foregroundColor(.white)
                    LineGraph(data: sortedScores) // Custom LineGraph view
                        .stroke(Color.white, lineWidth: 2)
                        .frame(height: 200)
                }
                .padding(.top, 20)

                // Placeholder for scoring details
                VStack(alignment: .leading) {
                    Text("Scoring Details")
                        .font(.custom("SFProText-Bold", size: 24))
                        .foregroundColor(.white)
                    Text("Placeholder text for scoring details. This will include more detailed explanations and insights about the score.")
                        .font(.custom("SFProText-Regular", size: 16))
                        .foregroundColor(.white)
                        .padding(.top, 10)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Spacer()

                // Back button
                Button(action: {
                    presentationMode.wrappedValue.dismiss() // Dismiss the detail view
                }) {
                    Text("Back")
                        .font(.custom("SFProText-Bold", size: 18))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(hex: "180b53")!)
                        .cornerRadius(10)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            print(selectedFactor)
            fetchFactorHistory(userId: viewModel.currentUser?.id ?? "", factorName: selectedFactor) { entries in
                self.scoreEntries = entries
                print(scoreEntries)

            }
        }
    }
    
    var sortedScores: [Double] {
        return scoreEntries
            .sorted(by: { $0.date < $1.date })
            .map { $0.score/100 }
    }

    func fetchFactorHistory(userId: String, factorName: String, completion: @escaping ([ScoreEntry]) -> Void) {
        let db = Firestore.firestore()
        db.collection("profile_data").document(userId).collection("scores")
            .order(by: "timestamp", descending: true) // Ensures the results are ordered by date
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                    completion([])
                    return
                }
                print(querySnapshot)
                var scoreEntries: [ScoreEntry] = []
                for document in querySnapshot!.documents {
                    print(document)
                    let data = document.data()
                    if let factorScores = data["factor_scores"] as? [String: Any],
                       let factorData = factorScores[factorName] as? [String: Any],
                       let score = factorData["score"] as? Double,
                       let timestamp = data["timestamp"] as? Timestamp {
                        let date = timestamp.dateValue()
                        scoreEntries.append(ScoreEntry(id: document.documentID, score: score, date: date))
                    }
                }

                // Sorting the score entries by date in ascending order
                scoreEntries.sort(by: { $0.date < $1.date })
                completion(scoreEntries)
            }
    }
}

// Line graph shape
struct LineGraph: Shape {
    var data: [Double]

    func path(in rect: CGRect) -> Path {
        var path = Path()

        guard data.count > 1 else { return path }

        let stepX = rect.width / CGFloat(data.count - 1)
        let points = data.enumerated().map { index, value in
            CGPoint(x: CGFloat(index) * stepX, y: rect.height * (1 - CGFloat(value)))
        }

        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }

        return path
    }
}

// Preview for testing

