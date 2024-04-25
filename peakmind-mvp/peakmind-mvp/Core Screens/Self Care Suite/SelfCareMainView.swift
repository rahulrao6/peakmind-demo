//
//  SelfCareMainView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 4/22/24.
//
import Charts

struct SelfCareHome: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showingCheckInSheet = false  // State to manage the sheet presentation

    @State private var tasks: [TaskFirebase] = []
    @State private var showingWidgetSelection = false
    @State private var currentTasksExpanded2 = false
    @State private var showingAnalyticsSheet = false
    @State private var moodEntries: [MoodEntry] = []


    @State private var lastCheckDate: Date?
    @State private var showAlert = false
    var uncompletedTasks: [TaskFirebase] {
        Array(tasks.filter { !$0.isCompleted }.prefix(5))
    }
    var body: some View {
        if let user = viewModel.currentUser {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    // Top Section
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Welcome, \(user.username)!")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .font(.system(size: 500))
                                    .minimumScaleFactor(0.01)
                                
                                Text("This is your self care suite where you can find your personal plan, analytics and much more")
                                    .foregroundColor(.white)
                                    .font(.system(size: 500))
                                    .minimumScaleFactor(0.01)
                            }
                            .padding()
                            .frame(width: geometry.size.width * 0.65)
                            
                            Spacer()
                            
                            VStack {
                                Image("Sherpa")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60)
                            }
                            .frame(width: geometry.size.width * 0.35)
                        }
                        .frame(height: geometry.size.height * 0.2)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.mediumBlue)
                    
                    // Sheet-Like View
                    
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            Spacer()
                            
                            VStack{
                                
                                VStack{
                                   
                                    MoodPreview(title: "Weekly Moods", color: Color("Navy Blue"), navigateToAnalytics: {
                                        showingAnalyticsSheet = true
                                    })
                                        .frame(width: geometry.size.width - 30)

                                    
                                }

                                
                                VStack{
                                    taskListView2(title: "Personal Plan", color: Color("Navy Blue"))
                                }
                                .frame(width: geometry.size.width)


                                
                                HStack{
                                    CustomButton(title: "Check In", onClick: {
                                        checkAndAllowCheckIn()
                                    })
                                    CustomButton(title: "Pick Widgets", onClick: {
                                        showingWidgetSelection = true
                                    })

                                }

                            }

                            Spacer(minLength: geometry.size.height * 0.2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.darkBlue)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: -5)
                    .offset(y: geometry.size.height * 0.2)
                }
                .background(Color.mediumBlue)
                .onAppear() {
                    //print("this")
                    Task{
                        fetchTasks()
                        fetchLastCheckInDate()
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Check-In Complete"), message: Text("You have already completed your check-in for today."), dismissButton: .default(Text("OK")))
                }
                
            }
            .sheet(isPresented: $showingWidgetSelection) {
                WidgetSelectionView(isPresented: $showingWidgetSelection)
            }
            .sheet(isPresented: $showingCheckInSheet) {  // Sheet is presented based on the state
                CheckInView(isPresented: $showingCheckInSheet)
                    .environmentObject(viewModel)  // Ensure the view model is passed if needed
            }
            .sheet(isPresented: $showingAnalyticsSheet) {  // Sheet is presented based on the state
                Analytics(isPresented: $showingAnalyticsSheet)
                    .environmentObject(viewModel)  // Ensure the view model is passed if needed
            }
            .navigationBarTitle("Self Care Suite", displayMode: .inline)
            .foregroundColor(.white)
        }
    }
    @ViewBuilder
    private func taskListView2(title: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding()

            VStack(alignment: .leading, spacing: 5) {
                ForEach(uncompletedTasks.prefix(3).indices, id: \.self) { index in
                    if let taskIndex = tasks.firstIndex(where: { $0.id == uncompletedTasks[index].id }) {
                        TaskCardFirebase(task: $tasks[taskIndex])
                            .padding(.leading, 0)
                            .padding(.top, index == 0 ? 5 : 0)
                    }
                }
            }
            .padding([.horizontal, .bottom])
        }
        .background(RoundedRectangle(cornerRadius: 10).fill(color))
        .foregroundColor(.white)
    }
    

    @ViewBuilder
    private func MoodPreview(title: String, color: Color, navigateToAnalytics: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding()

            VStack {
                Chart{
                    ForEach(moodEntries) { entry in
                        LineMark(
                            x: .value("Date", entry.formattedDate),
                            y: .value("Mood", entry.mood)
                        )
                        .interpolationMethod(.catmullRom) // This makes the line smooth

                    }
                }
                .frame(height: 150)
            }
            .padding([.horizontal])

            CustomButton(title: "Analytics", onClick: navigateToAnalytics)
                .padding()
        }
        .background(RoundedRectangle(cornerRadius: 10).fill(color))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            fetchMoodData() // Ensure this is called to load data
        }
    }

    
    private func fetchLastCheckInDate() {
        guard let userId = viewModel.currentUser?.id else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { document, error in
            if let document = document, document.exists, let lastCheck = document.get("lastCheck") as? Timestamp {
                self.lastCheckDate = lastCheck.dateValue()
            }
        }
    }
    
    func fetchMoodData() {
        guard let userId = viewModel.currentUser?.id else {
            print("No user ID found")
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userId)
          .collection("daily_check_in")
          .order(by: "timestamp", descending: true)
          .limit(to: 5)
          .getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("No documents or empty documents")
                return
            }
            self.moodEntries = documents.compactMap { doc -> MoodEntry? in
                let data = doc.data()
                guard let timestamp = data["timestamp"] as? Timestamp, let mood = data["moodRating"] as? Int else {
                    return nil
                }
                return MoodEntry(date: timestamp.dateValue(), mood: mood)
            }
            print("Mood Entries: \(self.moodEntries)") // Debugging output
        }
    }


    func checkAndAllowCheckIn() {
        let today = Calendar.current.startOfDay(for: Date())
        if let lastCheckDate = lastCheckDate, Calendar.current.isDate(lastCheckDate, inSameDayAs: today) {
            // If last check-in was today
            showAlert = true
        } else {
            // If no check-in today
            showingCheckInSheet = true
        }
    }
    
    func fetchTasks() {
        let db = Firestore.firestore()
        guard let currentUser = viewModel.currentUser else {
            print("No current user")
            return
        }
        let userId = currentUser.id
        db.collection("ai_tasks").document(userId).getDocument { (document, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                return
            }

            guard let document = document, document.exists else {
                print("Document does not exist")
                return
            }

            if let data = document.data() {
                // Extract tasks from the document data
                var tasks: [TaskFirebase] = []
                for (key, taskData) in data {
                    if let taskData = taskData as? [String: Any],
                       let id = taskData["id"] as? String,
                       let isCompleted = taskData["isCompleted"] as? Bool,
                       let name = taskData["name"] as? String,
                       let rank = taskData["rank"] as? Int,
                       let timeCompleted = taskData["timeCompleted"] as? String {
                        let task = TaskFirebase(id: id,
                                        isCompleted: isCompleted,
                                        name: name,
                                        rank: rank,
                                        timeCompleted: timeCompleted)
                        tasks.append(task)
                    }
                }

                // Sort tasks if needed
                let sortedTasks = tasks.sorted { $0.rank < $1.rank }
                self.tasks = sortedTasks
                print(self.tasks)
            } else {
                print("No tasks data found")
            }
        }
    }
    
    
}

struct WidgetView: View {
    let type: String
    let checkInData: CheckInDataArray
    
    var body: some View {
        switch type {
        case "Mood":
            MoodWidget(data: checkInData.moodRating)
        case "Water":
            WaterWidget(data: checkInData.waterIntake)
        case "Step Counter":
            StepWidget(data: checkInData.steps)
        case "Sleep Tracker":
            SleepWidget(data: checkInData.hoursOfSleep)
        default:
            Text("Unknown Widget Type")
        }
    }
}

struct MoodWidget: View {
    var data: [Date: Int]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(data.sorted(by: { $0.key < $1.key }), id: \.key) { date, mood in
                    VStack {
                        Text(date, style: .date)
                        
                        Text("Mood: \(mood)")
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.5)))
                }
            }
        }
        .padding()
    }
}

struct WaterWidget: View {
    var data: [Date: Int]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(data.sorted(by: { $0.key < $1.key }), id: \.key) { date, water in
                    VStack {
                        Text(date, style: .date)
                        Text("Water: \(water) L")
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.green.opacity(0.5)))
                }
            }
        }
        .padding()
    }
}

struct SleepWidget: View {
    var data: [Date: Int]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(data.sorted(by: { $0.key < $1.key }), id: \.key) { date, sleep in
                    VStack {
                        Text(date, style: .date)
                        Text("Sleep: \(sleep) hrs")
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.purple.opacity(0.5)))
                }
            }
        }
        .padding()
    }
}

struct StepWidget: View {
    var data: [Date: Int]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(data.sorted(by: { $0.key < $1.key }), id: \.key) { date, steps in
                    VStack {
                        Text(date, style: .date)
                        Text("Steps: \(steps)")
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.orange.opacity(0.5)))
                }
            }
        }
        .padding()
    }
}


struct SelfCareHome_Previews: PreviewProvider {
    static var previews: some View {
        SelfCareHome()
    }
}



struct WidgetSelectionView: View {
    @Binding var isPresented: Bool
    @State private var selectedWidgets: [String] = []
    @EnvironmentObject var viewModel: AuthViewModel

    let availableWidgets = ["Mood", "Water", "Step Counter", "Sleep Tracker"]

    var body: some View {
        NavigationView {
            List {
                ForEach(availableWidgets, id: \.self) { widget in
                    MultipleSelectionRow(title: widget, isSelected: selectedWidgets.contains(widget)) {
                        if selectedWidgets.contains(widget) {
                            selectedWidgets.removeAll { $0 == widget }
                        } else {
                            selectedWidgets.append(widget)
                        }
                    }
                }
            }
            .navigationTitle("Choose Widgets")
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
                Task {
                    await viewModel.saveSelectedWidgets(selected: selectedWidgets)
                }
            }
            .foregroundColor(.blue)) // Blue color for toolbar button
            .onAppear {
                loadSelectedWidgets()
            }
        }
    }

    private func loadSelectedWidgets() {
        selectedWidgets = viewModel.currentUser?.selectedWidgets ?? []
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(isSelected ? .blue : .gray)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
        .padding()
    }
}

//struct Analytics: View {
//    @Binding var isPresented: Bool
//    @EnvironmentObject var viewModel: AuthViewModel
//    @State private var checkInData: [CheckInData] = []
//    @State private var checkInDataArray: [CheckInDataArray] = []
//
//    @State private var viewMode: ViewMode = .byDate
//
//    enum ViewMode {
//        case byDate, byWidget
//    }
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                Picker("View Mode", selection: $viewMode) {
//                    Text("By Date").tag(ViewMode.byDate)
//                    Text("By Widget").tag(ViewMode.byWidget)
//                }
//                .pickerStyle(SegmentedPickerStyle())
//                .padding()
//
//                List {
//                    if viewMode == .byDate {
//                        dateView
//                    } else {
//                        widgetView
//                    }
//                }
//            }
//            .foregroundColor(.black)
//            .navigationTitle("Check-In Analytics")
//            .navigationBarItems(trailing: Button("Close") { isPresented = false })
//            .onAppear {
//                fetchCheckInData()
//                fetchCheckInDataArray()
//            }
//        }
//    }
//
//    private var dateView: some View {
//        ForEach(checkInData, id: \.date) { data in
//            VStack(alignment: .leading) {
//                Text("Date: \(data.date.formatted(date: .abbreviated, time: .omitted))")
//                Text("Mood Rating: \(data.moodRating)")
//                Text("Water Intake: \(data.waterIntake) liters")
//                Text("Hours of Sleep: \(data.hoursOfSleep)")
//                Text("Steps: \(data.steps)")
//            }
//        }
//    }
//
//    private var widgetView: some View {
//        let widgets = Dictionary(grouping: checkInData, by: { $0.date })
//        return ForEach(Array(widgets.keys).sorted(), id: \.self) { date in
//            Section(header: Text(date.formatted(date: .abbreviated, time: .omitted))) {
//                ForEach(widgets[date] ?? [], id: \.moodRating) { data in
//                    VStack(alignment: .leading) {
//                        Text("Mood Rating: \(data.moodRating)")
//                        Text("Water Intake: \(data.waterIntake) liters")
//                        Text("Hours of Sleep: \(data.hoursOfSleep)")
//                        Text("Steps: \(data.steps)")
//                    }
//                }
//            }
//        }
//    }
//
//    private func fetchCheckInData() {
//        guard let userId = viewModel.currentUser?.id else { return }
//        let db = Firestore.firestore()
//        db.collection("users").document(userId).collection("daily_check_in")
//            .getDocuments { (querySnapshot, error) in
//                if let error = error {
//                    print("Error getting documents: \(error)")
//                } else if let querySnapshot = querySnapshot {
//                    self.checkInData = querySnapshot.documents.compactMap { document -> CheckInData? in
//                        let data = document.data()
//                        guard let timestamp = data["timestamp"] as? Timestamp else { return nil }
//                        let date = timestamp.dateValue()
//                        let moodRating = data["moodRating"] as? Int ?? 0
//                        let waterIntake = data["waterIntake"] as? Int ?? 0
//                        let hoursOfSleep = data["hoursOfSleep"] as? Int ?? 0
//                        let steps = data["steps"] as? Int ?? 0
//                        return CheckInData(date: date, moodRating: moodRating, waterIntake: waterIntake, hoursOfSleep: hoursOfSleep, steps: steps)
//                    }
//                }
//            }
//    }
//
//    func fetchCheckInDataArray() {
//        guard let userId = viewModel.currentUser?.id else { return }
//        let db = Firestore.firestore()
//        db.collection("users").document(userId).collection("daily_check_in")
//            .order(by: "timestamp", descending: false)
//            .getDocuments { (querySnapshot, error) in
//                if let error = error {
//                    print("Error getting documents: \(error)")
//                } else if let querySnapshot = querySnapshot {
//                    var checkInData = CheckInDataArray(date: Date())
//                    for document in querySnapshot.documents {
//                        let data = document.data()
//                        if let timestamp = data["timestamp"] as? Timestamp {
//                            let date = timestamp.dateValue()
//                            if let mood = data["moodRating"] as? Int {
//                                checkInData.moodRating[date] = mood
//                            }
//                            if let water = data["waterIntake"] as? Int {
//                                checkInData.waterIntake[date] = water
//                            }
//                            if let sleep = data["hoursOfSleep"] as? Int {
//                                checkInData.hoursOfSleep[date] = sleep
//                            }
//                            if let steps = data["steps"] as? Int {
//                                checkInData.steps[date] = steps
//                            }
//                        }
//                    }
//                    // Update your state here with new data
//                    self.checkInDataArray = checkInDataArray
//                }
//            }
//    }
//
//}

struct Analytics: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var viewModel: AuthViewModel // Assuming your view model holds the user's selected widget preferences

    @State private var moodData: [Date: Int] = [:]
    @State private var waterData: [Date: Int] = [:]
    @State private var sleepData: [Date: Int] = [:]
    @State private var stepData: [Date: Int] = [:]

    var body: some View {
        NavigationView {
            List {
                if viewModel.currentUser?.selectedWidgets.contains("Mood") == true {
                    Section(header: Text("Mood Tracking").foregroundColor(.black)) {
                        MoodWidget(data: moodData)
                    }
                }
                if viewModel.currentUser?.selectedWidgets.contains("Water") == true {
                    Section(header: Text("Water Intake").foregroundColor(.black)) {
                        WaterWidget(data: waterData)
                    }
                }
                if viewModel.currentUser?.selectedWidgets.contains("Sleep Tracker") == true {
                    Section(header: Text("Sleep Tracking").foregroundColor(.black)) {
                        SleepWidget(data: sleepData)
                    }
                }
                if viewModel.currentUser?.selectedWidgets.contains("Step Counter") == true {
                    Section(header: Text("Step Count").foregroundColor(.black)) {
                        StepWidget(data: stepData)
                    }
                }
            }
            .navigationTitle("Health Analytics")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        isPresented = false
                    }
                    .foregroundColor(.blue)
                }
            }
            
            .onAppear {
                fetchData()
            }
        }
    }

    private func fetchData() {
        let userID = viewModel.currentUser?.id ?? ""
        fetchData(for: userID, metric: "moodRating") { data in
            moodData = data
        }
        fetchData(for: userID, metric: "waterIntake") { data in
            waterData = data
        }
        fetchData(for: userID, metric: "hoursOfSleep") { data in
            sleepData = data
        }
        fetchData(for: userID, metric: "steps") { data in
            stepData = data
        }
    }

    func fetchData(for userID: String, metric: String, completion: @escaping ([Date: Int]) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userID).collection("daily_check_in")
          .order(by: "timestamp", descending: false)
          .getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            var data: [Date: Int] = [:]
            for document in documents {
                if let timestamp = document.get("timestamp") as? Timestamp,
                   let value = document.get(metric) as? Int {
                    data[timestamp.dateValue()] = value
                }
            }
            DispatchQueue.main.async {
                completion(data)
            }
        }
    }
}



struct CheckInData {
    let date: Date
    let moodRating: Int
    let waterIntake: Int
    let hoursOfSleep: Int
    let steps: Int
}

struct CheckInDataArray {
    let date: Date
    var moodRating: [Date: Int] = [:]
    var waterIntake: [Date: Int] = [:]
    var hoursOfSleep: [Date: Int] = [:]
    var steps: [Date: Int] = [:]
}



import SwiftUI
import FirebaseFirestore

struct CheckInView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var viewModel: AuthViewModel
    @State var moodRating: Int = 3
    @State var waterIntake: Int = 0
    @State var hoursOfSleep: Int = 8
    @State var steps: Int = 0
    @State var lastCheckInDates: [Date] = []


    var body: some View {
        NavigationView {
            Form {
                if viewModel.currentUser?.selectedWidgets.contains("Mood") == true {
                    Section(header: Text("Mood Rating")) {
                        Slider(value: Binding<Double>(get: {
                            Double(moodRating)
                        }, set: { (newValue) in
                            moodRating = Int(newValue)
                        }), in: 1...5, step: 1)
                        Text("Current mood: \(moodRating)")
                    }
                }
                if viewModel.currentUser?.selectedWidgets.contains("Water") == true {
                    Section(header: Text("Water Intake (in liters)")) {
                        Stepper(value: $waterIntake, in: 0...10) {
                            Text("\(waterIntake) L")
                        }
                    }
                }
                if viewModel.currentUser?.selectedWidgets.contains("Sleep Tracker") == true {
                    Section(header: Text("Hours of Sleep")) {
                        Stepper(value: $hoursOfSleep, in: 0...24) {
                            Text("\(hoursOfSleep) hours")
                        }
                    }
                }
                if viewModel.currentUser?.selectedWidgets.contains("Step Counter") == true {
                    Section(header: Text("Steps Taken")) {
                        Text("\(steps) steps")
                        Button("Fetch Steps from Firestore") {
                            fetchSteps()
                        }
                    }
                }
            }
            .foregroundColor(.darkBlue)  // Set the dark blue color for all text inside the form
            .navigationBarItems(leading: Button("Cancel") {
                isPresented = false
            }, trailing: Button("Save") {
                saveCheckInData()
                isPresented = false
            })
            .navigationBarTitle("Daily Check-In", displayMode: .inline)
        }
    }
    
    func fetchSteps() {
        guard let userID = viewModel.currentUser?.id else {
            print("User not logged in")
            return
        }
        let db = Firestore.firestore()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())

        let stepsDocument = db.collection("steps").document(userID)
        stepsDocument.getDocument { (document, error) in
            if let document = document, document.exists, let data = document.data(), let todaySteps = data[todayString] as? Int {
                self.steps = todaySteps
            } else {
                print("Document does not exist or failed to cast steps data")
            }
        }
    }
    
    func saveCheckInData() {
        guard let userID = viewModel.currentUser?.id else { return }
        let db = Firestore.firestore()
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: today)

        let checkInData: [String: Any] = [
            "moodRating": moodRating,
            "waterIntake": waterIntake,
            "hoursOfSleep": hoursOfSleep,
            "steps": steps,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(userID).collection("daily_check_in").document(dateString).setData(checkInData) { error in
            if let error = error {
                print("Error saving check-in: \(error)")
            } else {
                print("Check-in saved successfully")
                updateLastCheckIn(timestamp: today)
            }
        }
    }
//    func saveCheckInData() {
//        guard let userID = viewModel.currentUser?.id else { return }
//        let db = Firestore.firestore()
//        let today = Date()
//        let userRef = db.collection("users").document(userID)
//
//        db.runTransaction({ (transaction, errorPointer) -> Any? in
//            let userDocument: DocumentSnapshot
//            do {
//                try userDocument = transaction.getDocument(userRef)
//            } catch let fetchError as NSError {
//                errorPointer?.pointee = fetchError
//                return nil
//            }
//
//            var checkInDates = userDocument.data()?["checkInDates"] as? [Timestamp] ?? []
//            // Add today's date if not already included
//            if !checkInDates.contains(where: { Calendar.current.isDate($0.dateValue(), inSameDayAs: today) }) {
//                checkInDates.append(Timestamp(date: today))
//            }
//
//            transaction.updateData(["checkInDates": checkInDates], forDocument: userRef)
//            return nil
//        }) { (object, error) in
//            if let error = error {
//                print("Transaction failed: \(error)")
//            } else {
//                print("Transaction successfully committed!")
//                self.lastCheckInDates.append(today)
//            }
//        }
//    }

    func updateLastCheckIn(timestamp: Date) {
        guard let userID = viewModel.currentUser?.id else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userID).updateData([
            "lastCheck": timestamp
        ]) { error in
            if let error = error {
                print("Error updating last check-in timestamp: \(error)")
            } else {
                print("Last check-in timestamp updated successfully")
            }
        }
    }
}

struct MoodEntry: Identifiable {
    var id = UUID()
    var date: Date
    var mood: Int

    var formattedDate: String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
}
