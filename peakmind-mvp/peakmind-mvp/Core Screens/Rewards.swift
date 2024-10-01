
import SwiftUI

// 1. Update the Badge model
struct Badge: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let imageURL: String
    var dateEarned: Date?
    let pointsRequired: Int
    let levelRequired: Int

    static func == (lhs: Badge, rhs: Badge) -> Bool {
        return lhs.id == rhs.id
    }
    
    var isUnlocked: Bool {
        return dateEarned != nil
    }
}

struct PointEntry: Identifiable, Codable {
    let id: String
    let userId: String
    let date: Date
    let points: Int
    let reason: String
}

// Predefined list of all possible badges
let allBadges = [
    Badge(id: "1", name: "Bronze Badge", description: "Achieve 1000 points", imageURL: "bronzeBadge", dateEarned: nil, pointsRequired: 1000, levelRequired: 1),
    Badge(id: "2", name: "Silver Badge", description: "Achieve 2000 points", imageURL: "silverBadge", dateEarned: nil, pointsRequired: 2000, levelRequired: 2),
    Badge(id: "3", name: "Gold Badge", description: "Achieve 3000 points", imageURL: "goldBadge", dateEarned: nil, pointsRequired: 3000, levelRequired: 3),
    Badge(id: "4", name: "Diamond Badge", description: "Achieve 4000 points", imageURL: "diamondBadge", dateEarned: nil, pointsRequired: 4000, levelRequired: 4)
]
// PointsAndBadgesView.swift

struct PointsAndBadgesView: View {
    @State private var pointsHistory: [PointEntry] = []
    @State private var badges: [Badge] = []
    @State private var totalPoints: Int = 0
    @State private var currentLevel: Int = 6 // Set default level to 6 for demonstration
    @State private var isLoading: Bool = true

    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Placeholder Box with Edit Button
                    ZStack(alignment: .topTrailing) {
                        Rectangle()
                            .fill(Color.white.opacity(0.1)) // Placeholder box color
                            .frame(width: 150, height: 150)
                            .cornerRadius(10)
                        
                        Button(action: {
                            // Action for edit button
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    .padding(.top)

                    if isLoading {
                        ProgressView("Loading your rewards...")
                            .foregroundColor(.white)
                    } else {
                        // User Stats Section
                        UserStatsView(totalPoints: totalPoints, currentLevel: currentLevel)
                            .foregroundColor(.white)

                        // Badges Section
                        BadgesGridView(badges: badges, totalPoints: totalPoints, currentLevel: currentLevel)

                        // Points History Section
                        PointsHistoryView(pointsHistory: pointsHistory)
                    }
                }
                .padding()
            }
            .background(Color(hex: "0d2c7b").ignoresSafeArea()) // Setting the background color
            .navigationBarTitle("Rewards", displayMode: .large)
            .onAppear {
                loadData()
            }
        }
    }

    func loadData() {
        Task {
            do {
                isLoading = true

                // Fetch points data
                let pointsData = try await viewModel.getPointsData()
                self.pointsHistory = pointsData.pointsHistory
                self.totalPoints = pointsData.totalPoints

                // Fetch current level
                self.currentLevel = try await viewModel.getCurrentLevel()

                // Fetch badges
                let earnedBadges = try await viewModel.getBadges()

                // Merge badges
                self.badges = mergeBadges(earnedBadges: earnedBadges)

                // Check and award new badges
                try await viewModel.checkAndAwardBadges(totalPoints: totalPoints, currentLevel: currentLevel, earnedBadges: earnedBadges)
                
                isLoading = false
            } catch {
                print("Failed to load data: \(error.localizedDescription)")
                isLoading = false
            }
        }
    }

    func mergeBadges(earnedBadges: [Badge]) -> [Badge] {
        return viewModel.allBadges.map { badge in
            if let earnedBadge = earnedBadges.first(where: { $0.id == badge.id }) {
                var updatedBadge = badge
                updatedBadge.dateEarned = earnedBadge.dateEarned
                return updatedBadge
            } else {
                return badge
            }
        }
    }
}

// MARK: - User Stats View

struct UserStatsView: View {
    let totalPoints: Int
    let currentLevel: Int
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Level \(currentLevel)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white) // Text color white
            Text("\(totalPoints) Points")
                .font(.headline)
                .foregroundColor(.white) // Text color white
            ProgressView(value: Float(totalPoints % 1000), total: 1000)
                .progressViewStyle(LinearProgressViewStyle(tint: .white))
            Text("\(1000 - (totalPoints % 1000)) points to next level")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7)) // Caption color white with opacity
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Badges Grid View

struct BadgesGridView: View {
    let badges: [Badge]
    let totalPoints: Int
    let currentLevel: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Badges")
                .font(.headline)
                .foregroundColor(.white) // Text color white
                .padding(.leading)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                ForEach(badges) { badge in
                    NavigationLink(destination: BadgeDetailView(badge: badge, totalPoints: totalPoints, currentLevel: currentLevel)) {
                        BadgeView(badge: badge, totalPoints: totalPoints, currentLevel: currentLevel)
                    }
                }
            }
            .padding()
        }
    }
}
// BadgeDetailView.swift

struct BadgeDetailView: View {
    let badge: Badge
    let totalPoints: Int
    let currentLevel: Int

    var body: some View {
        VStack(spacing: 20) {
            Image(badgeImageName(for: badge))
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .opacity(badge.dateEarned != nil ? 1 : 0.5)

            Text(badge.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white) // Text color white

            Text(badge.description)
                .multilineTextAlignment(.center)
                .foregroundColor(.white) // Text color white
                .padding()

            if badge.dateEarned == nil {
                VStack {
                    Text("Requirements:")
                        .font(.headline)
                        .foregroundColor(.white) // Text color white
                    Text("Points: \(badge.pointsRequired)")
                        .foregroundColor(.white) // Text color white
                    Text("Level: \(badge.levelRequired)")
                        .foregroundColor(.white) // Text color white
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                if totalPoints >= badge.pointsRequired && currentLevel >= badge.levelRequired {
                    Text("You've met the requirements for this badge!")
                        .foregroundColor(.green)
                        .fontWeight(.bold)
                } else {
                    Text("Keep playing to unlock this badge!")
                        .foregroundColor(.white.opacity(0.7)) // Text color white with opacity
                }
            } else {
                Text("Unlocked on \(badge.dateEarned?.formatted(date: .long, time: .shortened) ?? "Unknown Date")")
                    .foregroundColor(.white.opacity(0.7)) // Text color white with opacity
            }
        }
        .padding()
        .navigationBarTitle("Badge Details", displayMode: .inline)
        .background(Color(hex: "0d2c7b").ignoresSafeArea()) // Background color
    }

    func badgeImageName(for badge: Badge) -> String {
        if badge.name.contains("Bronze") {
            return "bronzeBadge"
        } else if badge.name.contains("Silver") {
            return "silverBadge"
        } else if badge.name.contains("Gold") {
            return "goldBadge"
        } else if badge.name.contains("Diamond") {
            return "diamondBadge"
        } else {
            return "defaultBadge" // Make sure to add a default badge image
        }
    }
}

struct BadgeView: View {
    let badge: Badge
    let totalPoints: Int
    let currentLevel: Int
    
    var body: some View {
        VStack {
            if totalPoints >= badge.pointsRequired && currentLevel >= badge.levelRequired {
                Image(badgeImageName(for: badge))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                
            } else {
                Color.gray
                    .frame(width: 80, height: 80)
                    .cornerRadius(10)
                    .overlay(
                        Text("?")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    )
            }
            Text(badge.name)
                .font(.caption)
                .foregroundColor(.white) // Text color white
                .multilineTextAlignment(.center)
        }
    }
    
    func badgeImageName(for badge: Badge) -> String {
        if badge.name.contains("Bronze") {
            return "bronzeBadge"
        } else if badge.name.contains("Silver") {
            return "silverBadge"
        } else if badge.name.contains("Gold") {
            return "goldBadge"
        } else if badge.name.contains("Diamond") {
            return "diamondBadge"
        } else {
            return "defaultBadge" // Make sure to add a default badge image
        }
    }
}

// MARK: - Points History View

struct PointsHistoryView: View {
    let pointsHistory: [PointEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Points History")
                .font(.headline)
                .foregroundColor(.white) // Text color white
                .padding(.leading)
            
            ForEach(pointsHistory) { entry in
                HStack {
                    VStack(alignment: .leading) {
                        Text(entry.reason)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white) // Text color white
                        Text(entry.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7)) // Caption color white with opacity
                    }
                    Spacer()
                    Text("+\(entry.points)")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .padding(.horizontal)
                Divider().background(Color.white)
            }
        }
        .padding(.top)
    }
}


// MARK: - Preview

struct Rewards_Previews: PreviewProvider {
    static var previews: some View {
        PointsAndBadgesView().environmentObject(AuthViewModel())
    }
}
