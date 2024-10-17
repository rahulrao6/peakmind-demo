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

// AvatarView
struct AvatarView: View {
    @State private var isCustomizing: Bool = false // State to trigger navigation to customization hub
    @State private var selectedAssets: [String: String] = [:] // Store the selected assets
    @EnvironmentObject var viewModel: AuthViewModel // Access the view model to fetch avatar data
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                Image("SampleIgloo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 350, height: 350)
                    .cornerRadius(10)
                
                ZStack {
                    Image(selectedAssets["Pants"] ?? "SamplePants")
                        .resizable()
                        .scaledToFit()
                    Image(selectedAssets["Coat"] ?? "SampleCoat")
                        .resizable()
                        .scaledToFit()
                    Image(selectedAssets["Head"] ?? "SampleHead")
                        .resizable()
                        .scaledToFit()
                    Image(selectedAssets["Beanie"] ?? "SampleBeanie")
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 350, height: 350)
            }
            .frame(width: 350, height: 350)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            
            // Edit button
            Button(action: {
                isCustomizing = true
            }) {
                Image(systemName: "gearshape.fill")
                    .resizable()
                    .frame(width: 22, height: 22)  // Slightly reduce the gear size to fit better
                    .foregroundColor(.iceBlue)  // Set gear icon to white
                    .padding(10)  // Add padding to create space between the gear and the background
                    .background(Color.navyBlue)  // Set background circle to black
                    .clipShape(Circle())  // Clip the background to a circle
            }
            .padding()

        }
        .onAppear {
            Task {
                do {
                    if let fetchedAssets = try await viewModel.fetchAvatarCustomization() {
                        self.selectedAssets = fetchedAssets
                    } else {
                        print("No avatar customization found")
                    }
                } catch {
                    print("Error fetching avatar customization: \(error.localizedDescription)")
                }
            }
        }
        .fullScreenCover(isPresented: $isCustomizing) {
            AvatarCustomizationView(isCustomizing: $isCustomizing, selectedAssets: $selectedAssets)
        }
    }
}

struct AvatarCustomizationView: View {
    @Binding var isCustomizing: Bool // Binding to go back to the previous view
    @EnvironmentObject var viewModel: AuthViewModel // Access the view model for saving
    @State private var expandedGroup: String? = nil
    @Binding var selectedAssets: [String : String]
    
    var body: some View {
        ZStack {
            Color(hex: "0d2c7b")
                .ignoresSafeArea()

            VStack {
                // Avatar display remains fixed at the top
                ZStack {
                    Image("SampleIgloo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250) // Fixed size for avatar preview
                        .cornerRadius(10)

                    ZStack {
                        Image(selectedAssets["Pants"] ?? "SamplePants")
                            .resizable()
                            .scaledToFit()
                        Image(selectedAssets["Coat"] ?? "SampleCoat")
                            .resizable()
                            .scaledToFit()
                        Image(selectedAssets["Head"] ?? "SampleHead")
                            .resizable()
                            .scaledToFit()
                        Image(selectedAssets["Beanie"] ?? "SampleBeanie")
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(width: 250, height: 250) // Fixed size for avatar parts
                }
                .frame(width: 250, height: 250)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding()

                // Scrollable customization categories
                ScrollView {
                    Text("Customize Your Avatar")
                        .font(.custom("SFProText-Heavy", size: 24)) // Set custom font SFProText-Heavy
                        .foregroundColor(.white) // White text to match the background
                        .padding(.bottom, 20)

                    // Customization Categories as expandable sections
                    VStack(spacing: 20) {
                        CustomizationCategoryView(category: "Beanie", expandedGroup: $expandedGroup, selectedAssets: $selectedAssets)
                        Divider().background(Color.white) // Divider between categories
                        CustomizationCategoryView(category: "Head", expandedGroup: $expandedGroup, selectedAssets: $selectedAssets)
                        Divider().background(Color.white) // Divider between categories
                        CustomizationCategoryView(category: "Coat", expandedGroup: $expandedGroup, selectedAssets: $selectedAssets)
                        Divider().background(Color.white) // Divider between categories
                        CustomizationCategoryView(category: "Pants", expandedGroup: $expandedGroup, selectedAssets: $selectedAssets)
                    }
                    .padding()
                }
                .frame(maxHeight: .infinity) // Allow ScrollView to grow without affecting the avatar preview
                Button(action: {
                    Task {
                        do {
                            try await viewModel.saveAvatarCustomization(selectedAssets: selectedAssets)
                            isCustomizing = false // Close customization view
                        } catch {
                            print("Error saving avatar customization: \(error.localizedDescription)")
                        }
                    }
                }) {
                    Text("Done")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "000722")!)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
    }
}

struct CustomizationCategoryView: View {
    let category: String
    @Binding var expandedGroup: String?
    @Binding var selectedAssets: [String: String] // Bind to store the selected asset for each category

    @State private var isColorSelected: Bool = false // Tracks if color has been selected
    @State private var selectedColor: String? = nil  // Tracks selected color for variation display

    var body: some View {
        DisclosureGroup(
            isExpanded: Binding<Bool>(
                get: { expandedGroup == category },
                set: { isExpanded in expandedGroup = isExpanded ? category : nil }
            )
        ) {
            if category == "Head" {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(1...10, id: \.self) { index in
                            let assetName = headAssetName(for: index) // Get the corresponding asset name
                            
                            Circle()
                                .fill(selectedAssets[category] == assetName ? Color.green : Color.clear) // Fill the circle when selected
                                .frame(width: 40, height: 40) // Circle size for head variations
                                .overlay(Text("\(index)").foregroundColor(.white)) // Number the circles 1 to 8
                                .overlay( // Stroke border directly on Circle
                                    Circle().stroke(Color.gray, lineWidth: 2)
                                )
                                .onTapGesture {
                                    selectedAssets[category] = assetName // Store the selected head variation
                                }
                        }
                    }
                    .padding(.top, 10)
                }
            } else {
                // Horizontal scrollable color selection
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        // Black color circle (selectable)
                        colorCircle(color: .black, colorName: "Black", selectedColor: $selectedColor, isColorSelected: $isColorSelected)

                        // Locked colors: blue, green, orange, purple, red, white, yellow
                        lockedColorCircle(color: .blue, colorName: "Blue")
                        lockedColorCircle(color: .green, colorName: "Green")
                        lockedColorCircle(color: .orange, colorName: "Orange")
                        lockedColorCircle(color: .purple, colorName: "Purple")
                        lockedColorCircle(color: .red, colorName: "Red")
                        lockedColorCircle(color: .white, colorName: "White")
                        lockedColorCircle(color: .yellow, colorName: "Yellow")
                    }
                    .padding(.top, 10)
                }

                // Show variations for the selected color (e.g., black)
                if isColorSelected {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) { // Smaller circle size for variations
                            ForEach(itemNames(for: category), id: \.self) { item in
                                Circle()
                                    .fill(selectedAssets[category] == item ? Color.green : Color.clear) // Fill the circle when selected
                                    .frame(width: 40, height: 40) // Smaller circle size for variations
                                    .overlay(Text(itemLabel(for: item)).foregroundColor(.white))
                                    .overlay( // Stroke border directly on Circle
                                        Circle().stroke(Color.gray, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        if !item.hasSuffix("3") { // Lock the third variation
                                            selectedAssets[category] = item
                                        }
                                    }
                                    .overlay(
                                        Text(item.hasSuffix("3") ? "🔒" : "")
                                            .foregroundColor(.white) // Display lock emoji for the third variation
                                            .font(.caption)
                                    )
                            }
                        }
                        .padding(.top, 10)
                    }
                }
            }
        } label: {
            HStack {
                Text(category)
                    .font(.custom("SFProText-Heavy", size: 18)) // Set custom font SFProText-Heavy
                    .foregroundColor(.white) // White text to match the background

                Spacer()

                Image(systemName: "chevron.right")
                    .rotationEffect(expandedGroup == category ? .degrees(90) : .degrees(0)) // Rotate arrow when expanded
                    .foregroundColor(.white)
            }
            .padding(.vertical, 10)
        }
    }

    // Helper function to display color selection circle (for the selectable black color)
    private func colorCircle(color: Color, colorName: String, selectedColor: Binding<String?>, isColorSelected: Binding<Bool>) -> some View {
        Circle()
            .fill(color) // Fill with the color passed as argument
            .frame(width: 60, height: 60) // Circle size for color selection
            .overlay( // Show green outline when selected
                Circle()
                    .stroke(selectedColor.wrappedValue == colorName ? Color.green : Color.gray, lineWidth: 2)
            )
            .onTapGesture {
                selectedColor.wrappedValue = colorName
                isColorSelected.wrappedValue = true // Toggle color selection to show variations
            }
    }

    // Helper function to display locked color selection circles
    private func lockedColorCircle(color: Color, colorName: String) -> some View {
        Circle()
            .fill(color)
            .frame(width: 60, height: 60) // Circle size for locked color selection
            .overlay(
                Text("🔒")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            )
            .overlay( // Stroke border around the circle
                Circle()
                    .stroke(Color.gray, lineWidth: 2)
            )
    }

    // Function to return the appropriate items for each category
    func itemNames(for category: String) -> [String] {
        return ["\(selectedColor ?? "Black")\(category)1", "\(selectedColor ?? "Black")\(category)2", "\(selectedColor ?? "Black")3"]
    }

    // Function to return the label for each item (1, 2, 3, etc. for variations)
    func itemLabel(for item: String) -> String {
        if item.hasSuffix("1") {
            return "1"
        } else if item.hasSuffix("2") {
            return "2"
        } else if item.hasSuffix("3") {
            return "3"
        }
        return ""
    }

    // Function to return the correct head asset name based on index
    func headAssetName(for index: Int) -> String {
        switch index {
        case 1:
            return "MaleHead1"
        case 2:
            return "MaleHead2"
        case 3:
            return "MaleHead3"
        case 4:
            return "MaleHead4" // Added MaleHead4
        case 5:
            return "MaleHead5" // Added MaleHead5
        case 6:
            return "FemaleHead1"
        case 7:
            return "FemaleHead2"
        case 8:
            return "FemaleHead3"
        case 9:
            return "FemaleHead4"
        case 10:
            return "FemaleHead5"
        default:
            return ""
        }
    }
}




// PointsAndBadgesView.swift
struct PointsAndBadgesView: View {
    @State private var pointsHistory: [PointEntry] = []
    @State private var badges: [Badge] = []
    @State private var totalPoints: Int = 0
    @State private var currentLevel: Int = 6 // Set default level to 6 for demonstration
    @State private var isLoading: Bool = true

    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        ZStack {
            // Setting the background color to extend through the entire screen
            Color(hex: "0d2c7b")
                .ignoresSafeArea() // Extends to the whole screen
            VStack(alignment: .leading) {
                // Custom Title for Rewards, aligned top left
                Text("Your Rewards")
                    .font(.custom("SFProText-Heavy", size: 30)) // Custom title font
                    .foregroundColor(.white) // White color for title
                    .padding(.leading, 20)
                    .padding(.top, 30) // Add some padding to the top for visibility
                
                // Content aligned centrally
                ScrollView {
                    VStack(spacing: 20) {
                        // Avatar View, centered
                        AvatarView()
                            .frame(maxWidth: .infinity) // Ensures AvatarView stays center aligned
                            .padding(.top, -5)
                        
                        
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
                            PointsHistoryView(pointsHistory: pointsHistory.reversed()) // Reverse the points history
                        }
                    }
                    .padding()
                }
            }
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
                .font(.custom("SFProText-Heavy", size: 26)) // Main title font
                .foregroundColor(.white)
            HStack {
                Text("\(totalPoints)")
                    .font(.custom("SFProText-Bold", size: 18)) // Main points font
                    .foregroundColor(.white)
                
                Image("PeakCoin") // Use the PeakCoin image asset
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24) // Adjust size of the coin image as needed
            }
            ProgressView(value: Float(totalPoints % 1000), total: 1000)
                .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "2788e3")!))
            Text("\(1000 - (totalPoints % 1000)) points to next level")
                .font(.custom("SFProText-Bold", size: 14)) // Secondary text font
                .foregroundColor(.white.opacity(0.7))
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
                .font(.custom("SFProText-Heavy", size: 24)) // Main title font
                .foregroundColor(.white)
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
// Function to map badge names to their respective image asset names
func badgeImageName(for badge: Badge) -> String {
    switch badge.name {
    case "Bronze Badge":
        return "bronzeBadge"
    case "Silver Badge":
        return "silverBadge"
    case "Gold Badge":
        return "goldBadge"
    case "Diamond Badge":
        return "diamondBadge"
    default:
        return "defaultBadge" // A fallback image in case no match is found
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
                .font(.custom("SFProText-Heavy", size: 24)) // Main title font
                .foregroundColor(.white)

            Text(badge.description)
                .font(.custom("SFProText-Bold", size: 18)) // Secondary text font
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding()

            if badge.dateEarned == nil {
                VStack {
                    Text("Requirements:")
                        .font(.custom("SFProText-Heavy", size: 18)) // Main title font
                        .foregroundColor(.white)
                    Text("Points: \(badge.pointsRequired)")
                        .font(.custom("SFProText-Bold", size: 18)) // Secondary text font
                        .foregroundColor(.white)
                    Text("Level: \(badge.levelRequired)")
                        .font(.custom("SFProText-Bold", size: 18)) // Secondary text font
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                if totalPoints >= badge.pointsRequired && currentLevel >= badge.levelRequired {
                    Text("You've met the requirements for this badge!")
                        .font(.custom("SFProText-Bold", size: 18)) // Secondary text font
                        .foregroundColor(.green)
                } else {
                    Text("Keep playing to unlock this badge!")
                        .font(.custom("SFProText-Bold", size: 14)) // Secondary text font
                        .foregroundColor(.white.opacity(0.7))
                }
            } else {
                Text("Unlocked on \(badge.dateEarned?.formatted(date: .long, time: .shortened) ?? "Unknown Date")")
                    .font(.custom("SFProText-Bold", size: 14)) // Secondary text font
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .navigationBarTitle("Badge Details", displayMode: .inline)
        .background(Color(hex: "0d2c7b").ignoresSafeArea()) // Background color
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
                .font(.custom("SFProText-Heavy", size: 24)) // Custom font SFProText-Heavy
                .foregroundColor(.white) // Text color white
                .padding(.leading)
            
            ForEach(pointsHistory) { entry in
                HStack {
                    VStack(alignment: .leading) {
                        Text(entry.reason)
                            .font(.custom("SFProText-Bold", size: 16)) // Custom font SFProText-Bold
                            .foregroundColor(.white) // Text color white
                        Text(entry.date, style: .date)
                            .font(.custom("SFProText-Bold", size: 12)) // Custom font SFProText-Bold for date
                            .foregroundColor(.white.opacity(0.7)) // Caption color white with opacity
                    }
                    Spacer()
                    Text("+\(entry.points)")
                        .font(.custom("SFProText-Heavy", size: 18)) // Custom font SFProText-Heavy
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
