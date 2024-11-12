//
//  Analytics.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 9/15/24.
//

import Foundation
import Combine
import FirebaseFirestore

class AnalyticsViewModel: ObservableObject {
    @Published var habitHistory: [Habit] = []
    let habitTitle: String
    private var db = Firestore.firestore()
    private var userID: String

    init(habitTitle: String, userID: String) {
        self.habitTitle = habitTitle
        self.userID = userID
        loadHabitHistory()
    }

    private func loadHabitHistory() {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -30, to: endDate)!

        var currentDate = startDate
        var habitData: [Habit] = []

        let dispatchGroup = DispatchGroup()

        while currentDate <= endDate {
            let dateString = dateString(for: currentDate)
            dispatchGroup.enter()

            db.collection("users").document(userID).collection("habits").document(dateString).getDocument { document, error in
                defer { dispatchGroup.leave() }

                if let document = document, document.exists {
                    if let data = document.data(), let habitsData = data["habits"] as? [[String: Any]] {
                        for habitDict in habitsData {
                            if let habit = self.createHabit(from: habitDict), habit.title == self.habitTitle {
                                habitData.append(habit)
                            }
                        }
                    }
                } else {
                    if let error = error {
                        print("Error fetching document for \(dateString): \(error.localizedDescription)")
                    }
                }
            }

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        dispatchGroup.notify(queue: .main) {
            self.habitHistory = habitData
        }
    }

    private func dateString(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }

    
    private func createHabit(from data: [String: Any]) -> Habit? {
        if let id = data["id"] as? String,
           let title = data["title"] as? String,
           let unit = data["unit"] as? String,
           let count = data["count"] as? Int,
           let goal = data["goal"] as? Int,
           let startColor = data["startColor"] as? String,
           let endColor = data["endColor"] as? String,
           let category = data["category"] as? String,
           let frequencyRawValue = data["frequency"] as? String,
           let frequency = Habit.FrequencyType(rawValue: frequencyRawValue),
           let routineTimeRawValue = data["routineTime"] as? String,
           let routineTime = Habit.RoutineTime(rawValue: routineTimeRawValue),
           let endDate = (data["endDate"] as? Timestamp)?.dateValue(),
           let startDate = (data["startDate"] as? Timestamp)?.dateValue(),
           let dateTaken = data["dateTaken"] as? String {

            let reminder = (data["reminder"] as? Timestamp)?.dateValue()

            let interval = data["interval"] as? Int
            let daysOfWeek = data["daysOfWeek"] as? [Int]

            var specificDates: [Date]? = nil
            if let specificDatesTimestamps = data["specificDates"] as? [Timestamp] {
                specificDates = specificDatesTimestamps.map { $0.dateValue() }
            } else if let specificDatesMillis = data["specificDates"] as? [Double] {
                specificDates = specificDatesMillis.map { Date(timeIntervalSince1970: $0 / 1000) }
            } else if let specificDatesStrings = data["specificDates"] as? [String] {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd" // Adjust the date format if needed
                specificDates = specificDatesStrings.compactMap { dateFormatter.date(from: $0) }
            }

            return Habit(id: id, title: title, unit: unit, count: count, goal: goal,
                         startColor: startColor, endColor: endColor,
                         category: category, frequency: frequency,
                         reminder: reminder, routineTime: routineTime,
                         endDate: endDate, dateTaken: dateTaken, startDate: startDate,
                         interval: interval, daysOfWeek: daysOfWeek, specificDates: specificDates)
        }
        return nil
    }
}


import SwiftUI
import Charts

// MARK: - Analytics View
struct AnalyticsView: View {
    @StateObject private var viewModel: AnalyticsViewModel
    @State private var selectedChartType: ChartType = .bar

    init(habitTitle: String, userID: String) {
        _viewModel = StateObject(wrappedValue: AnalyticsViewModel(habitTitle: habitTitle, userID: userID))
    }

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.habitHistory.isEmpty {
                    ProgressView("Loading data...")
                        .padding()
                } else {
                    Picker("Select Chart Type", selection: $selectedChartType) {
                        Text("Bar Chart").tag(ChartType.bar)
                        Text("Line Chart").tag(ChartType.line)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    if selectedChartType == .bar {
                        BarChartView(habitHistory: viewModel.habitHistory)
                    } else {
                        LineChartView(habitHistory: viewModel.habitHistory)
                    }
                }
            }
            .navigationTitle("Analytics for \(viewModel.habitTitle)")
        }
    }
}

// MARK: - Chart Type Enum
enum ChartType {
    case bar
    case line
}

// MARK: - Bar Chart View
struct BarChartView: View {
    let habitHistory: [Habit]

    var body: some View {
        Chart {
            ForEach(sortedHabitHistory) { habit in
                if let date = parseDate(from: habit.dateTaken) {
                    BarMark(
                        x: .value("Date", date),
                        y: .value("Count", habit.count)
                    )
                    .foregroundStyle(Color.green)
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
        .chartYAxis {
            AxisMarks()
        }
        .frame(height: 300)
        .padding()
    }

    // Helper functions
    func parseDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateString)
    }

    var sortedHabitHistory: [Habit] {
        habitHistory.sorted { (habit1, habit2) -> Bool in
            guard let date1 = parseDate(from: habit1.dateTaken),
                  let date2 = parseDate(from: habit2.dateTaken) else {
                return false
            }
            return date1 < date2
        }
    }
}

// MARK: - Line Chart View
struct LineChartView: View {
    let habitHistory: [Habit]

    var body: some View {
        Chart {
            ForEach(sortedHabitHistory) { habit in
                if let date = parseDate(from: habit.dateTaken) {
                    LineMark(
                        x: .value("Date", date),
                        y: .value("Count", habit.count)
                    )
                    .foregroundStyle(Color.blue)
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
        .chartYAxis {
            AxisMarks()
        }
        .frame(height: 300)
        .padding()
    }

    // Helper functions
    func parseDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateString)
    }

    var sortedHabitHistory: [Habit] {
        habitHistory.sorted { (habit1, habit2) -> Bool in
            guard let date1 = parseDate(from: habit1.dateTaken),
                  let date2 = parseDate(from: habit2.dateTaken) else {
                return false
            }
            return date1 < date2
        }
    }
}
