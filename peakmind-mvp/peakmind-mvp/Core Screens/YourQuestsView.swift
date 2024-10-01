//
//  NewQuestView.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 9/30/24.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestoreSwift

// MARK: - Quest Model

struct Quest: Identifiable, Codable {
    @DocumentID var id: String?  // Firebase document ID
    var baseName: String
    var currentProgress: Int
    var nextSegmentGoal: Int
    var totalSegments: [Int]
    
    // Check progress for a specific quest type
    
    
    
    // Since colors and computed properties are not stored in Firebase, they remain unchanged.
    
    // Define colors for each segment depth (hex strings)
    var segmentColorHexes: [String] = [
        "4CAF50",  // Green
        "FF9800",  // Orange
        "2196F3",  // Blue
        "E91E63",  // Pink
        "9C27B0"   // Purple
    ]
    
    // Computed property to get Color from hex
    var segmentColors: [Color] {
        segmentColorHexes.compactMap { Color(hex: $0) }
    }
    
    // Dynamically updates the quest title
    var title: String {
        switch baseName {
        case "Profiles": return "Quiz Master"
        case "Games": return "Game Guru"
        case "Journal": return "Journal Jedi"
        case "Chat": return "Sherpa Whisperer"
        case "Habits": return "Habit Hero"
        case "Routine": return "Routine Builder"
        default: return baseName
        }
    }
    
    var subtitle: String {
        switch baseName {
        case "Profiles": return "Take \(nextSegmentGoal) Profile Quizzes"
        case "Games": return "Complete \(nextSegmentGoal) Game Modules"
        case "Journal": return "Complete \(nextSegmentGoal) Journal Entries"
        case "Chat": return "Have \(nextSegmentGoal) Conversations with AI Companion"
        case "Habits": return "Complete \(nextSegmentGoal) Habits in a Routine"
        case "Routine": return "Build \(nextSegmentGoal) Routines"
        default: return baseName
        }
    }
    
    var segmentDetails: String {
        return "\(currentProgress)/\(nextSegmentGoal)"
    }
    
    var progressPercentage: CGFloat {
        CGFloat(currentProgress) / CGFloat(nextSegmentGoal)
    }
    
    // Select a color based on current depth
    var currentSegmentColor: Color {
        let index = min(totalSegments.firstIndex(of: nextSegmentGoal) ?? 0, segmentColors.count - 1)
        return segmentColors[index]
    }
    
    // Check if the user can claim a reward for the current segment
    var canClaimReward: Bool {
        currentProgress >= nextSegmentGoal
    }
    
    // Move to the next segment
    mutating func incrementProgress() -> Bool {
        currentProgress += 1
        if currentProgress >= nextSegmentGoal {
            return true // Indicates that the segment has been completed
        }
        return false
    }
    
    // Move to the next segment goal after reward is claimed
    mutating func claimReward() {
        if let nextGoalIndex = totalSegments.firstIndex(of: nextSegmentGoal),
           nextGoalIndex + 1 < totalSegments.count {
            nextSegmentGoal = totalSegments[nextGoalIndex + 1]
            currentProgress = 0 // Reset progress for the new segment
        }
    }
}


// MARK: - YourQuestsView

struct YourQuestsView: View {
    @State private var showRewardPopup = false
    @State private var selectedQuest: Quest?
    @EnvironmentObject var viewModel: AuthViewModel // Inject the AuthViewModel

    var body: some View {
        NavigationView {
            ZStack {
                // Background with Linear Gradient
                LinearGradient(gradient: Gradient(colors: [Color(hex: "452198")!, Color(hex: "1a1164")!]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Page title
                    Text("Your Quests")
                        .font(.custom("SFProText-Heavy", size: 34))
                        .foregroundColor(.white)
                        .padding(.top, 50)
                        .padding(.leading, 20)
                    
                    // Quest list
                    ScrollView {
                        ForEach($viewModel.quests) { $quest in
                            QuestCardView(quest: $quest, showRewardPopup: $showRewardPopup, selectedQuest: $selectedQuest)
                        }
                    }
                    
                    // Remove or keep the Increment Button for Testing
                    Button(action: {
                        for quest in viewModel.quests {
                            viewModel.incrementProgress(for: quest.id ?? "")
                        }
                    }) {
                        Text("Increment All")
                            .font(.custom("SFProText-Bold", size: 18))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "ca4c73")!)
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
                
                // Reward Popup - only appears after tapping to claim
                if showRewardPopup {
                    ZStack {
                        Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                        
                        VStack(spacing: 20) {
                            Text("Congratulations!")
                                .font(.custom("SFProText-Heavy", size: 24))
                                .foregroundColor(.white)
                            
                            Text("You completed a segment of \(selectedQuest?.title ?? "your quest")!")
                                .font(.custom("SFProText-Bold", size: 18))
                                .foregroundColor(.white)
                            
                            Button(action: {
                                // Claim reward and move to next segment
                                if let quest = selectedQuest {
                                    viewModel.claimReward(for: quest.id ?? "")
                                }
                                showRewardPopup = false
                            }) {
                                Text("Claim")
                                    .font(.custom("SFProText-Bold", size: 18))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(hex: "ca4c73")!)
                                    .cornerRadius(10)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding()
                        .background(Color(hex: "180b53")!)
                        .cornerRadius(15)
                        .frame(maxWidth: 300)
                    }
                }
            }
            .onAppear {
                viewModel.fetchQuestData()
                print(viewModel.quests)
                viewModel.checkAndSyncQuests()

            }
            .onDisappear {
                viewModel.removeListener()
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - QuestCardView

struct QuestCardView: View {
    @Binding var quest: Quest
    @Binding var showRewardPopup: Bool
    @Binding var selectedQuest: Quest?
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: 10) {
                // Quest Title
                Text(quest.title)
                    .font(.custom("SFProText-Heavy", size: 24))
                    .foregroundColor(.white)
                
                // Subtitle for current segment
                Text(quest.subtitle)
                    .font(.custom("SFProText-Bold", size: 16))
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Progress Text (e.g., 3/10)
                HStack {
                    Spacer()
                    Text(quest.segmentDetails)
                        .font(.custom("SFProText-Bold", size: 16))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(height: 150) // Card height
            .background(quest.currentSegmentColor.opacity(0.5))
            .cornerRadius(12)
            .onTapGesture {
                if quest.canClaimReward {
                    selectedQuest = quest
                    showRewardPopup = true
                }
            }
            .overlay(
                // Overlay the progress bar at the bottom
                QuestProgressBar(progress: quest.progressPercentage)
                    .frame(height: 20) // Thin progress bar
                    .cornerRadius(12, corners: [.bottomLeft, .bottomRight]),
                alignment: .bottom // Ensure the progress bar is at the very bottom
            )
            // Add white glow effect if segment can be claimed
            .shadow(color: quest.canClaimReward ? Color.white.opacity(0.8) : Color.clear, radius: 10, x: 0, y: 0)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

// MARK: - QuestProgressBar

struct QuestProgressBar: View {
    var progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Progress Bar with Sunset Gradient
                RoundedRectangle(cornerRadius: 0) // No corner radius since it's at the bottom
                    .fill(
                        LinearGradient(gradient: Gradient(colors: [Color(hex: "ff758c")!, Color(hex: "ff7eb3")!, Color(hex: "ffae88")!]), startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: geometry.size.width * progress, height: geometry.size.height) // Fill the height
            }
        }
    }
}

// MARK: - Corner Radius Modifier

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Color Extension

//extension Color {
//    init?(hex: String) {
//        let r, g, b: Double
//
//        var hexColor = hex
//        if hex.hasPrefix("#") {
//            hexColor = String(hex.dropFirst())
//        }
//
//        guard let intCode = Int(hexColor, radix: 16) else {
//            return nil
//        }
//
//        r = Double((intCode >> 16) & 0xFF) / 255.0
//        g = Double((intCode >> 8) & 0xFF) / 255.0
//        b = Double(intCode & 0xFF) / 255.0
//
//        self.init(red: r, green: g, blue: b)
//    }
//}

// MARK: - Preview

struct QuestView_Previews: PreviewProvider {
    static var previews: some View {
        YourQuestsView()
    }
}
