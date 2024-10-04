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
    @Binding var currentValue: Int // Now it is a binding so you can modify the value
    var totalValue: Int
    var unit: String
    var endColor: Color
    var startColor: Color
    @Binding var habit: Habit // Pass the habit object
      var saveHabit: (String, Int) -> Void // Pass the saveHabit function
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
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { value in
                    // Use geometry proxy inside the gesture closure
                    let progress = min(max(0, value.location.x / geometry.size.width), 1)
                    let newCount = Int(progress * CGFloat(totalValue))
                    currentValue = newCount // Update currentValue based on the progress
                }
                .onEnded { value in
                    habit.count = currentValue
                    saveHabit(habit.id, currentValue)
                }
            )
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
        case anytime = "All"
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
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "title": title,
            "unit": unit,
            "count": count,
            "goal": goal,
            "startColor": startColor,
            "endColor": endColor,
            "category": category,
            "frequency": frequency.rawValue,
            "routineTime": routineTime.rawValue,
            "startDate": Timestamp(date: startDate),
            "endDate": Timestamp(date: endDate),
            "dateTaken": dateTaken
        ]
        
        if let reminder = reminder {
            dict["reminder"] = Timestamp(date: reminder)
        } else {
            dict["reminder"] = NSNull()
        }
        
        if let interval = interval {
            dict["interval"] = interval
        } else {
            dict["interval"] = NSNull()
        }
        
        if let daysOfWeek = daysOfWeek {
            dict["daysOfWeek"] = daysOfWeek
        } else {
            dict["daysOfWeek"] = NSNull()
        }
        
        if let specificDates = specificDates {
            dict["specificDates"] = specificDates.map { Timestamp(date: $0) }
        } else {
            dict["specificDates"] = NSNull()
        }
        
        return dict
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
    @State private var selectedHabitForAnalytics: Habit? = nil
    @State private var habitHistory: [String: [Habit]] = [:]
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var habitsByName: [String: [Habit]] = [:]
    @State private var isEditing: Bool = false // Added for edit mode
    @State private var isDeleting: Bool = false // Added for delete mode
    private var db = Firestore.firestore()
    @State var customGroups: [Groups] = []
    @State private var selectedGroup: String = "All"
    let predefinedGroups = ["All", "Health", "Productivity", "Fitness"]
    @State private var showingHabitIndividualView: Bool = false
    @State private var selectedHabit: Habit? = nil
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
                        ForEach(predefinedGroups, id: \.self) { group in
                            Button(group) {
                                selectedGroup = group
                            }
                        }
                        ForEach(customGroups) { group in
                            Button(group.name) {
                                selectedGroup = group.name
                            }
                        }
                    } label: {
                        Text(selectedGroup)
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
                                        .stroke(Calendar.current.isDate(selectedDate, inSameDayAs: date) ? Color.green : Color.clear, lineWidth: 2)
                                        .background(
                                            Calendar.current.isDateInToday(date) ? Color.black.opacity(0.4) :
                                            (Calendar.current.isDate(selectedDate, inSameDayAs: date) ? Color.white.opacity(0.3) : Color.gray.opacity(0.0))
                                        )
                                        .cornerRadius(8)
                                        .frame(width: 50, height: 80)

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
                    VStack(spacing: 23) {
                        if filteredHabits.isEmpty {
                            Text("No tasks for the selected day")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.top, 20)
                        } else {
                            ForEach(filteredHabits, id: \.id ) { $habit in
                                ZStack(alignment: .topTrailing) {
                                    ProgressView(value: CGFloat(habit.count) / CGFloat(habit.goal))
                                        .progressViewStyle(GradientProgressViewStyleWithLabel2(
                                            title: habit.title,
                                            currentValue: $habit.count,
                                            totalValue: habit.goal,
                                            unit: habit.unit,
                                            endColor: Color(hex: habit.endColor)!,
                                            startColor: Color(hex: habit.startColor)!,
                                            habit: $habit,
                                            saveHabit: updateHabitNew
                                        ))
                                        .onTapGesture {
                                            if isEditing {
                                                selectedHabitForAnalytics = habit
                                                showingAnalytics.toggle()
                                                showingAddHabitForm = true
                                            } else if isDeleting {
                                                print("Delete pressed for \(habit.title)")
                                            }
                                        }
                                        .padding(.horizontal, 5)

                                    Button(action: {
                                        selectedHabit = habit
                                        showingHabitIndividualView = true
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 20, height: 20)

                                            Image(systemName: "pencil.circle.fill")
                                                .foregroundColor(.black)
                                                .frame(width: 10, height: 10)
                                        }
                                    }
                                    .padding(.trailing, 5)
                                    .padding(.top, -5)
                                }
                            }
                        }
                    }
                    .frame(minHeight: 0, maxHeight: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 60) // Extend the scroll view further down to avoid overlap with button
                }

                Spacer()
            }

            // Floating "Add Habit" button
            VStack {
                Spacer() // Pushes the button to the bottom
                HStack {
                    Spacer()
                    Button(action: {
                        showingAddHabitForm.toggle()
                    }) {
                        HStack {
                            Text("Add Habit")
                                .font(.custom("SFProText-Bold", size: 14))
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                        }
                        .padding()
                        .background(Color.white.opacity(0.8)) // Transparent background
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                        .shadow(color: .gray, radius: 5, x: 0, y: 5) // Shadow effect
                    }
                    .padding(.trailing, 20) // Add padding to float it from the right side
                    .padding(.bottom, 20)   // Padding to position it above the bottom of the screen
                }
            }
        }
        .sheet(isPresented: $showingAddHabitForm) {
            AddHabitForm() { newHabit in
                habits.append(newHabit)
                saveHabit(newHabit)
                fetchGroups()
            }
        }
        .sheet(item: $selectedHabitForAnalytics, onDismiss: {
            selectedHabitForAnalytics = nil
        }) { habit in
            AnalyticsView2(
                habitHistory: habitsByName[habit.title] ?? [],
                habitTitle: habit.title,
                habitid: habit.id
            )
            .environmentObject(viewModel)
        }
        .sheet(item: $selectedHabit, onDismiss: {
            selectedHabit = nil
            loadAllHabits();
            loadHabits(for: selectedDate)
        }) { habit in
            HabitIndividualView(habit: habit, selectedDate: selectedDate)
                .environmentObject(viewModel)
        }
        .onAppear {
            loadHabits(for: selectedDate)
            loadHabitHistory()
            updateAllHabitProgress()
            fetchGroups()
            viewModel.loadHabitHistory()
        }
    }
    
    private var filteredHabits: [Binding<Habit>] {
        let filtered = selectedGroup == "All" ? habits : habits.filter { $0.category == selectedGroup }
        return filtered.map { habit in
            Binding(
                get: { habit },
                set: { newValue in
                    if let index = habits.firstIndex(where: { $0.id == habit.id }) {
                        habits[index] = newValue
                    }
                }
            )
        }
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
    
    private func updateHabitNew(by habitId: String, newCount: Int) {
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
                        //let newCount = min(max(0, currentCount + increment), goal)
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
    
    func fetchGroups() {
        guard let userID = Auth.auth().currentUser?.uid else {
            //completion(.failure(NSError(domain: "User not authenticated", code: 401, userInfo: nil)))
            return
        }
        
        db.collection("groups")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching groups: \(error)")
                    return
                }
                
                self.customGroups = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Groups.self)
                } ?? []
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

import Foundation
import FirebaseFirestoreSwift

struct Groups: Identifiable, Codable, Equatable {
    @DocumentID var id: String? // Firestore document ID
    let name: String
    let userID: String // Reference to the user
    
    // Conform to Equatable for comparison
    static func == (lhs: Groups, rhs: Groups) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.userID == rhs.userID
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
    let emoji: String
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
    @State private var habitGoal: String = "" // Now using a string for direct input
    @State private var category: String = "Health"
    @State private var frequencyType: Habit.FrequencyType = .daily
    @State private var reminder: Date = Date()
    @State private var startColor: Color = .blue
    @State private var endColor: Color = .purple
    @State private var routineTime: Habit.RoutineTime = .anytime
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    @State private var shouldAddToReminders: Bool = false // Add to Reminders flag
    @State private var interval: Int = 1
    @State private var selectedDaysOfWeek: [Int] = []
    @State private var specificDates: [Date] = []
    @State var customGroups: [Groups] = []
    
    @State private var isAddingCustomGroup: Bool = false
    @State private var newGroupName: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var db = Firestore.firestore()

    @State private var showingTemplateSelection = true
    @Environment(\.dismiss) var dismiss

    let habitTemplates: [HabitTemplate] = [
        HabitTemplate(name: "Exercise", emoji: "🏋️‍♂️", defaultUnit: "minutes"),
        HabitTemplate(name: "Reading", emoji: "📖", defaultUnit: "pages"),
        HabitTemplate(name: "Meditation", emoji: "🧘‍♂️", defaultUnit: "minutes"),
        HabitTemplate(name: "Water Intake", emoji: "💧", defaultUnit: "glasses"),
        HabitTemplate(name: "Study", emoji: "📚", defaultUnit: "hours"),
        HabitTemplate(name: "Walk", emoji: "🚶‍♂️", defaultUnit: "minutes"),
        HabitTemplate(name: "Run", emoji: "🏃‍♂️", defaultUnit: "minutes"),
        HabitTemplate(name: "Bike", emoji: "🚴‍♂️", defaultUnit: "minutes"),
        HabitTemplate(name: "Burn Calories", emoji: "🔥", defaultUnit: "calories"),
        HabitTemplate(name: "Learning", emoji: "🧠", defaultUnit: "hours")
    ]

    //let categories = ["Physical Health", "Mental Wellbeing", "Personal Growth", "Custom"]
    
    let categories = ["Health", "Productivity", "Fitness"]


    var addHabitAction: (Habit) -> Void

    var body: some View {
        NavigationView {
            VStack {
                if showingTemplateSelection {
                    // Template Selection List
                    List {
                        ForEach(habitTemplates) { template in
                            Button(action: {
                                habitTitle = template.name
                                habitUnit = template.defaultUnit
                                showingTemplateSelection = false
                            }) {
                                HStack {
                                    Text(template.emoji) // Emoji corresponding to the habit type
                                    Text(template.name)
                                        .font(.custom("SFProText-Bold", size: 16)) // SF Pro Text Bold
                                }
                            }
                        }

                        // Custom Habit Button
                        Button(action: {
                            habitTitle = ""
                            habitUnit = ""
                            showingTemplateSelection = false
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Custom Habit")
                            }
                            .font(.custom("SFProText-Bold", size: 16)) // SF Pro Text Bold
                        }
                        .foregroundColor(.blue)
                    }
                    .navigationTitle("Select a Habit Template")
                    .navigationBarTitleDisplayMode(.inline)
                    .font(.custom("SFProText-Bold", size: 16)) // SF Pro Text Bold
                } else {
                    // Habit Form
                    Form {
                        Section(header: Text("Habit Details").font(.custom("SFProText-Bold", size: 16))) {
                            TextField("Habit Title", text: $habitTitle)
                                .font(.custom("SFProText-Bold", size: 16))
                            TextField("Unit", text: $habitUnit)
                                .disabled(habitTemplates.map { $0.name }.contains(habitTitle))
                                .font(.custom("SFProText-Bold", size: 16))
                        }

                        Section(header: Text("Goal").font(.custom("SFProText-Bold", size: 16))) {
                            TextField("Daily Goal", text: $habitGoal)
                                .keyboardType(.numberPad)
                                .font(.custom("SFProText-Bold", size: 16))
                        }

                        Section(header: Text("Schedule").font(.custom("SFProText-Bold", size: 16))) {
                            DatePicker("End Date", selection: $endDate, displayedComponents: [.date])
                                .font(.custom("SFProText-Bold", size: 16))

                            
                            
                            Picker("Group", selection: $category) {
                                ForEach(categories, id: \.self) { Text($0) }
                                ForEach(customGroups) { group in
                                    Text(group.name).tag(group.name)
                                }
                                Text("Custom").tag("Custom")
                            }
                            
                            
                            if category == "Custom" || customGroups.map({ $0.name }).contains(category) == false {
                                           if category == "Custom" {
                                               // Show text field to add a new custom group
                                               VStack(alignment: .leading) {
                                                   TextField("New Group Name", text: $newGroupName)
                                                       .textFieldStyle(RoundedBorderTextFieldStyle())
                                                       .font(.custom("SFProText-Bold", size: 16))
                                                   
                                                   Button(action: {
                                                       addNewGroup()
                                                   }) {
                                                       Text("Add Group")
                                                           .frame(maxWidth: .infinity)
                                                           .padding()
                                                           .background(Color.blue)
                                                           .foregroundColor(.white)
                                                           .cornerRadius(8)
                                                   }
                                                   .disabled(newGroupName.trimmingCharacters(in: .whitespaces).isEmpty)
                                                   .font(.custom("SFProText-Bold", size: 16))
                                                   .padding(.top, 5)
                                               }
                                               .padding(.vertical, 5)
                                           }
                                       }

                            // Frequency picker
                            Picker("Frequency", selection: $frequencyType) {
                                Text("Daily").tag(Habit.FrequencyType.daily)
                                Text("Weekly").tag(Habit.FrequencyType.weekly)
                                Text("Monthly").tag(Habit.FrequencyType.monthly)
                                Text("Every N Days").tag(Habit.FrequencyType.everyNDays)
                                Text("Specific Days of Week").tag(Habit.FrequencyType.specificDaysOfWeek)
                            }
                            .pickerStyle(MenuPickerStyle())
                            .font(.custom("SFProText-Bold", size: 16))

                            if frequencyType == .everyNDays {
                                Stepper("Every \(interval) days", value: $interval, in: 1...30)
                                    .font(.custom("SFProText-Bold", size: 16))
                            } else if frequencyType == .specificDaysOfWeek {
                                MultipleSelectionRow(title: "Select Days", options: [1, 2, 3, 4, 5, 6, 7], selectedOptions: $selectedDaysOfWeek)
                                    .font(.custom("SFProText-Bold", size: 16))
                            }
                        }

                        Section(header: Text("Reminder Options").font(.custom("SFProText-Bold", size: 16))) {
                            Toggle("Add to Reminders App", isOn: $shouldAddToReminders)
                                .font(.custom("SFProText-Bold", size: 16))

                            if shouldAddToReminders {
                                DatePicker("Reminder Date", selection: $reminder, displayedComponents: [.date, .hourAndMinute])
                                    .font(.custom("SFProText-Bold", size: 16))
                            }
                        }

                        Section(header: Text("Habit Color").font(.custom("SFProText-Bold", size: 16))) {
                            ColorPicker("Start Color", selection: $startColor)
                                .font(.custom("SFProText-Bold", size: 16))
                            ColorPicker("End Color", selection: $endColor)
                                .font(.custom("SFProText-Bold", size: 16))
                        }

                        Section {
                            Button(action: addHabit) {
                                Text("Add Habit")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.navyBlue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .font(.custom("SFProText-Bold", size: 16))
                            }
                            .disabled(habitTitle.isEmpty || habitUnit.isEmpty || habitGoal.isEmpty)
                        }
                    }
                    .navigationTitle("New Habit")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Back") {
                                showingTemplateSelection = true
                            }
                            .font(.custom("SFProText-Bold", size: 16))
                        }
                    }
                }
            }
            .onAppear {
                // Fetch groups when the view appears
                fetchGroups()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func addNewGroup() {
        let trimmedName = newGroupName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            alertMessage = "Group name cannot be empty."
            showAlert = true
            return
        }
        
        // Check if the group already exists
        if customGroups.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) {
            alertMessage = "A group with this name already exists."
            showAlert = true
            return
        }
        
        addGroup(name: trimmedName) { result in
            switch result {
            case .success():
                // Clear the text field and dismiss keyboard
                newGroupName = ""
                // Optionally, set the selected category to the new group
                category = trimmedName
            case .failure(let error):
                alertMessage = "Failed to add group: \(error.localizedDescription)"
                showAlert = true
            }
        }
        fetchGroups()
    }
    
    func fetchGroups() {
        guard let userID = Auth.auth().currentUser?.uid else {
            //completion(.failure(NSError(domain: "User not authenticated", code: 401, userInfo: nil)))
            return
        }
        
        db.collection("groups")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching groups: \(error)")
                    return
                }
                
                self.customGroups = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Groups.self)
                } ?? []
            }
    }

    func addGroup(name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "User not authenticated", code: 401, userInfo: nil)))
            return
        }
        
        let newGroup = Groups(id: nil, name: name, userID: userID)
        
        do {
            _ = try db.collection("groups").addDocument(from: newGroup) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch let error {
            completion(.failure(error))
        }
    }


    private func addHabit() {
            guard let goalInt = Int(habitGoal) else {
                alertMessage = "Please enter a valid goal."
                showAlert = true
                return
            }
            
            // Ensure that if a new group was created, it's already added
            let selectedCategory = category
            
            let newHabit = Habit(
                id: UUID().uuidString,
                title: habitTitle,
                unit: habitUnit,
                count: 0,
                goal: goalInt,
                startColor: startColor.toHex() ?? "#0000FF",
                endColor: endColor.toHex() ?? "#800080",
                category: selectedCategory,
                frequency: frequencyType,
                reminder: shouldAddToReminders ? reminder : nil,
                routineTime: routineTime,
                endDate: endDate,
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
    let habitid: String
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showLineChart = true
    @State private var showingEditForm = false
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "112864")!, Color(hex: "23429a")!]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

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
                            .foregroundColor(.white)  // Ensure text is visible on dark background
                    } else {
                        Chart {
                            ForEach(sortedHabitHistory) { habit in
                                if let date = parseDate(from: habit.dateTaken) {
                                    if showLineChart {
                                        LineMark(
                                            x: .value("Date", date),
                                            y: .value("Count", habit.count)
                                        )
                                        .foregroundStyle(Color.white)  // Set the line color to white
                                    } else {
                                        BarMark(
                                            x: .value("Date", date),
                                            y: .value("Count", habit.count)
                                        )
                                        .foregroundStyle(Color.white)  // Set the bar color to white
                                    }
                                }
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel(format: .dateTime.month().day())
                                    .foregroundStyle(.white)  // Set the axis label color to white
                            }
                        }
                        .chartYAxis {
                            AxisMarks { value in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel()
                                    .foregroundStyle(.white)  // Set the axis label color to white
                            }
                        }
                        .frame(height: 300)
                        .padding()

                    }

                    Spacer()

                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("Analytics for \(habitTitle)")
                                .font(.custom("SFProText-Heavy", size: 30))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil) // Allow multiple lines
                                .fixedSize(horizontal: false, vertical: true) // Let the text expand vertically
                                .padding(.top, 50) // Add padding to the top

                        }
                    }
                }

                .sheet(isPresented: $showingEditForm) {
                    if let baseHabit = baseHabit() {
                        EditHabitForm(habit: baseHabit, updateAction: { updatedHabit in
                            updateHabit(updatedHabit: updatedHabit)
                        })
                        .environmentObject(viewModel)
                    } else {
                        Text("Error: Unable to load habit data.")
                    }
                }
                .alert(isPresented: $showDeleteConfirmation) {
                    Alert(
                        title: Text("Delete Habit"),
                        message: Text("Are you sure you want to delete this habit? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteHabit()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .onAppear {
                print("Analytics for \(habitTitle)")
                print(habitHistory)
            }
        }
    }

    
    // Helper to parse date string to Date
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
    
    // Obtain a base habit from the habitHistory (assuming all habits have the same data except dateTaken)
    func baseHabit() -> Habit? {
        return habitHistory.first
    }
    
    // MARK: - Update Habit
    func updateHabit(updatedHabit: Habit) {
        guard let user = viewModel.currentUser else {
            print("No current user")
            return
        }
        let userID = user.id
        let db = Firestore.firestore()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        db.collection("users").document(userID).collection("habits").getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching habit documents: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No habit documents found")
                return
            }
            
            let batch = db.batch()
            let updatedHabitDict = updatedHabit.toDictionary()
            
            for document in documents {
                var habits = document.get("habits") as? [[String: Any]] ?? []
                var updated = false
                for (index, habit) in habits.enumerated() {
                    if let habitId = habit["id"] as? String, habitId == updatedHabit.id {
                        // Update the habit's fields
                        var newHabit = habit
                        newHabit["title"] = updatedHabit.title
                        newHabit["unit"] = updatedHabit.unit
                        newHabit["goal"] = updatedHabit.goal
                        newHabit["startColor"] = updatedHabit.startColor
                        newHabit["endColor"] = updatedHabit.endColor
                        newHabit["category"] = updatedHabit.category
                        newHabit["frequency"] = updatedHabit.frequency.rawValue
                        newHabit["routineTime"] = updatedHabit.routineTime.rawValue
                        newHabit["endDate"] = Timestamp(date: updatedHabit.endDate)
                        
                        if let reminderDate = updatedHabit.reminder {
                            newHabit["reminder"] = Timestamp(date: reminderDate)
                        } else {
                            newHabit["reminder"] = NSNull()
                        }
                        
                        if let interval = updatedHabit.interval {
                            newHabit["interval"] = interval
                        } else {
                            newHabit["interval"] = NSNull()
                        }
                        
                        if let daysOfWeek = updatedHabit.daysOfWeek {
                            newHabit["daysOfWeek"] = daysOfWeek
                        } else {
                            newHabit["daysOfWeek"] = NSNull()
                        }
                        
                        if let specificDates = updatedHabit.specificDates {
                            newHabit["specificDates"] = specificDates.map { Timestamp(date: $0) }
                        } else {
                            newHabit["specificDates"] = NSNull()
                        }
                        
                        habits[index] = newHabit
                        updated = true
                    }
                }
                if updated {
                    batch.updateData(["habits": habits], forDocument: document.reference)
                }
            }
            
            batch.commit { error in
                if let error = error {
                    print("Error updating habit: \(error.localizedDescription)")
                } else {
                    print("Habit updated successfully across all dates.")
                    // Optionally, you can trigger a data refresh here
                }
            }
        }
    }
    
    // MARK: - Delete Habit
    func deleteHabit() {
        guard let user = viewModel.currentUser else {
            print("No current user")
            return
        }
        let userID = user.id
        let db = Firestore.firestore()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        db.collection("users").document(userID).collection("habits").getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching habit documents: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No habit documents found")
                return
            }
            
            let batch = db.batch()
            
            for document in documents {
                var habits = document.get("habits") as? [[String: Any]] ?? []
                let originalCount = habits.count
                habits.removeAll { $0["id"] as? String == habitid }
                
                if habits.count != originalCount {
                    batch.updateData(["habits": habits], forDocument: document.reference)
                }
            }
            
            batch.commit { error in
                if let error = error {
                    print("Error deleting habit: \(error.localizedDescription)")
                } else {
                    print("Habit deleted successfully from all dates.")
                    // Optionally, dismiss the AnalyticsView or refresh data
                }
            }
        }
    }
}

struct EditHabitForm: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var habitTitle: String
    @State private var habitUnit: String
    @State private var habitGoal: String
    @State private var category: String
    @State private var frequencyType: Habit.FrequencyType
    @State private var reminder: Date
    @State private var startColor: Color
    @State private var endColor: Color
    @State private var routineTime: Habit.RoutineTime
    @State private var endDate: Date
    @State private var shouldAddToReminders: Bool
    @State private var interval: Int
    @State private var selectedDaysOfWeek: [Int]
    @State private var specificDates: [Date]
    @State var customGroups: [Groups] = []
    
    @State private var isAddingCustomGroup: Bool = false
    @State private var newGroupName: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var db = Firestore.firestore()
    
    let habitToEdit: Habit
    let updateHabitAction: (Habit) -> Void
    
    let habitTemplates: [HabitTemplate] = [
        HabitTemplate(name: "Exercise", emoji: "🏋️‍♂️", defaultUnit: "minutes"),
        HabitTemplate(name: "Reading", emoji: "📖", defaultUnit: "pages"),
        HabitTemplate(name: "Meditation", emoji: "🧘‍♂️", defaultUnit: "minutes"),
        HabitTemplate(name: "Water Intake", emoji: "💧", defaultUnit: "glasses"),
        HabitTemplate(name: "Study", emoji: "📚", defaultUnit: "hours"),
        HabitTemplate(name: "Walk", emoji: "🚶‍♂️", defaultUnit: "minutes"),
        HabitTemplate(name: "Run", emoji: "🏃‍♂️", defaultUnit: "minutes"),
        HabitTemplate(name: "Bike", emoji: "🚴‍♂️", defaultUnit: "minutes"),
        HabitTemplate(name: "Burn Calories", emoji: "🔥", defaultUnit: "calories"),
        HabitTemplate(name: "Learning", emoji: "🧠", defaultUnit: "hours")
    ]
    
    let categories = ["Health", "Productivity", "Fitness"]
    
    init(habit: Habit, updateAction: @escaping (Habit) -> Void) {
        self.habitToEdit = habit
        self.updateHabitAction = updateAction
        _habitTitle = State(initialValue: habit.title)
        _habitUnit = State(initialValue: habit.unit)
        _habitGoal = State(initialValue: String(habit.goal))
        _category = State(initialValue: habit.category)
        _frequencyType = State(initialValue: habit.frequency)
        _reminder = State(initialValue: habit.reminder ?? Date())
        _startColor = State(initialValue: Color(hex: habit.startColor) ?? .blue)
        _endColor = State(initialValue: Color(hex: habit.endColor) ?? .purple)
        _routineTime = State(initialValue: habit.routineTime)
        _endDate = State(initialValue: habit.endDate)
        _shouldAddToReminders = State(initialValue: habit.reminder != nil)
        _interval = State(initialValue: habit.interval ?? 1)
        _selectedDaysOfWeek = State(initialValue: habit.daysOfWeek ?? [])
        _specificDates = State(initialValue: habit.specificDates ?? [])
    }
    
    var body: some View {

            VStack {
                Form {
                    Section(header: Text("Habit Details").font(.custom("SFProText-Bold", size: 16))) {
                        TextField("Habit Title", text: $habitTitle)
                            .font(.custom("SFProText-Bold", size: 16))
                        TextField("Unit", text: $habitUnit)
                            .disabled(habitTemplates.map { $0.name }.contains(habitTitle))
                            .font(.custom("SFProText-Bold", size: 16))
                    }
                    
                    Section(header: Text("Goal").font(.custom("SFProText-Bold", size: 16))) {
                        TextField("Daily Goal", text: $habitGoal)
                            .keyboardType(.numberPad)
                            .font(.custom("SFProText-Bold", size: 16))
                    }
                    
                    Section(header: Text("Schedule").font(.custom("SFProText-Bold", size: 16))) {
                        DatePicker("End Date", selection: $endDate, displayedComponents: [.date])
                            .font(.custom("SFProText-Bold", size: 16))
                        
                        Picker("Group", selection: $category) {
                            ForEach(categories, id: \.self) { Text($0) }
                            ForEach(customGroups) { group in
                                Text(group.name).tag(group.name)
                            }
                            Text("Custom").tag("Custom")
                        }
                        
                        if category == "Custom" || !customGroups.map({ $0.name }).contains(category) {
                            if category == "Custom" {
                                VStack(alignment: .leading) {
                                    TextField("New Group Name", text: $newGroupName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .font(.custom("SFProText-Bold", size: 16))
                                    
                                    Button(action: {
                                        addNewGroup()
                                    }) {
                                        Text("Add Group")
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                    .disabled(newGroupName.trimmingCharacters(in: .whitespaces).isEmpty)
                                    .font(.custom("SFProText-Bold", size: 16))
                                    .padding(.top, 5)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        
                        Picker("Frequency", selection: $frequencyType) {
                            Text("Daily").tag(Habit.FrequencyType.daily)
                            Text("Weekly").tag(Habit.FrequencyType.weekly)
                            Text("Monthly").tag(Habit.FrequencyType.monthly)
                            Text("Every N Days").tag(Habit.FrequencyType.everyNDays)
                            Text("Specific Days of Week").tag(Habit.FrequencyType.specificDaysOfWeek)
                        }
                        .pickerStyle(MenuPickerStyle())
                        .font(.custom("SFProText-Bold", size: 16))
                        
                        if frequencyType == .everyNDays {
                            Stepper("Every \(interval) days", value: $interval, in: 1...30)
                                .font(.custom("SFProText-Bold", size: 16))
                        } else if frequencyType == .specificDaysOfWeek {
                            MultipleSelectionRow(title: "Select Days", options: [1, 2, 3, 4, 5, 6, 7], selectedOptions: $selectedDaysOfWeek)
                                .font(.custom("SFProText-Bold", size: 16))
                        }
                    }
                    
                    Section(header: Text("Reminder Options").font(.custom("SFProText-Bold", size: 16))) {
                        Toggle("Add to Reminders App", isOn: $shouldAddToReminders)
                            .font(.custom("SFProText-Bold", size: 16))
                        
                        if shouldAddToReminders {
                            DatePicker("Reminder Date", selection: $reminder, displayedComponents: [.date, .hourAndMinute])
                                .font(.custom("SFProText-Bold", size: 16))
                        }
                    }
                    
                    Section(header: Text("Habit Color").font(.custom("SFProText-Bold", size: 16))) {
                        ColorPicker("Start Color", selection: $startColor)
                            .font(.custom("SFProText-Bold", size: 16))
                        ColorPicker("End Color", selection: $endColor)
                            .font(.custom("SFProText-Bold", size: 16))
                    }
                    
                    Section {
                        Button(action: updateHabit) {
                            Text("Update Habit")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.navyBlue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .font(.custom("SFProText-Bold", size: 16))
                        }
                        .disabled(habitTitle.isEmpty || habitUnit.isEmpty || habitGoal.isEmpty)
                    }
                }
                .navigationTitle("Edit Habit")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .font(.custom("SFProText-Bold", size: 16))
                    }
                }
            }
            .onAppear {
                fetchGroups()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        
         func addNewGroup() {
            let trimmedName = newGroupName.trimmingCharacters(in: .whitespaces)
            guard !trimmedName.isEmpty else {
                alertMessage = "Group name cannot be empty."
                showAlert = true
                return
            }
            
            // Check if the group already exists
            if customGroups.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) {
                alertMessage = "A group with this name already exists."
                showAlert = true
                return
            }
            
            addGroup(name: trimmedName) { result in
                switch result {
                case .success():
                    // Clear the text field and dismiss keyboard
                    newGroupName = ""
                    // Optionally, set the selected category to the new group
                    category = trimmedName
                case .failure(let error):
                    alertMessage = "Failed to add group: \(error.localizedDescription)"
                    showAlert = true
                }
            }
            fetchGroups()
        }
        
        func fetchGroups() {
            guard let userID = Auth.auth().currentUser?.uid else {
                return
            }
            
            db.collection("groups")
                .whereField("userID", isEqualTo: userID)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error fetching groups: \(error)")
                        return
                    }
                    
                    self.customGroups = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: Groups.self)
                    } ?? []
                }
        }
        
        func addGroup(name: String, completion: @escaping (Result<Void, Error>) -> Void) {
            guard let userID = Auth.auth().currentUser?.uid else {
                completion(.failure(NSError(domain: "User not authenticated", code: 401, userInfo: nil)))
                return
            }
            
            let newGroup = Groups(id: nil, name: name, userID: userID)
            
            do {
                _ = try db.collection("groups").addDocument(from: newGroup) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            } catch let error {
                completion(.failure(error))
            }
        }
        
         func updateHabit() {
            guard let goalInt = Int(habitGoal) else {
                alertMessage = "Please enter a valid goal."
                showAlert = true
                return
            }
            
            let selectedCategory = category
            
            let updatedHabit = Habit(
                id: habitToEdit.id,
                title: habitTitle,
                unit: habitUnit,
                count: habitToEdit.count, // Retain the current count
                goal: goalInt,
                startColor: startColor.toHex() ?? "#0000FF",
                endColor: endColor.toHex() ?? "#800080",
                category: selectedCategory,
                frequency: frequencyType,
                reminder: shouldAddToReminders ? reminder : nil,
                routineTime: routineTime,
                endDate: endDate,
                dateTaken: habitToEdit.dateTaken,
                startDate: habitToEdit.startDate,
                interval: frequencyType == .everyNDays ? interval : nil,
                daysOfWeek: frequencyType == .specificDaysOfWeek ? selectedDaysOfWeek : nil,
                specificDates: frequencyType == .specificDaysOfWeek ? specificDates : nil
            )
            
            updateHabitAction(updatedHabit)
            updateHabitInFirestore(updatedHabit)
            dismiss()
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
        
    private func updateHabitInFirestore(_ habit: Habit) {
        guard let user = viewModel.currentUser else {
            print("No current user")
            return
        }
        let userID = user.id
        let db = Firestore.firestore()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var datesToUpdate: [Date] = []
        
        // Generate all relevant dates based on frequency
        switch habit.frequency {
        case .daily:
            datesToUpdate = generateDailyDates(startDate: habit.startDate, endDate: habit.endDate)
        case .weekly:
            datesToUpdate = generateWeeklyDates(startDate: habit.startDate, endDate: habit.endDate)
        case .monthly:
            datesToUpdate = generateMonthlyDates(startDate: habit.startDate, endDate: habit.endDate)
        case .everyNDays:
            if let interval = habit.interval {
                datesToUpdate = generateEveryNDaysDates(startDate: habit.startDate, endDate: habit.endDate, interval: interval)
            }
        case .specificDaysOfWeek:
            if let daysOfWeek = habit.daysOfWeek {
                datesToUpdate = generateSpecificDaysOfWeekDates(startDate: habit.startDate, endDate: habit.endDate, daysOfWeek: daysOfWeek)
            }
        }
        
        for date in datesToUpdate {
            let dateString = dateFormatter.string(from: date)
            let habitDoc = db.collection("users").document(userID).collection("habits").document(dateString)
            
            db.runTransaction { (transaction, errorPointer) -> Any? in
                do {
                    let habitSnapshot = try transaction.getDocument(habitDoc)
                    guard var habitsArray = habitSnapshot.data()?["habits"] as? [[String: Any]] else {
                        // If no habits array exists, nothing to update
                        return nil
                    }
                    
                    // Find the index of the habit to update
                    if let index = habitsArray.firstIndex(where: { $0["id"] as? String == habit.id }) {
                        // Preserve the existing count
                        let existingCount = habitsArray[index]["count"] as? Int ?? 0
                        
                        // Update fields except count
                        habitsArray[index]["title"] = habit.title
                        habitsArray[index]["unit"] = habit.unit
                        habitsArray[index]["goal"] = habit.goal
                        habitsArray[index]["startColor"] = habit.startColor
                        habitsArray[index]["endColor"] = habit.endColor
                        habitsArray[index]["category"] = habit.category
                        habitsArray[index]["frequency"] = habit.frequency.rawValue
                        habitsArray[index]["routineTime"] = habit.routineTime.rawValue
                        habitsArray[index]["reminder"] = habit.reminder != nil ? Timestamp(date: habit.reminder!) : NSNull()
                        habitsArray[index]["endDate"] = Timestamp(date: habit.endDate)
                        habitsArray[index]["interval"] = habit.interval ?? NSNull()
                        habitsArray[index]["daysOfWeek"] = habit.daysOfWeek ?? NSNull()
                        habitsArray[index]["specificDates"] = habit.specificDates?.map { Timestamp(date: $0) } ?? NSNull()
                        
                        // Restore the existing count
                        habitsArray[index]["count"] = existingCount
                        
                        // Optionally, update other fields like dateTaken if necessary
                        // habitsArray[index]["dateTaken"] = habit.dateTaken
                    
                        // Commit the updated habits array back to Firestore
                        transaction.updateData(["habits": habitsArray], forDocument: habitDoc)
                    }
                    return nil
                } catch let error as NSError {
                    errorPointer?.pointee = error
                    return nil
                }
            } completion: { (object, error) in
                if let error = error {
                    print("Transaction failed: \(error)")
                    // Optionally, present an alert to the user
                } else {
                    print("Transaction successfully committed for date \(dateString)!")
                    // Optionally, refresh data or notify the user
                }
            }
        }
    }
    }

    
    // Extension to convert Habit to Dictionary

