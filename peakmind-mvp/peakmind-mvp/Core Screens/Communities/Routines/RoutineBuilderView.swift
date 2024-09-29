import SwiftUI
import EventKit
import Charts
struct GradientProgressViewStyleWithLabel: ProgressViewStyle {
    var gradient: LinearGradient
    var title: String
    var currentValue: Int
    var totalValue: Int
    var unit: String

    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background bar
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 60)

                // Progress bar
                RoundedRectangle(cornerRadius: 10)
                    .fill(gradient)
                    .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * geometry.size.width, height: 60)

                // Text inside the progress bar
                HStack {
                    Text(title) // Title on the left side of the bar
                        .font(.custom("SFProText-Heavy", size: 16))
                        .foregroundColor(.white)
                        .padding(.leading, 10)

                    Spacer()

                    Text("\(currentValue)/\(totalValue) \(unit)") // Count on the right side of the bar
                        .font(.custom("SFProText-Heavy", size: 16))
                        .foregroundColor(.white)
                        .padding(.trailing, 10)
                }
                .frame(width: geometry.size.width)
            }
        }
        .frame(height: 60)
    }
}
struct GradientProgressViewStyleWithLabel2: ProgressViewStyle {
    var title: String
    var currentValue: Int
    var totalValue: Int
    var unit: String
    var endColor: Color
    var startColor: Color

    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 60)

                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(gradient: Gradient(colors: [startColor, endColor]), startPoint: .leading, endPoint: .trailing))
                    .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * geometry.size.width, height: 60)

                HStack {
                    Text(title)
                        .font(.custom("SFProText-Heavy", size: 16))
                        .foregroundColor(.white)
                        .padding(.leading, 10)

                    Spacer()

                    Text("\(currentValue)/\(totalValue) \(unit)")
                        .font(.custom("SFProText-Heavy", size: 16))
                        .foregroundColor(.white)
                        .padding(.trailing, 10)
                }
                .frame(width: geometry.size.width)
            }
        }
        .frame(height: 60)
    }
}


import FirebaseFirestore



import Foundation
import FirebaseFirestore

struct Habit: Identifiable {
    let id: String
    let title: String
    let unit: String
    var count: Int
    let goal: Int
    let startColor: String
    let endColor: String
    let category: String
    let frequency: FrequencyType
    let reminder: Date?
    let routineTime: RoutineTime
    let endDate: Date
    let dateTaken: String // New property
    // New properties for custom frequencies
     let startDate: Date
     let interval: Int? // For every N days
     let daysOfWeek: [Int]? // For specific days of the week (1 = Sunday, 7 = Saturday)
     let specificDates: [Date]? // For specific dates
     
    // Enum for frequency types
    enum FrequencyType: String {
        case daily
        case weekly
        case monthly
        case everyNDays
        case specificDaysOfWeek
    }

    enum RoutineTime: String, CaseIterable {
        case morning = "Morning"
        case afternoon = "Afternoon"
        case evening = "Evening"
        case anytime = "Anytime"
    }

    init(id: String, title: String, unit: String, count: Int, goal: Int, startColor: String, endColor: String, category: String, frequency: FrequencyType, reminder: Date?, routineTime: RoutineTime, endDate: Date, dateTaken: String, startDate: Date, interval: Int? = nil, daysOfWeek: [Int]? = nil, specificDates: [Date]? = nil) {
        self.id = id
        self.title = title
        self.unit = unit
        self.count = count
        self.goal = goal
        self.startColor = startColor
        self.endColor = endColor
        self.category = category
        self.frequency = frequency
        self.reminder = reminder
        self.routineTime = routineTime
        self.endDate = endDate
        self.dateTaken = dateTaken
        self.startDate = startDate
        self.interval = interval
        self.daysOfWeek = daysOfWeek
        self.specificDates = specificDates
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, unit, count, goal, startColor, endColor, category, frequency, reminder, routineTime, endDate, dateTaken, startDate, interval, daysOfWeek, specificDates
    }
    
    init?(dictionary: [String: Any]) {
        // Required fields
        guard let id = dictionary["id"] as? String,
              let title = dictionary["title"] as? String,
              let unit = dictionary["unit"] as? String,
              let count = dictionary["count"] as? Int,
              let goal = dictionary["goal"] as? Int,
              let startColor = dictionary["startColor"] as? String,
              let endColor = dictionary["endColor"] as? String,
              let category = dictionary["category"] as? String,
              let frequencyRawValue = dictionary["frequency"] as? String,
              let frequency = Habit.FrequencyType(rawValue: frequencyRawValue.lowercased()),
              let routineTimeRawValue = dictionary["routineTime"] as? String,
              let routineTime = Habit.RoutineTime(rawValue: routineTimeRawValue.lowercased()),
              let endTimestamp = dictionary["endDate"] as? Timestamp,
              let dateTaken = dictionary["dateTaken"] as? String else {
            print("Failed to parse required fields in Habit initializer.")
            return nil
        }
        
        // Optional fields
        let reminderDate: Date?
        if let reminderTimestamp = dictionary["reminder"] as? Timestamp {
            reminderDate = reminderTimestamp.dateValue()
        } else {
            reminderDate = nil
        }

        // Handle `startDate` (if optional)
        let startDate: Date
        if let startTimestamp = dictionary["startDate"] as? Timestamp {
            startDate = startTimestamp.dateValue()
        } else {
            // Provide a default value or handle the absence appropriately
            startDate = Date() // Default to current date, or adjust as needed
        }

        self.id = id
        self.title = title
        self.unit = unit
        self.count = count
        self.goal = goal
        self.startColor = startColor
        self.endColor = endColor
        self.category = category
        self.frequency = frequency
        self.reminder = reminderDate
        self.routineTime = routineTime
        self.endDate = endTimestamp.dateValue()
        self.startDate = startDate
        self.dateTaken = dateTaken
        self.interval = dictionary["interval"] as? Int
        self.daysOfWeek = dictionary["daysOfWeek"] as? [Int]
        self.specificDates = [Date()]
        // Handle `specificDates` similarly if needed
    }
}

import SwiftUI
import Firebase

struct RoutineBuilderView: View {
    @State private var selectedRoutines: Set<String> = ["All"]
    @State private var showingAddHabitForm: Bool = false
    @State private var showingIncrementPopup: Bool = false
    @State private var selectedHabitId: String?
    @State private var selectedDate: Date = Date()
    @State private var selectedRoutine: Habit.RoutineTime = .anytime
    @State private var habits: [Habit] = []
    @State private var habitProgress: [String: CGFloat] = [:]
    @State private var showingAnalytics: Bool = false
    @State private var selectedHabitForAnalytics: Habit?
    @State private var habitHistory: [String: [Habit]] = [:]
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var habitsByName: [String: [Habit]] = [:]
    private var db = Firestore.firestore()
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Image("RoutineBG")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text("Your Routines")
                        .font(.custom("SFProText-Heavy", size: 28))
                        .foregroundColor(.white)
                        .padding(.leading, 20)
                    
                    Spacer()
                    
                    Menu {
                        ForEach(Habit.RoutineTime.allCases, id: \.self) { routineTime in
                            Button(routineTime.rawValue) {
                                selectedRoutine = routineTime
                            }
                        }
                        } label: {
                        Text(selectedRoutine.rawValue ?? "All")
                            .font(.custom("SFProText-Heavy", size: 14))
                            .frame(width: 50, height: 5)
                            .padding()
                            .background(Color(hex: "6b58db"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.trailing, 20)
                    }
                }
                .padding(.top, 40)
                
                ScrollView(.horizontal, showsIndicators: false) {
                                   HStack(spacing: 10) {
                                       ForEach(-3..<7, id: \.self) { index in
                                           let date = Calendar.current.date(byAdding: .day, value: index, to: Date()) ?? Date()
                                           VStack {
                                               ZStack(alignment: .bottom) {
                                                   RoundedRectangle(cornerRadius: 8)
                                                       .fill(
                                                           Calendar.current.isDateInToday(date) ? Color.black.opacity(0.4) :
                                                           (Calendar.current.isDate(selectedDate, inSameDayAs: date) ? Color.blue.opacity(0.4) : Color.gray.opacity(0.0))
                                                       )
                                                       .frame(width: 50, height: 80)
                                                       .border(Color.blue, width: Calendar.current.isDate(selectedDate, inSameDayAs: date) ? 2 : 0)
                                                   
                                                   // Updated progress bar for each date
                                                   RoundedRectangle(cornerRadius: 8)
                                                       .fill(Color(hex: "6b58db")!)
                                                       .frame(width: 50, height: 80 * (habitProgress[dateString(for: date)] ?? 0))
                                                   
                                                   VStack {
                                                       Text(getDayAbbreviation(for: date))
                                                           .font(.custom("SFProText-Bold", size: 12))
                                                           .foregroundColor(.white)
                                                       Text("\(getDateNumber(for: date))")
                                                           .font(.custom("SFProText-Heavy", size: 16))
                                                           .foregroundColor(.white)
                                                   }
                                                   .padding()
                                               }
                                               .onTapGesture {
                                                   selectedDate = date
                                                   loadHabits(for: date)
                                               }
                                           }
                                       }
                                   }
                                   .padding(.horizontal)
                               }
                               .padding(.top, -5)
                
                ScrollView {
                    VStack(spacing: 20) {
                        if filteredHabits.isEmpty {
                            Text("No tasks for the selected day")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.top, 20)
                        } else {
                        ForEach(filteredHabits) { habit in
                            ProgressView(value: CGFloat(habit.count) / CGFloat(habit.goal))
                                .progressViewStyle(GradientProgressViewStyleWithLabel2(
                                    title: habit.title,
                                    currentValue: habit.count,
                                    totalValue: habit.goal,
                                    unit: habit.unit,
                                    endColor: Color(hex: habit.endColor)!,
                                    startColor: Color(hex: habit.startColor)!
                                ))
                                .onTapGesture {
                                    selectedHabitForAnalytics = habit
                                    loadHabitHistoryForHabit(habit.title) {
                                        showingAnalytics = true
                                    }
                                }
                                .gesture(DragGesture(minimumDistance: 10)
                                    .onEnded { value in
                                        if value.translation.width < 0 {
                                            updateHabit(by: habit.id, increment: -1)
                                        } else if value.translation.width > 0 {
                                            updateHabit(by: habit.id, increment: 1)
                                        }
                                    }
                                )
                                .padding(.horizontal)
                        }
                    }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                
                Button(action: {
                    showingAddHabitForm.toggle()
                }) {
                    Text("Add New Habit")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom)
                Button(action: {
                    showingAnalytics = true
                }) {
                    Text("Show Analytics")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom)
            }
        }
        .sheet(isPresented: $showingIncrementPopup) {
            if let habitId = selectedHabitId {
                IncrementPopup(habitId: habitId, habits: habits) { increment in
                    updateHabit(by: habitId, increment: increment)
                }
            } else {
                EmptyView()
            }
        }
        .sheet(isPresented: $showingAddHabitForm) {
            AddHabitForm { newHabit in
                habits.append(newHabit)
                saveHabit(newHabit)
            }
        }
        .sheet(isPresented: $showingAnalytics) {
            if let selectedHabit = selectedHabitForAnalytics {
                AnalyticsView2(
                    habitHistory: habitsByName[selectedHabit.title] ?? [],
                    habitTitle: selectedHabit.title
                )
            }
        }
        
        .onAppear {
            loadHabits(for: selectedDate)
            loadHabitHistory()
            updateAllHabitProgress()

        }
    }
    
    private var filteredHabits: [Habit] {
        selectedRoutine == .anytime ? habits : habits.filter { $0.routineTime == selectedRoutine }
    }
    
    // New helper function to get date string
    private func dateString(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }

    private func getDayAbbreviation(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: date).uppercased()
    }

    private func getDateNumber(for date: Date) -> Int {
        let calendar = Calendar.current
        return calendar.component(.day, from: date)
    }
    
    func generateDailyDates(startDate: Date, endDate: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate
        let calendar = Calendar.current

        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        return dates
    }
    
    
    
    func generateWeeklyDates(startDate: Date, endDate: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate
        let calendar = Calendar.current

        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!
        }
        return dates
    }
    func generateMonthlyDates(startDate: Date, endDate: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate
        let calendar = Calendar.current

        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
        }
        return dates
    }
    
    func generateSpecificDaysOfWeekDates(startDate: Date, endDate: Date, daysOfWeek: [Int]) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate
        let calendar = Calendar.current

        while currentDate <= endDate {
            let weekday = calendar.component(.weekday, from: currentDate)
            if daysOfWeek.contains(weekday) {
                dates.append(currentDate)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        return dates
    }
    
    func generateEveryNDaysDates(startDate: Date, endDate: Date, interval: Int) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate
        let calendar = Calendar.current

        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: interval, to: currentDate)!
        }
        return dates
    }
    private func loadHabitHistoryForHabit(_ habitTitle: String, completion: @escaping () -> Void) {
        guard let user = viewModel.currentUser else {
            print("No current user")
            return
        }
        let userID = user.id

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
                            if let habit = createHabit(from: habitDict), habit.title == habitTitle {
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
            self.habitsByName[habitTitle] = habitData
            completion()
        }
    }
    
    // Updated saveHabit function
    private func saveHabit(_ habit: Habit) {
        guard let user = viewModel.currentUser else {
            print("No current user")
            return
        }
        let userID = user.id
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current

        var datesToSave: [Date] = []

        switch habit.frequency {
        case .daily:
            datesToSave = generateDailyDates(startDate: habit.startDate, endDate: habit.endDate)
        case .weekly:
            datesToSave = generateWeeklyDates(startDate: habit.startDate, endDate: habit.endDate)
        case .monthly:
            datesToSave = generateMonthlyDates(startDate: habit.startDate, endDate: habit.endDate)
        case .everyNDays:
            if let interval = habit.interval {
                datesToSave = generateEveryNDaysDates(startDate: habit.startDate, endDate: habit.endDate, interval: interval)
            }
        case .specificDaysOfWeek:
            if let daysOfWeek = habit.daysOfWeek {
                datesToSave = generateSpecificDaysOfWeekDates(startDate: habit.startDate, endDate: habit.endDate, daysOfWeek: daysOfWeek)
            }
        }

        for date in datesToSave {
            let dateString = dateFormatter.string(from: date)

            var habitData: [String: Any] = [
                "id": habit.id,
                "title": habit.title,
                "unit": habit.unit,
                "count": habit.count,
                "goal": habit.goal,
                "startColor": habit.startColor,
                "endColor": habit.endColor,
                "category": habit.category,
                "frequency": habit.frequency.rawValue,
                "routineTime": habit.routineTime.rawValue,
                "startDate": Timestamp(date: habit.startDate),
                "endDate": Timestamp(date: habit.endDate),
                "dateTaken": dateString
            ]

            // Handle optional fields
            if let reminderDate = habit.reminder {
                habitData["reminder"] = Timestamp(date: reminderDate)
            } else {
                habitData["reminder"] = NSNull()
            }

            if let interval = habit.interval {
                habitData["interval"] = interval
            } else {
                habitData["interval"] = NSNull()
            }

            if let daysOfWeek = habit.daysOfWeek {
                habitData["daysOfWeek"] = daysOfWeek
            } else {
                habitData["daysOfWeek"] = NSNull()
            }

            if let specificDates = habit.specificDates {
                habitData["specificDates"] = specificDates.map { Timestamp(date: $0) }
            } else {
                habitData["specificDates"] = NSNull()
            }

            db.collection("users").document(userID).collection("habits").document(dateString).setData([
                "habits": FieldValue.arrayUnion([habitData])
            ], merge: true) { error in
                if let error = error {
                    print("Error saving habit: \(error.localizedDescription)")
                } else {
                    print("Habit saved successfully for \(dateString)!")
                    self.updateAllHabitProgress()
                }
            }
        }
    }

    // Updated loadHabits function
    private func loadHabits(for date: Date) {
        guard let user = viewModel.currentUser else {
            print("No current user")
            return
        }
        let userID = user.id
        let dateString = dateString(for: date)
        print("loadhabits")
        db.collection("users").document(userID).collection("habits").document(dateString).getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data(), let habitsData = data["habits"] as? [[String: Any]] {
                    habits = habitsData.compactMap { habitData in
                        if let id = habitData["id"] as? String,
                           let title = habitData["title"] as? String,
                           let unit = habitData["unit"] as? String,
                           let count = habitData["count"] as? Int,
                           let goal = habitData["goal"] as? Int,
                           let startColor = habitData["startColor"] as? String,
                           let endColor = habitData["endColor"] as? String,
                           let category = habitData["category"] as? String,
                           let frequencyRawValue = habitData["frequency"] as? String,
                           let frequency = Habit.FrequencyType(rawValue: frequencyRawValue),
                           let routineTimeRawValue = habitData["routineTime"] as? String,
                           let routineTime = Habit.RoutineTime(rawValue: routineTimeRawValue),
                           let endDate = (habitData["endDate"] as? Timestamp)?.dateValue(),
                           let startDate = (habitData["startDate"] as? Timestamp)?.dateValue(),
                           let dateTaken = habitData["dateTaken"] as? String{
                            let habit = Habit(id: id, title: title, unit: unit, count: count, goal: goal,
                                              startColor: startColor, endColor: endColor,
                                              category: category, frequency: frequency,
                                              reminder: Date(),
                                              routineTime: routineTime, endDate: endDate, dateTaken: dateTaken, startDate: startDate)
                            
//                            // Check if the habit has just been completed
//                            if count == goal {
//                                Task {
//                                    do {
//                                        try await self.viewModel.awardPoints(10, reason: "Completed habit: \(title)")
//                                        print("Awarded 10 points for completing habit: \(title)")
//                                    } catch {
//                                        print("Failed to award points: \(error.localizedDescription)")
//                                    }
//                                }
//                            }
                            return habit
                        }
                        return nil
                    }
                    
                    
                    print(habitsData)
                    print(habits)
                    self.updateAllHabitProgress()
                }
            } else {
                print("Document does not exist or error: \(error?.localizedDescription ?? "unknown error")")
                habits = []
            }
        }
    }
    
    



    // Updated updateHabit function
    private func updateHabit(by habitId: String, increment: Int) {
        guard let user = viewModel.currentUser else {
            print("No current user")
            return
        }
        
        let userID = user.id
        let dateString = dateString(for: selectedDate)

        let documentRef = db.collection("users").document(userID).collection("habits").document(dateString)

        documentRef.getDocument { document, error in
            if let document = document, document.exists {
                if var habitsData = document.data()?["habits"] as? [[String: Any]] {
                    if let index = habitsData.firstIndex(where: { $0["id"] as? String == habitId }) {
                        var habitData = habitsData[index]
                        let currentCount = habitData["count"] as? Int ?? 0
                        let goal = habitData["goal"] as? Int ?? 0
                        let newCount = min(max(0, currentCount + increment), goal)
                        habitData["count"] = newCount
                        habitsData[index] = habitData
                        
                        documentRef.setData(["habits": habitsData], merge: true) { error in
                            if let error = error {
                                print("Error updating habit: \(error.localizedDescription)")
                            } else {
                                print("Habit updated successfully!")
                                loadHabits(for: selectedDate)
                                self.updateAllHabitProgress()
                                if newCount >= goal {
                                    print("Habit \(habitData["title"] as? String ?? "") completed!")
                                    // Optional: Add reward or notification
                                    Task {
                                        do {
                                            try await self.viewModel.awardPoints(10, reason: "Completed habit: \(habitData["title"] as? String ?? "")")
                                            print("Awarded 10 points for completing habit")
                                        } catch {
                                            print("Failed to award points: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                print("Document does not exist or error: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }

    
    private func loadHabitHistory() {
        guard let user = viewModel.currentUser else {
            print("No current user")
            return
        }
        let userID = user.id
        
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -30, to: endDate)!
        
        var currentDate = startDate
        while currentDate <= endDate {
            let dateString = dateString(for: currentDate)
            
            db.collection("users").document(userID).collection("habits").document(dateString).getDocument { document, error in
                if let document = document, document.exists {
                    if let data = document.data(), let habitsData = data["habits"] as? [[String: Any]] {
                        let validHabits = habitsData.compactMap { habitData -> Habit? in
                            return createHabit(from: habitData)
                        }
                        
                        DispatchQueue.main.async {
                            // Group habits by title
                            for habit in validHabits {
                                var existingHabits = self.habitsByName[habit.title] ?? []
                                existingHabits.append(habit)
                                self.habitsByName[habit.title] = existingHabits
                            }
                        }
                    }
                } else if let error = error {
                    print("Error fetching document for \(dateString): \(error.localizedDescription)")
                }
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
    }
        
    private func updateHabitProgress(for dateString: String, habits: [Habit]) {
        let totalProgress = habits.reduce(CGFloat(0)) { $0 + min(CGFloat($1.count) / CGFloat($1.goal), 1.0) }
        let averageProgress = habits.isEmpty ? 0 : totalProgress / CGFloat(habits.count)
        habitProgress[dateString] = averageProgress
    }
    

    private func updateAllHabitProgress() {
        guard let user = viewModel.currentUser else {
            print("No current user")
            return
        }
        let userID = user.id
        
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .day, value: 7, to: Date())! // +7 days from today
        let startDate = calendar.date(byAdding: .day, value: -3, to: Date())! // -3 days from today
        
        var currentDate = startDate
        while currentDate <= endDate {
            let dateString = dateString(for: currentDate)
            
            db.collection("users").document(userID).collection("habits").document(dateString).getDocument { document, error in
                if let document = document, document.exists {
                    if let data = document.data(), let habitsData = data["habits"] as? [[String: Any]] {
                        var validHabits: [Habit] = []
                        for habitData in habitsData {
                            if let habit = createHabit(from: habitData) {
                                validHabits.append(habit)
                            }
                        }
                        DispatchQueue.main.async {
                            self.updateHabitProgress(for: dateString, habits: validHabits)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        // Set progress to 0 for dates without data
                        self.habitProgress[dateString] = 0
                    }
                    if let error = error {
                        print("Error fetching document for \(dateString): \(error.localizedDescription)")
                    }
                }
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
    }
    
    private func loadAllHabits() {
        guard let user = viewModel.currentUser else { return }
        let userID = user.id

        let habitsRef = db.collection("users").document(userID).collection("habits")

        habitsRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }

            var groupedHabits: [String: [Habit]] = [:]

            snapshot?.documents.forEach { document in
                if let data = document.data()["habits"] as? [[String: Any]] {
                    data.forEach { habitData in
                        if let habit = createHabit(from: habitData) {
                            groupedHabits[habit.title, default: []].append(habit)
                        }
                    }
                }
            }

            DispatchQueue.main.async {
                self.habitsByName = groupedHabits
            }
        }
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
    
    private func processHabitsGroupedByName(_ habitsByName: [String: [Habit]]) {
        // Process grouped habits (e.g., analytics, update UI)
        // Example: Print the grouped habits
        for (title, habits) in habitsByName {
            print("Habit: \(title), Instances: \(habits.count)")
        }
    }
}



struct IncrementPopup: View {
    let habitId: String
    let habits: [Habit]
    var onIncrement: (Int) -> Void

    var body: some View {
        VStack {
            Text("Update Habit")
                .font(.headline)
                .padding()

            if let habit = habits.first(where: { $0.id == habitId }) {
                Text(habit.title)
                    .font(.title)
                    .padding()

                HStack {
                    Button(action: {
                        onIncrement(-1)
                    }) {
                        Text("-")
                            .font(.largeTitle)
                            .frame(width: 60, height: 60)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }

                    Text("\(habit.count)")
                        .font(.largeTitle)
                        .padding(.horizontal, 20)

                    Button(action: {
                        onIncrement(1)
                    }) {
                        Text("+")
                            .font(.largeTitle)
                            .frame(width: 60, height: 60)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
                .padding()

//                List {
//                    ForEach(habit.history, id: \.self) { historyItem in
//                        HStack {
//                            Text(historyItem.date)
//                                .foregroundColor(.gray)
//                            Spacer()
//                            Text("\(historyItem.count)")
//                        }
//                    }
//                }
                .padding(.horizontal)
            } else {
                Text("Habit not found")
            }

            Button(action: {
                onIncrement(0)
            }) {
                Text("Close")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}

import SwiftUI

struct HabitTemplate: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let defaultUnit: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: HabitTemplate, rhs: HabitTemplate) -> Bool {
        return lhs.id == rhs.id
    }
}
struct AddHabitForm: View {
    @State private var habitTitle: String = ""
    @State private var habitUnit: String = ""
    @State private var habitGoal: Int = 1
    @State private var selectedTemplate: HabitTemplate?
    @State private var category: String = "Health"
    @State private var frequency: String = "Daily"
    @State private var reminder: Date = Date()
    @State private var startColor: Color = .blue
    @State private var endColor: Color = .purple
    @State private var routineTime: Habit.RoutineTime = .anytime
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    @State private var shouldAddToReminders: Bool = false // Add this property
    @State private var frequencyType: Habit.FrequencyType = .daily
    @State private var interval: Int = 1
    @State private var selectedDaysOfWeek: [Int] = [] // 1 = Sunday, ..., 7 = Saturday
    @State private var specificDates: [Date] = []
    @Environment(\.dismiss) var dismiss

    let habitTemplates: [HabitTemplate] = [
        HabitTemplate(name: "Exercise", defaultUnit: "minutes"),
        HabitTemplate(name: "Reading", defaultUnit: "pages"),
        HabitTemplate(name: "Meditation", defaultUnit: "minutes"),
        HabitTemplate(name: "Water Intake", defaultUnit: "glasses")
    ]
    
    var addHabitAction: (Habit) -> Void

    let categories = ["Health", "Productivity", "Personal Growth", "Other"]
    let frequencies = ["Daily", "Weekly", "Monthly"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Habit Details")) {
                    // Existing fields for title, unit, and goal
                    // ...
                    Picker("Select Template", selection: $selectedTemplate) {
                        Text("Custom").tag(HabitTemplate?.none)
                        ForEach(habitTemplates) { template in
                            Text(template.name).tag(HabitTemplate?.some(template))
                        }
                    }
                    .onChange(of: selectedTemplate) { newValue in
                        if let template = newValue {
                            habitTitle = template.name
                            habitUnit = template.defaultUnit
                        } else {
                            habitTitle = ""
                            habitUnit = ""
                        }
                    }

                    if selectedTemplate == nil {
                        TextField("Custom Habit", text: $habitTitle)
                    }

                    TextField("Unit", text: $habitUnit)
                        .disabled(selectedTemplate != nil)
                }

                Section(header: Text("Goal")) {
                    Stepper("Daily Goal: \(habitGoal) \(habitUnit)", value: $habitGoal, in: 1...100)
                }


                
                
                Section(header: Text("Schedule")) {
                      DatePicker("End Date", selection: $endDate, displayedComponents: [.date])
                      
                      Picker("Category", selection: $category) {
                          ForEach(categories, id: \.self) { Text($0) }
                      }
                      
                    Picker("Frequency", selection: $frequencyType) {
                        Text("Daily").tag(Habit.FrequencyType.daily)
                        Text("Weekly").tag(Habit.FrequencyType.weekly)
                        Text("Monthly").tag(Habit.FrequencyType.monthly)
                        Text("Every N Days").tag(Habit.FrequencyType.everyNDays)
                        Text("Specific Days of Week").tag(Habit.FrequencyType.specificDaysOfWeek)
                        //Text("Custom Dates").tag(Habit.FrequencyType.customDates)
                        
                    }
                    
                    Group {
                        switch frequencyType {
                        case .everyNDays:
                            Stepper("Every \(interval) days", value: $interval, in: 1...30)
                        case .specificDaysOfWeek:
                            MultipleSelectionRow(title: "Select Days", options: [1, 2, 3, 4, 5, 6, 7], selectedOptions: $selectedDaysOfWeek)
                        default:
                            EmptyView()
                        }
                    }
                    
                    
                      
                      Picker("Routine Time", selection: $routineTime) {
                          ForEach(Habit.RoutineTime.allCases, id: \.self) { routineTime in
                              Text(routineTime.rawValue).tag(routineTime)
                          }
                      }
                      
                      //DatePicker("Reminder", selection: $reminder, displayedComponents: [.hourAndMinute])
                  }
                
                
                Section(header: Text("Reminder Options")) {
                    Toggle("Add to Reminders App", isOn: $shouldAddToReminders)
                    if shouldAddToReminders {
                        DatePicker("Reminder Date", selection: $reminder, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                

                Section(header: Text("Habit Color")) {
                    ColorPicker("Start Color", selection: $startColor)
                    ColorPicker("End Color", selection: $endColor)
                }

                Section {
                    Button(action: addHabit) {
                        Text("Add Habit")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(habitTitle.isEmpty || habitUnit.isEmpty)
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func addHabit() {
        let newHabit = Habit(
            id: UUID().uuidString,
            title: habitTitle,
            unit: habitUnit,
            count: 0,
            goal: habitGoal,
            startColor: startColor.toHex() ?? "#0000FF",
            endColor: endColor.toHex() ?? "#800080",
            category: category,
            frequency: frequencyType, // Use frequencyType directly
            reminder: shouldAddToReminders ? reminder : nil,
            routineTime: routineTime,
            endDate: endDate, // Provide startDate
            dateTaken: "",
            startDate: Date(),
            interval: frequencyType == .everyNDays ? interval : nil,
            daysOfWeek: frequencyType == .specificDaysOfWeek ? selectedDaysOfWeek : nil
        )
        addHabitAction(newHabit)

        if shouldAddToReminders {
            Task {
                var recurrenceRule: EKRecurrenceRule? = nil

                switch frequencyType {
                case .daily:
                    recurrenceRule = EventKitManager.shared.createRecurrenceRule(frequency: .daily)
                case .weekly:
                    recurrenceRule = EventKitManager.shared.createRecurrenceRule(frequency: .weekly)
                case .monthly:
                    recurrenceRule = EventKitManager.shared.createRecurrenceRule(frequency: .monthly)
                case .everyNDays:
                    recurrenceRule = EventKitManager.shared.createRecurrenceRuleForEveryNDays(interval: interval, endDate: endDate)
                case .specificDaysOfWeek:
                    recurrenceRule = EventKitManager.shared.createRecurrenceRuleForSpecificDaysOfWeek(daysOfWeek: selectedDaysOfWeek, endDate: endDate)
                    break
                }

                _ = await EventKitManager.shared.scheduleReminder(
                    title: habitTitle,
                    notes: "Don't forget to complete your habit!",
                    dueDate: reminder,
                    recurrenceRule: recurrenceRule
                )
            }
        }

        dismiss()
    }
}

struct MultipleSelectionRow: View {
    let title: String
    let options: [Int]
    @Binding var selectedOptions: [Int]

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            ForEach(options, id: \.self) { option in
                Button(action: {
                    if selectedOptions.contains(option) {
                        selectedOptions.removeAll(where: { $0 == option })
                    } else {
                        selectedOptions.append(option)
                    }
                }) {
                    HStack {
                        Text(dayName(for: option))
                        Spacer()
                        if selectedOptions.contains(option) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
    }

    func dayName(for weekday: Int) -> String {
        let formatter = DateFormatter()
        return formatter.weekdaySymbols[weekday - 1]
    }
}

struct AnalyticsView2: View {
    let habitHistory: [Habit]
    let habitTitle: String
    @State private var showLineChart = true
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("", selection: $showLineChart) {
                    Text("Line Chart").tag(true)
                    Text("Bar Chart").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if habitHistory.isEmpty {
                    Text("No data available")
                        .font(.headline)
                        .padding()
                } else {
                    Chart {
                        ForEach(sortedHabitHistory) { habit in
                            if let date = parseDate(from: habit.dateTaken) {
                                if showLineChart {
                                    LineMark(
                                        x: .value("Date", date),
                                        y: .value("Count", habit.count)
                                    )
                                    .foregroundStyle(Color.blue)
                                } else {
                                    BarMark(
                                        x: .value("Date", date),
                                        y: .value("Count", habit.count)
                                    )
                                    .foregroundStyle(Color.green)
                                }
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
            }
            .navigationTitle("Analytics for \(habitTitle)")
        }
    }
    
    func parseDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Adjust to your date format
        return dateFormatter.date(from: dateString)
    }
    
    // Sort the habitHistory by date
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
