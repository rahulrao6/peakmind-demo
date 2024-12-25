//
//  RecommendedActions.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 12/23/24.
//

import Foundation
import SwiftUI


import SwiftUI

enum RecommendationType: String, Codable {
    case relaxation
    case journaling
    case movement
    case custom
}

/// Each card has:
/// - A unique ID
/// - A type (which drives background color or icon)
/// - A description (e.g., "Take 5 deep breaths.")
/// - Possibly tags or metadata for AI tracking
struct RecommendedAction: Identifiable, Codable {
    let id: String
    let type: RecommendationType
    let description: String
    var isCompleted: Bool
    var isDeclined: Bool
    
    // Possibly store tags, e.g. ["breathing", "mood"]
    var tags: [String] = []
}

struct RecommendedTask: Codable, Identifiable {
    let id: String
    let type: String  // "relaxation", "journaling", etc. (enum or string)
    let description: String
    let tags: [String]
    let color: String  // hex color string, or store in the enum
    var completed: Bool
    var declined: Bool
    var rating: Int?   // e.g., 1..5 or nil
}


import Combine
import SwiftUI
import FirebaseFirestore

import SwiftUI
import FirebaseFirestore

class RecommendationsViewModel: ObservableObject {
    @Published var tasks: [RecommendedTask] = []
    @Published var showCompletionScreen = false
    @Published var showBadge = false
    
    private var db = Firestore.firestore()
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
        loadActiveTasks()
    }
    
    func loadActiveTasks() {
        let ref = db.collection("users").document(userId)
                     .collection("recommendations").document("active")
        ref.getDocument { snapshot, error in
            guard let data = snapshot?.data() else {
                // No tasks in Firestore: fetch from ML or handle “intro to profiles”
                self.fetchFromModelIfEligible()
                return
            }
            do {
                // decode tasks array
                let tasksData = data["tasks"] as? [[String: Any]] ?? []
                let jsonData = try JSONSerialization.data(withJSONObject: tasksData)
                let loadedTasks = try JSONDecoder().decode([RecommendedTask].self, from: jsonData)
                DispatchQueue.main.async {
                    self.tasks = loadedTasks.filter { !$0.declined } // or handle in code
                }
                self.checkAllTasksCompletion()
            } catch {
                print("Error decoding tasks: \(error)")
            }
        }
    }
    
    func fetchFromModelIfEligible() {
        // Check user assessments or prerequisites first
        guard userCompletedAssessment() else {
            // Show "intro to profiles" or default
            self.tasks = []
            return
        }
        
        // Hit your ML service, e.g. GET /recommendations?userId=...
        // For example:
        // Mocked data:
        let newTasks = [
            RecommendedTask(id: "task_101", type: "relaxation",
                            description: "Take 5 deep breaths", tags: ["breathing"],
                            color: "#ADD8E6", completed: false, declined: false, rating: nil),
            RecommendedTask(id: "task_102", type: "journaling",
                            description: "Log today's mood", tags: ["mood"],
                            color: "#98FB98", completed: false, declined: false, rating: nil),
            RecommendedTask(id: "task_103", type: "movement",
                            description: "Stretch for 2 mins", tags: ["exercise"],
                            color: "#FFA500", completed: false, declined: false, rating: nil)
        ]
        
        saveTasksToFirestore(newTasks)
        self.tasks = newTasks
    }
    
    func saveTasksToFirestore(_ tasks: [RecommendedTask]) {
        let ref = db.collection("users").document(userId)
                     .collection("recommendations").document("active")
        do {
            let tasksData = try tasks.map { task -> [String: Any] in
                let encoded = try JSONEncoder().encode(task)
                return try JSONSerialization.jsonObject(with: encoded) as? [String: Any] ?? [:]
            }
            ref.setData(["tasks": tasksData], merge: true)
        } catch {
            print("Error encoding tasks: \(error)")
        }
    }
    
    func completeTask(_ task: RecommendedTask, rating: Int?) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].completed = true
        tasks[index].rating = rating
        
        // Update Firestore
        saveTasksToFirestore(tasks)
        
        checkAllTasksCompletion()
        
        // If rating >= 4, we can store "user enjoyed" data in ML logs
        if let r = rating, r >= 4 {
            // Mark for ML or do not show again if rating < x
        }
    }
    
    func declineTask(_ task: RecommendedTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].declined = true
        
        // Option 1: Remove from list
        tasks.remove(at: index)
        
        // Option 2: Replace with a new recommended task
        if tasks.count < 3 {
            // fetch new single recommendation from ML
        }
        
        saveTasksToFirestore(tasks)
    }
    
    func checkAllTasksCompletion() {
        let allCompleted = tasks.allSatisfy { $0.completed || $0.declined }
        if allCompleted && !tasks.isEmpty {
            // show completion screen
            showCompletionScreen = true
            
            // Possibly award a badge
            showBadge = true
            
            // Then fetch new tasks from the model
            fetchFromModelIfEligible()
        }
    }
    
    private func userCompletedAssessment() -> Bool {
        // Check user profile docs or quizzes
        // Return true if they've done at least 1
        return true // example
    }
}


import SwiftUI

struct RecommendedActionsSection: View {
    @ObservedObject var viewModel: RecommendationsViewModel
    @EnvironmentObject var AuthViewModel: AuthViewModel // Added viewModel as an environment object

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended Actions")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
                .padding(.leading)
            
            if viewModel.tasks.isEmpty {
                // If no tasks available, show placeholder or "Intro to Profiles"
                introToProfilesView
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.tasks.prefix(3)) { task in
                            RecommendationCard(
                                task: task,
                                onComplete: { rating in
                                    viewModel.completeTask(task, rating: rating)
                                },
                                onDecline: {
                                    viewModel.declineTask(task)
                                }
                            )
                            .frame(width: 250, height: 160)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .sheet(isPresented: $viewModel.showCompletionScreen) {
            CompletionSheet(showBadge: $viewModel.showBadge)
        }
    }
    
    private var introToProfilesView: some View {
        VStack {
            Text("Complete an assessment to get personalized tasks.")
                .font(.subheadline)
            Button("Explore Assessments") {
                // navigate to profiles or progress page
            }
            .padding(.top, 4)
        }
        .padding()
    }
}


struct RecommendationCard: View {
    let task: RecommendedTask
    let onComplete: (Int?) -> Void
    let onDecline: () -> Void
    
    @State private var rating: Int = 5
    @State private var showRating = false
    
    var body: some View {
        ZStack {
            color(for: task.type)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(task.description)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if showRating {
                    HStack {
                        Picker("Rating", selection: $rating) {
                            ForEach(1..<6) { val in
                                Text("\(val)").tag(val)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 120)
                        
                        Button(action: {
                            onComplete(rating)
                            showRating = false
                        }) {
                            Text("Done")
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                        }
                    }
                } else {
                    HStack {
                        Button(action: {
                            onDecline()
                        }) {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                        Spacer()
                        Button(action: {
                            // show rating controls
                            showRating = true
                        }) {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private func color(for type: String) -> Color {
        switch type {
        case "relaxation": return Color.blue.opacity(0.8)
        case "journaling": return Color.green.opacity(0.8)
        case "movement":   return Color.orange.opacity(0.8)
        default: return Color.purple.opacity(0.8)
        }
    }
}


struct CompletionSheet: View {
    @Binding var showBadge: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("All Tasks Completed!")
                .font(.title2)
                .fontWeight(.bold)
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            if showBadge {
                Text("You've earned a new badge!")
                    .font(.headline)
            }
            
            Text("Great job! Check back soon for new recommendations.")
                .font(.subheadline)
            
            Button("Done") {
                // Dismiss
                // Could use Environment(\.presentationMode).wrappedValue.dismiss()
            }
            .padding(.top, 8)
        }
        .padding()
    }
}

struct RatingSheet: View {
    let action: RecommendedAction
    
    // 1 to 5 rating
    @State private var rating: Int = 5
    var onSubmitRating: (Int) -> Void
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("How helpful was '\(action.description)'?")
                    .font(.headline)
                    .padding()
                
                // Example simple 1..5 rating
                Picker("Rating", selection: $rating) {
                    ForEach(1..<6) { value in
                        Text("\(value)")
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Button("Submit") {
                    onSubmitRating(rating)
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .navigationTitle("Rate Task")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}


struct RecommendedActionSection: View {
    // Example: If you want to show multiple recommended tasks,
    // you could store them in an array and use a ScrollView or TabView.
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text("Recommended Action")
                        .font(.headline)
                    
                    Text("“Take 5 deep breaths for relaxation.”")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            
            // Action Button
            Button(action: {
                // Handle "Start Breathing Exercise" or other task start
            }) {
                Text("Start")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color("CardBackground")) // Use a named color or .white
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding(.horizontal)
    }
}


