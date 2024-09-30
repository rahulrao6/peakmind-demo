import SwiftUI

// Quest Model with progress and segment management
// Quest Model with progress and segment management
struct Quest: Identifiable {
    let id = UUID()
    var baseName: String
    var currentProgress: Int
    var nextSegmentGoal: Int
    var totalSegments: [Int]
    
    // Define colors for each segment depth
    var segmentColors: [Color] = [
        Color(hex: "4CAF50")!,  // Green
        Color(hex: "FF9800")!,  // Orange
        Color(hex: "2196F3")!,  // Blue
        Color(hex: "E91E63")!,  // Pink
        Color(hex: "9C27B0")!   // Purple
    ]
    
    // Dynamically updates the quest title
    var title: String {
        switch baseName {
        case "First Task": return "Quiz Master"
        case "Second Task": return "Game Guru"
        case "Third Task": return "Journal Jedi"
        case "Fourth Task": return "Sherpa Whisperer"
        case "Fifth Task": return "Habit Hero"
        case "Sixth Task": return "Routine Builder"
        default: return baseName
        }
    }
    
    var subtitle: String {
        switch baseName {
        case "First Task": return "Take \(nextSegmentGoal) Profile Quizzes"
        case "Second Task": return "Complete \(nextSegmentGoal) Game Modules"
        case "Third Task": return "Complete \(nextSegmentGoal) Journal Entries"
        case "Fourth Task": return "Have \(nextSegmentGoal) Conversations with AI Companion"
        case "Fifth Task": return "Complete \(nextSegmentGoal) Habits in a Routine"
        case "Sixth Task": return "Build \(nextSegmentGoal) Routines"
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
        }
    }
}

struct YourQuestsView: View {
    
    @State private var quests: [Quest] = [
        Quest(baseName: "First Task", currentProgress: 1, nextSegmentGoal: 3, totalSegments: [1, 3, 10, 20, 40]),
        Quest(baseName: "Second Task", currentProgress: 5, nextSegmentGoal: 25, totalSegments: [5, 25, 50, 150, 400]),
        Quest(baseName: "Third Task", currentProgress: 10, nextSegmentGoal: 30, totalSegments: [10, 30, 60, 100, 250]),
        Quest(baseName: "Fourth Task", currentProgress: 3, nextSegmentGoal: 10, totalSegments: [3, 10, 20, 40, 100]),
        Quest(baseName: "Fifth Task", currentProgress: 5, nextSegmentGoal: 20, totalSegments: [5, 20, 50, 100, 250]),
        Quest(baseName: "Sixth Task", currentProgress: 1, nextSegmentGoal: 3, totalSegments: [1, 3, 5, 10, 20])
    ]
    
    @State private var showRewardPopup = false
    @State private var selectedQuest: Quest?
    @State private var showPointsAndBadgesView = false // State to control navigation
    
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
                        ForEach($quests) { $quest in
                            QuestCardView(quest: $quest, showRewardPopup: $showRewardPopup, selectedQuest: $selectedQuest)
                        }
                    }
                    
                    // Increment Button for Testing
                    Button(action: {
                        for index in quests.indices {
                            quests[index].incrementProgress() // Just increment the progress
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
                                if let selectedQuestIndex = quests.firstIndex(where: { $0.id == selectedQuest?.id }) {
                                    quests[selectedQuestIndex].claimReward()
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
            .overlay(
                HStack {
                    Spacer()
                    VStack {
                        Button(action: {
                            showPointsAndBadgesView = true // Set to true to navigate to PointsAndBadgesView
                        }) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 20)) // Smaller button
                                .foregroundColor(.yellow) // Yellow star
                                .padding(10) // Reduced padding
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

// Quest Card View with glow effect when segment is claimable
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
                alignment: .bottom // Make sure the progress bar is at the very bottom
            )
            // Add white glow effect if segment can be claimed
            .shadow(color: quest.canClaimReward ? Color.white.opacity(0.8) : Color.clear, radius: 10, x: 0, y: 0)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}



// Corner Radius Modifier for bottom corners only
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

// Preview
struct QuestView_Previews: PreviewProvider {
    static var previews: some View {
        YourQuestsView()
    }
}
