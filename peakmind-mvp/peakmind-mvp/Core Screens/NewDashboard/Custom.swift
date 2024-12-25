//
//  Custom.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 12/23/24.
//

import Foundation
import SwiftUI

struct HomeDashboardViewCustom: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var toolsViewModel: ToolsViewModel
    @EnvironmentObject var eventKitManager: EventKitManager
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject var aggregator: InsightsAggregator
    
    @State private var showToolsSettings = false
    @State private var showDashboardCustomization = false
    
    // The new preferences VM
    @StateObject private var dashboardPrefsVM = DashboardPreferencesViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Example: Recommended Action Section
                    // We’ll conditionally show/hide based on prefs
                    if isSectionVisible("recommendedAction") {
                        RecommendedActionSection()
                    }

                    // Insights summary
                    // We can apply layout or show/hide based on prefs
                    if isSectionVisible("insights") {
                        InsightsListView(aggregator: aggregator)
                    }

                    // Personalized Tools
                    if isSectionVisible("tools") {
                        PersonalizedToolsSection()
                            .environmentObject(toolsViewModel)
                    }
                    
                    // Add more sections as needed...
                    
                    FooterSection()
                }
                .padding(.vertical)
            }
            .onAppear {
                aggregator.fetchDailyInsights()
                
                if let userId = viewModel.currentUser?.id {
                    dashboardPrefsVM.fetchPreferences(for: userId)
                }
            }
            .navigationBarTitle("Home", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    // Handle Menu action
                }) {
                    Image(systemName: "line.horizontal.3")
                },
                trailing: HStack {
                    // Tools customization
                    Button(action: {
                        showToolsSettings.toggle()
                    }) {
                        Image(systemName: "rectangle.grid.2x2")
                    }
                    // Dashboard customization gear
                    Button(action: {
                        showDashboardCustomization.toggle()
                    }) {
                        Image(systemName: "gearshape.fill")
                    }
                }
            )
            // Tools settings sheet
            .sheet(isPresented: $showToolsSettings) {
                ToolsSettingsView(userId: viewModel.currentUser?.id ?? "", viewModel: viewModel)
                    .environmentObject(toolsViewModel)
            }
            // Dashboard customization sheet
            .sheet(isPresented: $showDashboardCustomization) {
                if let userId = viewModel.currentUser?.id {
                    DashboardCustomizationView(prefsViewModel: dashboardPrefsVM, userId: userId)
                } else {
                    Text("No user logged in")
                        .font(.title)
                        .padding()
                }
            }
        }
    }
    
    // Helper to check if a given section is included in the user’s sectionsOrder
    private func isSectionVisible(_ sectionKey: String) -> Bool {
        dashboardPrefsVM.preferences.sectionsOrder.contains(sectionKey)
    }
}
