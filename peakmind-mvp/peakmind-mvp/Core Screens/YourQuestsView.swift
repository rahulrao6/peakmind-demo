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
        "b0e8ff",  // Green
        "1a82b3",  // Orange
        "00b4ff",  // Blue
        "2262f5",  // Pink
        "122352"   // Purple
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
        case "DailyCheckin": return "Check-in Champion"
        case "Habits": return "Habit Hero"
        case "Routine": return "Routine Builder"
        case "RoutineCompletion": return "Routine Streak Master"
        default: return baseName
        }
    }
    
    var subtitle: String {
        switch baseName {
        case "Profiles": return "Take \(nextSegmentGoal) Profile Quizzes"
        case "Games": return "Complete \(nextSegmentGoal) Game Modules"
        case "Journal": return "Complete \(nextSegmentGoal) Journal Entries"
        case "Chat": return "Have \(nextSegmentGoal) Conversations with Sherpa"
        case "Habits": return "Complete \(nextSegmentGoal) Habits in a Routine"
        case "Routine": return "Build \(nextSegmentGoal) Routines"
        case "DailyCheckin": return "Maintain a streak for \(nextSegmentGoal) days"
        case "RoutineCompletion": return "Complete routines for \(nextSegmentGoal) consecutive days"
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
    @State private var showPointsAndBadgesView = false // State to control navigation
    @EnvironmentObject var viewModel: AuthViewModel // Inject the AuthViewModel

    var body: some View {
        NavigationView {
            ZStack {
                // Background with Linear Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "112864")!, Color(hex: "23429a")!]),
                    startPoint: .top,
                    endPoint: .bottom
                )
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
                    Spacer()
                }
                
                // Reward Popup - only appears after tapping to claim
                if showRewardPopup {
                    ZStack {
                        // Background overlay
                        Color.black.opacity(0.7).edgesIgnoringSafeArea(.all)
                        
                        // Base reward popup image that covers the entire screen
                        Image("RewardPopup")
                            .resizable()
                            .scaledToFit()
                            .edgesIgnoringSafeArea(.all) // Make sure the image covers the full screen
                        
                        // Overlay +150 text, PeakCoin image, and Claim button
                        VStack(spacing: 30) {
                            
                            // +150 and PeakCoin overlay positioned using y-offset
                            HStack {
                                Text("+150")
                                    .font(.custom("SFProText-Bold", size: 45)) // Font size for +150
                                    .foregroundColor(.white)
                                
                                Image("PeakCoin")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 55, height: 55) // Adjust size as needed
                            }
                            .offset(y: -20) // Adjust Y-offset for precise positioning of +150 and PeakCoin
                            
                            
                            // Claim button on top of the image asset, positioned using y-offset
                            Button(action: {
                                // Claim reward and move to the next segment
                                if let quest = selectedQuest {
                                    viewModel.claimReward(for: quest.id ?? "")
                                }
                                showRewardPopup = false
                            }) {
                                Text("Claim")
                                    .font(.custom("SFProText-Bold", size: 24)) // Button font size
                                    .foregroundColor(.white)
                                    .padding(.vertical, 18) // Reduced vertical padding to make the button less tall
                                    .padding(.horizontal, 55) // Adjust horizontal padding to make it less wide
                                    .background(Color(hex: "03182c")!) // Button background color
                                    .cornerRadius(10) // Rounded corners for the button
                            }
                            .frame(width: 220) // Set a specific width to make the button less wide
                            .offset(y: -0) // Adjust Y-offset to position the button precisely

                        }
                    }
                }

            }
            .onAppear {
                Task {
                    await viewModel.fetchQuestData()
                }
                print(viewModel.quests)
                viewModel.checkAndSyncQuests()

            }
            .onDisappear {
                viewModel.removeListener()
            }
            .overlay(
                HStack {
                    Spacer()
                    VStack {
                        Button(action: {
                            showPointsAndBadgesView = true // Set to true to navigate to PointsAndBadgesView
                        }) {
                            Image("PeakCoin") // Use custom image asset instead of system star icon
                                 .resizable() // Make the image resizable to control its size
                                 .aspectRatio(contentMode: .fit)
                                 .frame(width: 42, height: 42) // Adjust the size of the image
                                 .padding(5) // Add padding around the image
                                 .background(Color.black) // Black circle background
                                 .clipShape(Circle())
                        }
                        .padding(.top, 40)
                        Spacer()
                    }
                    .padding(.trailing, 20)
                }
            )
            .navigationBarHidden(true)
            .sheet(isPresented: $showPointsAndBadgesView) {
                PointsAndBadgesView() // Navigate to the PointsAndBadgesView
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


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
                    .padding(.top, 5)
                
                // Subtitle for current segment
                Text(quest.subtitle)
                    .font(.custom("SFProText-Bold", size: 16))
                    .foregroundColor(.gray)
                    .lineLimit(nil) // Allow unlimited lines
                    .multilineTextAlignment(.leading) // Align text to the left

                // Yellow stars to indicate current phase
                HStack {
                    ForEach(0..<quest.totalSegments.count, id: \.self) { index in
                        Image(systemName: index < quest.totalSegments.count && (index < quest.totalSegments.firstIndex(of: quest.nextSegmentGoal) ?? quest.totalSegments.count || quest.currentProgress >= quest.totalSegments.last!) ? "star.fill" : "star")
                            .foregroundColor(index < quest.totalSegments.count && (index < quest.totalSegments.firstIndex(of: quest.nextSegmentGoal) ?? quest.totalSegments.count || quest.currentProgress >= quest.totalSegments.last!) ? Color.yellow : Color.gray)
                    }
                }

                // Progress Text (e.g., 3/10) moved up above Spacer
                HStack {
                    Spacer()
                    Text(quest.segmentDetails)
                        .font(.custom("SFProText-Bold", size: 16))
                        .foregroundColor(.gray)
                }
                
                Spacer() // Spacer ensures the progress bar stays at the bottom
            }
            .padding()
            .frame(height: 150) // Card height
            // Set background to gold if ALL segments are completed, else use #122352
            .background(quest.currentProgress >= quest.totalSegments.last! ? Color(hex: "2a0068") : Color(hex: "122352"))
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
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
        // Apply the glow effect to the entire card (ZStack), not to individual elements
        .shadow(color: quest.canClaimReward ? Color.white.opacity(0.44) : Color.clear, radius: 8, x: 0, y: 0)
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
                        LinearGradient(gradient: Gradient(colors: [Color(hex: "00ebf4")!, Color(hex: "0090ff")!, Color(hex: "2067a8")!]), startPoint: .leading, endPoint: .trailing)
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

// MARK: - Preview

struct QuestView_Previews: PreviewProvider {
    static var previews: some View {
        YourQuestsView()
    }
}
