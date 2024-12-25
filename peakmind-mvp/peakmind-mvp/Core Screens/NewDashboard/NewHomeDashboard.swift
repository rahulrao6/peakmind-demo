import SwiftUI


struct DailyInsights {
    var mood: String?           // e.g., "Happy", "Calm", "Stressed"
    var moodDescription: String // e.g., "Great progress!" (placeholder)
    var steps: Int              // e.g., from HealthKit
    var sleepHours: Double      // e.g., from HealthKit
    var screenTime: Double      // e.g., from Screen Time integration
    var habitStatus: String?    // e.g., "All habits done", or "1 out of 3"
    // Add more fields as needed (Focus session metrics, daily checkin, etc.)
}


struct HomeDashboardView: View {
    @EnvironmentObject var viewModel: AuthViewModel // Added viewModel as an environment object
    @EnvironmentObject var ToolsViewModel: ToolsViewModel // Added viewModel as an environment object
    @EnvironmentObject var EventKitManager1: EventKitManager
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject var aggregator: InsightsAggregator // Added viewModel as an environment object
    @EnvironmentObject var recommendationsVM : RecommendationsViewModel

    @State private var showToolsSettings = false

    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Example: Recommended Action Section (omitted details)
                    RecommendedActionsSection(viewModel: recommendationsVM).environmentObject(viewModel)

                    // Insights summary
                    InsightsListView(aggregator: aggregator)
                        
                    // Personalized Tools
                    PersonalizedToolsSection().environmentObject(ToolsViewModel).environmentObject(viewModel)
                    
                    // Footer
                    FooterSection()
                }
                .padding(.vertical)
            }
            .onAppear() {
                aggregator.fetchDailyInsights()
                
            }
            .sheet(isPresented: $showToolsSettings) {
                ToolsSettingsView(userId: viewModel.currentUser?.id ?? "", viewModel: viewModel)
                    .environmentObject(ToolsViewModel)
            }
        }
        .navigationTitle("Dashboard")

    }
    
    // Mock daily insights to demonstrate usage
    var mockDailyInsights: DailyInsights {
        DailyInsights(
            mood: "Calm",
            moodDescription: "Feeling relaxed",
            steps: 3000,
            sleepHours: 6.5,
            screenTime: 2.3,
            habitStatus: "2/3 habits"
        )
    }
}


// MARK: - Footer (Miscellaneous)

struct FooterSection: View {
    var body: some View {
        VStack(spacing: 8) {
            // Example motivational quote
            Text("“Every small step counts!”")
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            // Example: Morning/Evening Summary Prompt
            // (Navigate to a morning/evening check-in flow)
            Button(action: {
                // Show morning/evening summary
            }) {
                Text("View Evening Recap")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview

struct HomeDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        HomeDashboardView()
            // Example of forcing a light or dark mode for design previews:
            .preferredColorScheme(.light)
    }
}
