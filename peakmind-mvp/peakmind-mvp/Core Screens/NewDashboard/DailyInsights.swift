//
//  DailyInsights.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 12/23/24.
//

import Foundation
import SwiftUI

// MARK: - Daily Insights Section


import SwiftUI

struct Insight: Identifiable {
    let id = UUID()
    let title: String
    let value: String      // e.g., "7 hours", "5000 steps"
    let status: InsightStatus  // e.g., .good, .fair, .poor
    let icon: String      // system image name or custom asset
    let type: InsightType // enum for insight categories (sleep, activity, etc.)
}

// For charting or detailed daily breakdown
struct DailyDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

enum InsightStatus {
    case excellent
    case good
    case fair
    case poor
}

enum InsightType {
    case sleep
    case steps
    case mood
    case custom(String) // Expandable for future types
}

import SwiftUI
import Combine
import HealthKit
import SwiftUI
import Combine
import Firebase
import FirebaseFirestore

import SwiftUI
import Combine
import Firebase
import FirebaseFirestore

class InsightsAggregator: ObservableObject {
    
    @Published var dailyInsights: [Insight] = []
    
    // For charts or detailed views
    @Published var stepDataPoints: [DailyDataPoint] = []
    @Published var activeEnergyDataPoints: [DailyDataPoint] = []
    
    private var db = Firestore.firestore()
    private var userId: String
    
    init(userId: String) {
        guard !userId.isEmpty else {
            self.userId = "default"
            print("Warning: Empty userId provided to InsightsAggregator")
            return
        }
        self.userId = userId
        
        // (Optional) request HealthKit authorization if you still want to use it
        requestHealthKitAuthorization()
        
        fetchDailyInsights()
    }
    
    private func requestHealthKitAuthorization() {
        // HealthKit authorization if needed
    }
    
    // Main function to refresh daily insights
    func fetchDailyInsights() {
        // Fetch step data
        fetchStepDataForLast7Days { [weak self] stepPoints in
            guard let self = self else { return }
            self.stepDataPoints = stepPoints
            
            // Fetch active energy data
            self.fetchActiveEnergyForLast7Days { [weak self] energyPoints in
                guard let self = self else { return }
                self.activeEnergyDataPoints = energyPoints
                
                // Now that both sets of data are fetched, create the combined Insights
                self.createInsights()
            }
        }
    }
    
    // MARK: - Fetch Steps Data
    
    private func fetchStepDataForLast7Days(completion: @escaping ([DailyDataPoint]) -> Void) {
        let last7Dates = generateLast7Dates()
        var dataPoints: [DailyDataPoint] = []
        let group = DispatchGroup()
        
        for date in last7Dates {
            group.enter()
            let dateString = formattedString(for: date)
            
            db.collection("users")
              .document(userId)
              .collection("healthKitData")
              .document("stepCount")
              .collection("days")
              .document(dateString)
              .getDocument { snapshot, error in
                  defer { group.leave() }
                  
                  if let error = error {
                      print("Error fetching steps for \(dateString): \(error)")
                      return
                  }
                  
                  guard let data = snapshot?.data(),
                        let steps = data["steps"] as? Double else {
                      return
                  }
                  
                  dataPoints.append(DailyDataPoint(date: date, value: steps))
              }
        }
        
        group.notify(queue: .main) {
            let sortedPoints = dataPoints.sorted { $0.date < $1.date }
            completion(sortedPoints)
        }
    }
    
    // MARK: - Fetch Active Energy Data
    
    private func fetchActiveEnergyForLast7Days(completion: @escaping ([DailyDataPoint]) -> Void) {
        let last7Dates = generateLast7Dates()
        var dataPoints: [DailyDataPoint] = []
        let group = DispatchGroup()
        
        for date in last7Dates {
            group.enter()
            let dateString = formattedString(for: date)
            
            db.collection("users")
              .document(userId)
              .collection("healthKitData")
              .document("activeEnergyBurned")
              .collection("days")
              .document(dateString)
              .getDocument { snapshot, error in
                  defer { group.leave() }
                  
                  if let error = error {
                      print("Error fetching active energy for \(dateString): \(error)")
                      return
                  }
                  
                  guard let data = snapshot?.data(),
                        let activeEnergy = data["activeEnergy"] as? Double else {
                      return
                  }
                  
                  dataPoints.append(DailyDataPoint(date: date, value: activeEnergy))
              }
        }
        
        group.notify(queue: .main) {
            let sortedPoints = dataPoints.sorted { $0.date < $1.date }
            completion(sortedPoints)
        }
    }
    
    // MARK: - Create Insights
    
    private func createInsights() {
        // --- Steps ---
        let totalSteps = stepDataPoints.reduce(0) { $0 + $1.value }
        let avgSteps = stepDataPoints.isEmpty ? 0 : (totalSteps / Double(stepDataPoints.count))
        
        let roundedTotalSteps = Int(round(totalSteps))
        let roundedAvgSteps = Int(round(avgSteps))
        
        // --- Active Energy ---
        let totalEnergy = activeEnergyDataPoints.reduce(0) { $0 + $1.value }
        let avgEnergy = activeEnergyDataPoints.isEmpty ? 0 : (totalEnergy / Double(activeEnergyDataPoints.count))
        
        let roundedTotalEnergy = Int(round(totalEnergy))
        let roundedAvgEnergy = Int(round(avgEnergy))
        
        // Build [Insight]. In the future, add more data sources here.
        let stepsInsight = Insight(
            title: "Steps Over Last Week",
            value: "\(roundedAvgSteps) avg / \(roundedTotalSteps) total",
            status: statusForSteps(roundedAvgSteps),
            icon: "figure.walk",
            type: .steps
        )
        
        let energyInsight = Insight(
            title: "Active Energy Over Last Week",
            value: "\(roundedAvgEnergy) avg / \(roundedTotalEnergy) total",
            status: statusForActiveEnergy(roundedAvgEnergy),
            icon: "flame.fill",
            type: .custom("activeEnergy")
        )
        
        // Replace the entire array. You could also append if you have more insights.
        self.dailyInsights = [stepsInsight, energyInsight]
    }
    
    // MARK: - Utility: Step & Energy Status
    
    private func statusForSteps(_ steps: Int) -> InsightStatus {
        switch steps {
            case ..<2000: return .poor
            case 2000..<7000: return .fair
            case 7000..<10000: return .good
            default: return .excellent
        }
    }
    
    private func statusForActiveEnergy(_ energy: Int) -> InsightStatus {
        switch energy {
            case ..<200: return .poor
            case 200..<400: return .fair
            case 400..<600: return .good
            default: return .excellent
        }
    }
    
    // MARK: - Helper Methods
    
    private func generateLast7Dates() -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Create an array of the last 7 days (including today)
        return (1..<8).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: -dayOffset, to: today)
        }.sorted()
    }
    
    private func formattedString(for date: Date) -> String {
        // Format as "YYYY-MM-DD"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}


struct DailyInsightsSection: View {
    // Placeholder insights; you would replace with real data
    let insights: [String] = [
        "Mood: Calm",
        "Sleep: 7 hours (Good)",
        "Steps: 5,000 (Fair)",
        "Focus Sessions: 2 completed"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Insights")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(insights, id: \.self) { insight in
                HStack {
                    Image(systemName: "chart.bar.fill") // Just a placeholder icon
                        .foregroundColor(.green)
                    Text(insight)
                        .font(.body)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
            
            // Example "See More" button to navigate to a detailed analytics screen
            Button(action: {
                // Navigate to a more detailed analytics view
            }) {
                Text("See More")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.leading)
            }
        }
        .padding(.vertical, 12)
        .background(Color("CardBackground"))
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding(.horizontal)
    }
}


struct InsightsView: View {
    @ObservedObject var aggregator: InsightsAggregator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Personalized Tools")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            List {
                ForEach(aggregator.dailyInsights) { insight in
                    HStack {
                        Image(systemName: insight.icon)
                            .foregroundColor(colorForStatus(insight.status))
                        VStack(alignment: .leading) {
                            Text(insight.title)
                                .font(.headline)
                            Text(insight.value)
                                .font(.subheadline)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
    
    private func colorForStatus(_ status: InsightStatus) -> Color {
        switch status {
            case .excellent: return .green
            case .good: return .blue
            case .fair: return .orange
            case .poor: return .red
        }
    }
}

struct InsightRow: View {
    let insight: Insight
    
    var body: some View {
        HStack {
            // Icon
            Image(systemName: insight.icon)
                .foregroundColor(colorForStatus(insight.status))
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text(insight.title)
                    .font(.headline)
                Text(insight.value)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Optional color-coded indicator
            Circle()
                .fill(colorForStatus(insight.status))
                .frame(width: 10, height: 10)
        }
        .padding(.vertical, 4)
    }
    
    // Color-coding based on the insight’s status
    func colorForStatus(_ status: InsightStatus) -> Color {
        switch status {
            case .excellent: return .green
            case .good: return .blue
            case .fair: return .orange
            case .poor: return .red
        }
    }
}

struct InsightsListView: View {
    @ObservedObject var aggregator: InsightsAggregator
    @State private var selectedInsight: Insight? = nil
    @State private var showDetail = false
    @EnvironmentObject var viewModel: AuthViewModel // Added viewModel as an environment object

    var body: some View {
            // We want horizontal scrolling only
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Weekly Insights")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
                .padding(.leading)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(aggregator.dailyInsights) { insight in
                        // Each insight is displayed in a card
                        InsightCard(insight: insight) {
                            // On tap, store the selected insight and open the detail
                            selectedInsight = insight
                            showDetail = true
                        }
                        // Fix card size so they’re uniform
                        .frame(width: 240, height: 160)
                    }
                }
                .padding([.horizontal])
            }
        }
//            .navigationTitle("Dashboard")
            // Present a detail view via sheet when user taps a card
            .sheet(item: $selectedInsight) { insight in
                InsightDetailView(aggregator: aggregator, insight: insight)
            }
        }
    
}


import Charts
import SwiftUI

import SwiftUI
import Charts

struct InsightDetailView: View, Identifiable {
    let id = UUID()
    
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var aggregator: InsightsAggregator
    let insight: Insight
    
    // State to track user selection (for interactive charts)
    @State private var selectedPoint: DailyDataPoint? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            // Title & Description
            Text(insight.title)
                .font(.title2)
                .padding(.top, 16)
            
            // Show the relevant chart depending on the insight type
            switch insight.type {
            case .steps:
                Text("Daily Steps Chart (Last 7 Days)")
                    .font(.headline)
                
                InteractiveStepsChart(data: aggregator.stepDataPoints,
                                      selectedPoint: $selectedPoint)
                .frame(height: 250)
                
                // Provide qualitative feedback based on average steps
                Text(feedbackForSteps())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

            case .custom("activeEnergy"):
                Text("Daily Active Energy (Last 7 Days)")
                    .font(.headline)
                
                InteractiveActiveEnergyChart(data: aggregator.activeEnergyDataPoints,
                                             selectedPoint: $selectedPoint)
                .frame(height: 250)
                
                // Provide qualitative feedback based on average energy
                Text(feedbackForActiveEnergy())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
            default:
                Text("No chart available for this insight type.")
                    .padding(.top, 16)
            }
            
            Spacer()
            
            // Close or Dismiss button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Close")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
            }
            .padding(.bottom)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Qualitative Feedback
    
    private func feedbackForSteps() -> String {
        // You could compute average steps or pull from aggregator
        let totalSteps = aggregator.stepDataPoints.reduce(0) { $0 + $1.value }
        let count = Double(aggregator.stepDataPoints.count)
        let avgSteps = (count == 0) ? 0 : totalSteps / count
        
        switch avgSteps {
        case 0..<3000:
            return "Your activity is a bit low. Try adding short walks or stretches!"
        case 3000..<8000:
            return "Nice job staying active! Keep up the daily walking routine."
        case 8000..<10000:
            return "Great work! You’re above average in your daily steps."
        default:
            return "Excellent! You’re crushing your step goal—keep it up!"
        }
    }
    
    private func feedbackForActiveEnergy() -> String {
        let totalEnergy = aggregator.activeEnergyDataPoints.reduce(0) { $0 + $1.value }
        let count = Double(aggregator.activeEnergyDataPoints.count)
        let avgEnergy = (count == 0) ? 0 : totalEnergy / count
        
        switch avgEnergy {
        case 0..<200:
            return "You might need more active time. Try short, frequent exercise sessions."
        case 200..<400:
            return "You’re doing pretty well—aim for a bit more consistency."
        case 400..<600:
            return "Nice energy burn! You’re on a strong track for daily activity."
        default:
            return "Excellent energy burn—you're surpassing typical goals!"
        }
    }
}
import SwiftUI
import Charts

struct InteractiveStepsChart: View {
    let data: [DailyDataPoint]
    
    // Bind a selected point for pinned annotation
    @Binding var selectedPoint: DailyDataPoint?

    var body: some View {
        Chart {
            ForEach(data) { point in
                BarMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Steps", point.value)
                )
                .foregroundStyle(Color.blue.gradient)
                
                // Annotation: Display text above the bar ONLY if this bar is the selected one
                .annotation(position: .overlay, alignment: .top) {
                    if selectedPoint?.id == point.id {
                        labelForPoint(point)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                // Translate gesture x-position to a Date on the chart’s x-axis
                                let xLocation = value.location.x - geometry[proxy.plotAreaFrame].origin.x
                                if let date: Date = proxy.value(atX: xLocation) {
                                    // Find the data point nearest to this date
                                    selectedPoint = findNearestPoint(to: date)
                                }
                            }
                            .onEnded { _ in
                                // Optionally keep it selected or clear it:
                                // selectedPoint = nil
                            }
                    )
            }
        }
    }
    
    // Helper to show a small label with the y-value
    private func labelForPoint(_ point: DailyDataPoint) -> some View {
        Text("\(Int(point.value)) steps")
            .font(.caption)
            .padding(4)
            .background(.thinMaterial)
            .cornerRadius(4)
    }
    
    // Finds the data point closest by date
    private func findNearestPoint(to date: Date) -> DailyDataPoint? {
        guard !data.isEmpty else { return nil }
        
        // Sort data if it isn’t already
        let sorted = data.sorted { $0.date < $1.date }
        // Convert the input date to a timeInterval
        let targetTime = date.timeIntervalSince1970
        
        return sorted.min(by: {
            abs($0.date.timeIntervalSince1970 - targetTime) <
            abs($1.date.timeIntervalSince1970 - targetTime)
        })
    }
}


struct InteractiveActiveEnergyChart: View {
    let data: [DailyDataPoint]
    @Binding var selectedPoint: DailyDataPoint?
    
    var body: some View {
        Chart {
            ForEach(data) { point in
                BarMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Active Energy", point.value)
                )
                .foregroundStyle(Color.red.gradient)
                .annotation(position: .overlay, alignment: .top) {
                    if selectedPoint?.id == point.id {
                        Text("\(Int(point.value)) kcal")
                            .font(.caption)
                            .padding(4)
                            .background(.thinMaterial)
                            .cornerRadius(4)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle().fill(Color.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let xLocation = value.location.x - geometry[proxy.plotAreaFrame].origin.x
                                if let date: Date = proxy.value(atX: xLocation) {
                                    selectedPoint = findNearestPoint(to: date)
                                }
                            }
                    )
            }
        }
    }
    
    private func findNearestPoint(to date: Date) -> DailyDataPoint? {
        guard !data.isEmpty else { return nil }
        let targetTime = date.timeIntervalSince1970
        let sorted = data.sorted { $0.date < $1.date }
        
        return sorted.min(by: { abs($0.date.timeIntervalSince1970 - targetTime) < abs($1.date.timeIntervalSince1970 - targetTime) })
    }
}



// Example chart views
struct StepsChartView: View {
    let data: [DailyDataPoint]
    
    var body: some View {
        Chart(data) { point in
            BarMark(
                x: .value("Date", point.date, unit: .day),
                y: .value("Steps", point.value)
            )
            .foregroundStyle(Color.blue.gradient)
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 200)
    }
}

struct ActiveEnergyChartView: View {
    let data: [DailyDataPoint]
    
    var body: some View {
        Chart(data) { point in
            BarMark(
                x: .value("Date", point.date, unit: .day),
                y: .value("Energy", point.value)
            )
            .foregroundStyle(Color.red.gradient)
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 200)
    }
}


struct InsightCard: View {
    let insight: Insight
    var onTap: () -> Void  // closure for tapping the card
    
    var body: some View {
        ZStack {
            // Background color changes based on status
            backgroundColor(for: insight.status)
                .cornerRadius(12)
                .shadow(radius: 2)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: insight.icon)
                        .foregroundColor(.white)
                        .font(.title2)
                    
                    Text(insight.title)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Text(insight.value)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
        }
        // Tap gesture to open detail
        .onTapGesture {
            onTap()
        }
    }
    
    // Return a different background color depending on performance
    private func backgroundColor(for status: InsightStatus) -> Color {
        switch status {
            case .excellent: return Color.green.opacity(0.8)
            case .good:      return Color.blue.opacity(0.8)
            case .fair:      return Color.orange.opacity(0.8)
            case .poor:      return Color.red.opacity(0.8)
        }
    }
}
