////
////  SelfCareMainView.swift
////  peakmind-mvp
////
////  Created by Mikey Halim on 4/22/24.
////
//import Charts
//
//struct SelfCareHome: View {
//    @EnvironmentObject var viewModel: AuthViewModel
//    @State private var showingCheckInSheet = false  // State to manage the sheet presentation
//    
//    @State private var tasks: [TaskFirebase] = []
//    @State private var showingWidgetSelection = false
//    @State private var currentTasksExpanded2 = false
//    @State private var showingQuestionsSheet = false
//    @State private var showingAnalyticsSheet = false
//    @State private var moodEntries: [MoodEntry] = []
//    
//    
//    @State private var lastCheckDate: Date?
//    @State private var showAlert = false
//    @State private var showWidgetAlert = false
//    @State private var taskPollingTimer: Timer?
//    
//    var uncompletedTasks: [TaskFirebase] {
//        Array(tasks.filter { !$0.isCompleted }.prefix(5))
//    }
//    var body: some View {
//        if let user = viewModel.currentUser {
//            GeometryReader { geometry in
//                ZStack(alignment: .top) {
//                    // Top Section
//                    VStack {
//                        HStack {
//                            VStack(alignment: .leading) {
//                                Text("Welcome, \(user.username)!")
//                                    .fontWeight(.bold)
//                                    .foregroundColor(.black)
//                                    .font(.system(size: 500))
//                                    .minimumScaleFactor(0.01)
//                                
//                                Text("This is your self care suite where you can find your personal plan, analytics and much more!")
//                                    .fontWeight(.semibold)
//                                    .foregroundColor(.black)
//                                    .font(.system(size: 500))
//                                    .minimumScaleFactor(0.01)
//                            }
//                            .padding()
//                            .frame(width: geometry.size.width * 0.65)
//                            
//                            Spacer()
//                            
//                            Image("Sherpa")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 60)
//                            Spacer()
//                            
//                            //.frame(width: geometry.size.width * 0.35)
//                        }
//                        .frame(height: geometry.size.height * 0.2)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .background(
//                        Image("SelfCare")
//                            .resizable() // Allows the image to be resized
//                            .aspectRatio(contentMode: .fill) // Keeps the aspect ratio and fills the frame
//                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // Sets frame size and aligns image to top
//                            .clipped() // Clips the overflowing parts of the image outside the frame
//                    )
//                    
//                    // Sheet-Like View
//                    
//                    ScrollView {
//                        LazyVStack(spacing: 20) {
//                            Spacer()
//                            
//                            VStack{
//                                
//                                VStack{
//                                    
//                                    MoodPreview(title: "Weekly Moods", color: Color("Navy Blue"), navigateToAnalytics: {
//                                        showingAnalyticsSheet = true
//                                    })
//                                    .frame(width: geometry.size.width - 30)
//                                    
//                                    
//                                }
//                                
//                                
//                                VStack{
//                                    taskListView2(title: "Personal Plan", color: Color("Navy Blue"))
//                                }
//                                .frame(width: geometry.size.width - 30)
//                                                                
//                                HStack(spacing: -15){
//                                    CustomButton2(title: "Check In", onClick: {
//                                        checkAndAllowCheckIn()
//                                        Task{
//                                            await viewModel.fetchUser()
//                                        }
//                                    })
//                                    .frame(maxWidth: .infinity)
//                                    CustomButton2(title: "Pick Widgets", onClick: {
//                                        showingWidgetSelection = true
//                                    })
//                                    .frame(maxWidth: .infinity)
//                                    
//                                }
//                                .frame(width: geometry.size.width) // Adjusted width here by including horizontal padding in calculation
//                                //.padding(.horizontal, 30)
//                                
//                            }
//                            
//                            Spacer(minLength: geometry.size.height * 0.2)
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding(.horizontal, 15) // Adjusted horizontal padding for the entire stack if needed
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .background(Color.darkBlue)
//                    .cornerRadius(20)
//                    .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: -5)
//                    .offset(y: geometry.size.height * 0.2)
//                    
//                    if (showWidgetAlert) {
//                        SherpaTutorialBox(tutorialText: "Please select your daily widgets and complete your first check-in.") {
//                            showWidgetAlert = false
//                            showingWidgetSelection = true
//                        }
//                    }
//                }
//                .background(Color.iceBlue)
//                .onAppear() {
//                    //print("this")
//                    if (viewModel.currentUser?.lastCheck == nil && viewModel.currentUser?.hasCompletedTutorial == true && (viewModel.currentUser?.selectedWidgets.isEmpty == true)) {
//                        showWidgetAlert = true
//                    }
//                    startTaskPolling()
//                    
//                    Task{
//                        fetchTasks()
//                        fetchLastCheckInDate()
//                        
//                    }
//                }
//                .onDisappear {
//                    stopTaskPolling()
//                }
//                .alert(isPresented: $showAlert) {
//                    Alert(title: Text("Check-In Complete"), message: Text("You have already completed your check-in for today."), dismissButton: .default(Text("OK")))
//                }
//                //                .alert(isPresented: $showWidgetAlert) {
//                //                    Alert(
//                //                        title: Text("No Mood Entries"),
//                //                        message: Text("Please select your daily widgets."),
//                //                        primaryButton: .default(Text("Select Widgets")) {
//                //                            showWidgetAlert = false
//                //                            showingWidgetSelection = true
//                //                        },
//                //                        secondaryButton: .cancel(Text("Close"))
//                //                    )
//                //                }
//                
//                
//            }
//            .sheet(isPresented: $showingWidgetSelection) {
//                WidgetSelectionView(isPresented: $showingWidgetSelection)
//            }
//            .sheet(isPresented: $showingCheckInSheet, onDismiss: {
//                Task {
//                    fetchLastCheckInDate()
//                    try await viewModel.fetchUser()
//                }
//            }) {
//                CheckInView(isPresented: $showingCheckInSheet)
//                    .environmentObject(viewModel)
//            }
//            .sheet(isPresented: $showingAnalyticsSheet, onDismiss: {
//                Task{
//                    try await viewModel.fetchUser()
//                }
//                
//            }) {  // Sheet is presented based on the state
//                //Analytics(isPresented: $showingAnalyticsSheet)
//                    //.environmentObject(viewModel)  // Ensure the view model is passed if needed
//            }
//            .sheet(isPresented: $showingQuestionsSheet, onDismiss: {
//                Task{
//                    try await viewModel.fetchUser()
//                }
//                
//            }) {  // Sheet is presented based on the state
//                QuestionsView()
//                    .environmentObject(viewModel)  // Ensure the view model is passed if needed
//            }
//            
//            
//            
//            .navigationBarTitle("Self Care Suite", displayMode: .inline)
//            .foregroundColor(.white)
//        }
//        
//        
//    }
//    
//    func checkQuiz() {
//        if (!(viewModel.currentUser?.hasCompletedInitialQuiz ?? true) && viewModel.currentUser?.hasCompletedTutorial ?? true) {
//            showingQuestionsSheet = true
//        }
//    }
//    private func startTaskPolling() {
//        taskPollingTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
//            fetchTasks() {
//                if ((tasks.isEmpty ?? true)) {
//                    stopTaskPolling()
//                }
//            }
//        }
//    }
//    
//    private func stopTaskPolling() {
//        taskPollingTimer?.invalidate()
//        taskPollingTimer = nil
//    }
//    @ViewBuilder
//    private func taskListView2(title: String, color: Color) -> some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text(title)
//                .font(.headline)
//                .foregroundColor(.white)
//                .padding()
//            if uncompletedTasks.isEmpty {
//                VStack {
//                    HStack {
//                        Text("Looks like all of your tasks are completed!")
//                        Spacer()
//                    }
//                    .padding()
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
//                    .foregroundColor(.black)
//                }
//                .padding([.horizontal, .bottom])
// 
//            } else {
//                VStack(alignment: .leading, spacing: 5) {
//                    ForEach(uncompletedTasks.prefix(3).indices, id: \.self) { index in
//                        if let taskIndex = tasks.firstIndex(where: { $0.id == uncompletedTasks[index].id }) {
//                            TaskCardFirebase(task: $tasks[taskIndex])
//                                .padding(.leading, 0)
//                                .padding(.top, index == 0 ? 5 : 0)
//                        }
//                    }
//                }
//                .padding([.horizontal, .bottom])
//            }
//        }
//        .background(RoundedRectangle(cornerRadius: 10).fill(color))
//        .foregroundColor(.white)
//    }
//    
//    @ViewBuilder
//    private func MoodPreview(title: String, color: Color, navigateToAnalytics: @escaping () -> Void) -> some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text(title)
//                .font(.headline)
//                .foregroundColor(.white)
//                .padding()
//            
//            VStack {
//                // Check the count of moodEntries
//                if moodEntries.count < 2 {
//                    Text("Check back tomorrow for your mood chart.")
//                        .foregroundColor(.white)
//                        .padding()
//                } else {
//                    Chart{
//                        ForEach(moodEntries) { entry in
//                            LineMark(
//                                x: .value("Date", entry.formattedDate),
//                                y: .value("Mood", entry.mood)
//                            )
//                            .interpolationMethod(.catmullRom) // This makes the line smooth
//                        }
//                    }
//                    .frame(height: 150)
//                }
//            }
//            .padding([.horizontal])
//            
//            CustomButton2(title: "Analytics", onClick: navigateToAnalytics)
//                .padding()
//        }
//        .background(RoundedRectangle(cornerRadius: 10).fill(color))
//        .foregroundColor(.white)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .onAppear {
//            checkQuiz()
//            fetchMoodData() // Ensure this is called to load data
//        }
//    }
//    
//    
//    
//    private func fetchLastCheckInDate() {
//        guard let userId = viewModel.currentUser?.id else { return }
//        let db = Firestore.firestore()
//        let userRef = db.collection("users").document(userId)
//        userRef.getDocument { document, error in
//            if let document = document, document.exists, let lastCheck = document.get("lastCheck") as? Timestamp {
//                self.lastCheckDate = lastCheck.dateValue()
//            }
//        }
//    }
//    
//    func fetchMoodData() {
//        guard let userId = viewModel.currentUser?.id else {
//            print("No user ID found")
//            return
//        }
//        let db = Firestore.firestore()
//        db.collection("users").document(userId)
//            .collection("daily_check_in")
//            .order(by: "timestamp", descending: true)
//            .limit(to: 5)
//            .getDocuments { (snapshot, error) in
//                if let error = error {
//                    print("Error fetching documents: \(error)")
//                    return
//                }
//                guard let documents = snapshot?.documents, !documents.isEmpty else {
//                    print("No documents or empty documents")
//                    return
//                }
//                self.moodEntries = documents.compactMap { doc -> MoodEntry? in
//                    let data = doc.data()
//                    guard let timestamp = data["timestamp"] as? Timestamp, let mood = data["moodRating"] as? Int else {
//                        return nil
//                    }
//                    return MoodEntry(date: timestamp.dateValue(), mood: mood)
//                }
//                print("Mood Entries: \(self.moodEntries)") // Debugging output
//            }
//    }
//    
//    
//    func checkAndAllowCheckIn() {
//        let today = Calendar.current.startOfDay(for: Date())
//        if let lastCheckDate = lastCheckDate, Calendar.current.isDate(lastCheckDate, inSameDayAs: today) {
//            // If last check-in was today
//            showAlert = true
//        } else {
//            // If no check-in today
//            showingCheckInSheet = true
//        }
//    }
//    
//    func fetchTasks() {
//        let db = Firestore.firestore()
//        guard let currentUser = viewModel.currentUser else {
//            print("No current user")
//            return
//        }
//        let userId = currentUser.id
//        db.collection("ai_tasks").document(userId).getDocument { (document, error) in
//            if let error = error {
//                print("Error getting documents: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let document = document, document.exists else {
//                print("Document does not exist")
//                return
//            }
//            
//            if let data = document.data() {
//                // Extract tasks from the document data
//                var tasks: [TaskFirebase] = []
//                for (key, taskData) in data {
//                    if let taskData = taskData as? [String: Any],
//                       let id = taskData["id"] as? String,
//                       let isCompleted = taskData["isCompleted"] as? Bool,
//                       let name = taskData["name"] as? String,
//                       let rank = taskData["rank"] as? Int,
//                       let timeCompleted = taskData["timeCompleted"] as? String {
//                        let task = TaskFirebase(id: id,
//                                                isCompleted: isCompleted,
//                                                name: name,
//                                                rank: rank,
//                                                timeCompleted: timeCompleted)
//                        tasks.append(task)
//                    }
//                }
//                
//                // Sort tasks if needed
//                let sortedTasks = tasks.sorted { $0.rank < $1.rank }
//                self.tasks = sortedTasks
//                print(self.tasks)
//            } else {
//                print("No tasks data found")
//            }
//        }
//    }
//    func fetchTasks(completion: (() -> Void)? = nil) {
//        let db = Firestore.firestore()
//        guard let currentUser = viewModel.currentUser else {
//            print("No current user")
//            return
//        }
//        let userId = currentUser.id
//        db.collection("ai_tasks").document(userId).getDocument { (document, error) in
//            if let error = error {
//                print("Error getting documents: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let document = document, document.exists else {
//                print("Document does not exist")
//                return
//            }
//            
//            if let data = document.data() {
//                // Extract tasks from the document data
//                var tasks: [TaskFirebase] = []
//                for (key, taskData) in data {
//                    if let taskData = taskData as? [String: Any],
//                       let id = taskData["id"] as? String,
//                       let isCompleted = taskData["isCompleted"] as? Bool,
//                       let name = taskData["name"] as? String,
//                       let rank = taskData["rank"] as? Int,
//                       let timeCompleted = taskData["timeCompleted"] as? String {
//                        let task = TaskFirebase(id: id,
//                                                isCompleted: isCompleted,
//                                                name: name,
//                                                rank: rank,
//                                                timeCompleted: timeCompleted)
//                        tasks.append(task)
//                    }
//                }
//                
//                // Sort tasks if needed
//                let sortedTasks = tasks.sorted { $0.rank < $1.rank }
//                self.tasks = sortedTasks
//                print(self.tasks)
//            } else {
//                print("No tasks data found")
//            }
//            completion?()
//        }
//        
//        
//    }
//}
//
//struct WidgetView: View {
//    let type: String
//    let checkInData: CheckInDataArray
//    
//    var body: some View {
//        switch type {
//        case "Mood":
//            MoodWidget(data: checkInData.moodRating)
//        case "Water":
//            WaterWidget(data: checkInData.waterIntake)
//        case "Step Counter":
//            StepWidget(data: checkInData.steps)
//        case "Sleep Tracker":
//            SleepWidget(data: checkInData.hoursOfSleep)
//        default:
//            Text("Unknown Widget Type")
//        }
//    }
//}
//
//struct MoodWidget: View {
//    var data: [Date: Int]
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack {
//                ForEach(data.sorted(by: { $0.key < $1.key }), id: \.key) { date, mood in
//                    VStack {
//                        Text(date, style: .date)
//                        
//                        Text("Mood: \(mood)")
//                    }
//                    .padding()
//                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.5)))
//                }
//            }
//        }
//        .padding()
//    }
//}
//
//struct WaterWidget: View {
//    var data: [Date: Int]
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack {
//                ForEach(data.sorted(by: { $0.key < $1.key }), id: \.key) { date, water in
//                    VStack {
//                        Text(date, style: .date)
//                        Text("Water: \(water) L")
//                    }
//                    .padding()
//                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.green.opacity(0.5)))
//                }
//            }
//        }
//        .padding()
//    }
//}
//
//struct SleepWidget: View {
//    var data: [Date: Int]
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack {
//                ForEach(data.sorted(by: { $0.key < $1.key }), id: \.key) { date, sleep in
//                    VStack {
//                        Text(date, style: .date)
//                        Text("Sleep: \(sleep) hrs")
//                    }
//                    .padding()
//                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.purple.opacity(0.5)))
//                }
//            }
//        }
//        .padding()
//    }
//}
//
//struct StepWidget: View {
//    var data: [Date: Int]
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack {
//                ForEach(data.sorted(by: { $0.key < $1.key }), id: \.key) { date, steps in
//                    VStack {
//                        Text(date, style: .date)
//                        Text("Steps: \(steps)")
//                    }
//                    .padding()
//                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.orange.opacity(0.5)))
//                }
//            }
//        }
//        .padding()
//    }
//}
//
//
//struct SelfCareHome_Previews: PreviewProvider {
//    static var previews: some View {
//        SelfCareHome()
//    }
//}
//
//
//
//struct WidgetSelectionView: View {
//    @Binding var isPresented: Bool
//    @State private var selectedWidgets: [String] = []
//    @EnvironmentObject var viewModel: AuthViewModel
//
//    let availableWidgets = ["Mood", "Water", "Step Counter", "Sleep Tracker"]
//
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(availableWidgets, id: \.self) { widget in
//                    MultipleSelectionRow(title: widget, isSelected: selectedWidgets.contains(widget)) {
//                        if selectedWidgets.contains(widget) {
//                            selectedWidgets.removeAll { $0 == widget }
//                        } else {
//                            selectedWidgets.append(widget)
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Choose Widgets")
//            .navigationBarItems(trailing: Button("Done") {
//                isPresented = false
//                Task {
//                    await viewModel.saveSelectedWidgets(selected: selectedWidgets)
//                }
//            }
//            .foregroundColor(.blue)) // Blue color for toolbar button
//            .onAppear {
//                //loadSelectedWidgets()
//            }
//        }
//        .environment(\.colorScheme, .light)
//    }
//
//
////    private func loadSelectedWidgets() {
////        selectedWidgets = viewModel.currentUser?.selectedWidgets
////    }
//}
//
//struct MultipleSelectionRow: View {
//    var title: String
//    var isSelected: Bool
//    var action: () -> Void
//
//    var body: some View {
//        HStack {
//            Text(title)
//                .foregroundColor(isSelected ? .blue : .gray)
//            Spacer()
//            if isSelected {
//                Image(systemName: "checkmark")
//                    .foregroundColor(.blue)
//            }
//        }
//        .contentShape(Rectangle())
//        .onTapGesture(perform: action)
//        .padding()
//    }
//}
//
//
////struct Analytics: View {
////    @Binding var isPresented: Bool
////    @EnvironmentObject var viewModel: AuthViewModel // Assuming your view model holds the user's selected widget preferences
////    
////    @State private var moodData: [Date: Int] = [:]
////    @State private var waterData: [Date: Int] = [:]
////    @State private var sleepData: [Date: Int] = [:]
////    @State private var stepData: [Date: Int] = [:]
////    //create a dynamic data object to track stuff
////    @State private var pieChartData: [String: Double] = [:]
////    @State private var lineChartData: [String: [Double]] = [:]
////    @State private var barChartData: [String: [Int]] = [:]
////    @State private var summary: String = ""
////    
////    
////    var body: some View {
////        NavigationView {
////            ScrollView {
////                VStack(spacing: 20) {
////                    
////                    Text(summary)
////                    
////                    if viewModel.currentUser?.selectedWidgets.contains("Mood") == true {
////                        MoodWidget(data: moodData)
////                    }
////                    if viewModel.currentUser?.selectedWidgets.contains("Water") == true {
////                        WaterWidget(data: waterData)
////                    }
////                    if viewModel.currentUser?.selectedWidgets.contains("Sleep Tracker") == true {
////                        SleepWidget(data: sleepData)
////                    }
////                    if viewModel.currentUser?.selectedWidgets.contains("Step Counter") == true {
////                        StepWidget(data: stepData)
////                    }
////                }
////                .padding(.horizontal, 20)
////            }
////            .background(Color("SentMessage")) // Background color for the ScrollView
////            .navigationTitle("Health Analytics")
////            .toolbar {
////                ToolbarItem(placement: .navigationBarLeading) {
////                    Button("Close") {
////                        isPresented = false
////                    }
////                    .foregroundColor(.blue)
////                }
////            }
////            
////            .onAppear {
////                fetchData()
////            }
////        }
////        .background(Color("SentMessage")) // Background color for the Navigation View
////    }
////    
////    //    private func fetchData() {
////    //        let userID = viewModel.currentUser?.id ?? ""
////    //        fetchData(for: userID, metric: "moodRating") { data in
////    //            moodData = data
////    //        }
////    //        fetchData(for: userID, metric: "waterIntake") { data in
////    //            waterData = data
////    //        }
////    //        fetchData(for: userID, metric: "hoursOfSleep") { data in
////    //            sleepData = data
////    //        }
////    //        fetchData(for: userID, metric: "steps") { data in
////    //            stepData = data
////    //        }
////    //    }
////    //
////    //    func fetchData(for userID: String, metric: String, completion: @escaping ([Date: Int]) -> Void) {
////    //        let db = Firestore.firestore()
////    //        db.collection("users").document(userID).collection("daily_check_in")
////    //          .order(by: "timestamp", descending: false)
////    //          .getDocuments { snapshot, error in
////    //            guard let documents = snapshot?.documents else {
////    //                print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
////    //                return
////    //            }
////    //
////    //            var data: [Date: Int] = [:]
////    //            for document in documents {
////    //                if let timestamp = document.get("timestamp") as? Timestamp,
////    //                   let value = document.get(metric) as? Int {
////    //                    data[timestamp.dateValue()] = value
////    //                }
////    //            }
////    //            DispatchQueue.main.async {
////    //                completion(data)
////    //            }
////    //        }
////    //    }
////    private func fetchData() {
////        guard let userID = viewModel.currentUser?.id else {
////            print("User ID not found")
////            return
////        }
////        
////        let urlString = "http://35.188.88.124/api/health_summary/\(userID)"
////        guard let url = URL(string: urlString) else {
////            print("Invalid URL")
////            return
////        }
////        
////        URLSession.shared.dataTask(with: url) { data, response, error in
////            if let error = error {
////                print("Error fetching data: \(error.localizedDescription)")
////                return
////            }
////            
////            guard let data = data else {
////                print("No data returned")
////                return
////            }
////            
////            do {
////                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
////                    if let chartData = json["chartData"] as? [String: Any],
////                       let pieData = chartData["pieChart"] as? [String: Any],
////                       let lineData = chartData["lineChart"] as? [String: [Double]],
////                       let barData = chartData["barChart"] as? [String: [Int]] {
////                        
////                        DispatchQueue.main.async {
////                            self.pieChartData = self.processPieChartData(pieData)
////                            self.lineChartData = lineData
////                            self.barChartData = barData
////                            
////                            self.moodData = self.processBarChartData(barData, for: "moodRating")
////                            self.waterData = self.processBarChartData(barData, for: "waterIntake")
////                            self.sleepData = self.processBarChartData(barData, for: "hoursOfSleep")
////                            self.stepData = self.processBarChartData(barData, for: "steps")
////                        }
////                    }
////                    
////                    if let summaryText = json["summary"] as? String {
////                        DispatchQueue.main.async {
////                            self.summary = summaryText
////                        }
////                    }
////                }
////            } catch {
////                print("Error parsing JSON: \(error.localizedDescription)")
////            }
////        }.resume()
////    }
////    
////    private func processPieChartData(_ data: [String: Any]) -> [String: Double] {
////        var result: [String: Double] = [:]
////        if let labels = data["labels"] as? [String], let values = data["values"] as? [Double] {
////            for (index, label) in labels.enumerated() {
////                result[label] = values[index]
////            }
////        }
////        return result
////    }
////    
////    private func processBarChartData(_ data: [String: [Int]], for metric: String) -> [Date: Int] {
////        var result: [Date: Int] = [:]
////        if let values = data[metric] {
////            for (index, value) in values.enumerated() {
////                let date = Date(timeIntervalSince1970: TimeInterval(index)) // Example date processing
////                result[date] = value
////            }
////        }
////        return result
////    }
////}
//
//
//
//struct CheckInData {
//    let date: Date
//    let moodRating: Int
//    let waterIntake: Int
//    let hoursOfSleep: Int
//    let steps: Int
//}
//
//struct CheckInDataArray {
//    let date: Date
//    var moodRating: [Date: Int] = [:]
//    var waterIntake: [Date: Int] = [:]
//    var hoursOfSleep: [Date: Int] = [:]
//    var steps: [Date: Int] = [:]
//}
//
//
//
//import SwiftUI
//import FirebaseFirestore
//
//
//struct CheckInView: View {
//    @Binding var isPresented: Bool
//    @EnvironmentObject var viewModel: AuthViewModel
//    @State var moodRating: Int = 5
//    @State var waterIntake: Int = 0
//    @State var hoursOfSleep: Int = 0
//    @State var steps: Int = 0
//    @State var lastCheckInDates: [Date] = []
//    
//    let moodDescriptions = [
//        1: "Terrible",
//        2: "Very Bad",
//        3: "Bad",
//        4: "Somewhat Bad",
//        5: "Neutral",
//        6: "Somewhat Good",
//        7: "Good",
//        8: "Very Good",
//        9: "Great",
//        10: "Amazing"
//    ]
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(spacing: 20) {
//                    Text("Answer these questions to complete your daily check-in!")
//                               .font(.title2)
//                               .fontWeight(.bold)
//                               .multilineTextAlignment(.center)
//                               .padding()
//                               .foregroundColor(.white)
//
//                    
////                    
////                    if viewModel.currentUser?.selectedWidgets.contains("Mood") == true {
////                        moodSection
////                    }
////                    if viewModel.currentUser?.selectedWidgets.contains("Water") == true {
////                        waterSection
////                    }
////                    if viewModel.currentUser?.selectedWidgets.contains("Sleep Tracker") == true {
////                        sleepSection
////                    }
////                    if viewModel.currentUser?.selectedWidgets.contains("Step Counter") == true {
////                        stepSection
////                    }
//                }
//                .padding(.horizontal, 20)
//            }
//            .background(Color("SentMessage")) // Background color for the ScrollView
//            .navigationBarItems(
//                leading: Button("Cancel") {
//                    isPresented = false
//                }.foregroundColor(.white),
//                trailing: Button("Save") {
//                    saveCheckInData()
//                    isPresented = false
//                }.foregroundColor(.white)
//            )
//            .navigationBarBackButtonHidden(true)
//        }
//        .background(Color("SentMessage")) // Background color for the Navigation View
//    }
//
//    var moodSection: some View {
//        Section {
//            VStack(alignment: .center, spacing: 8) {
//                Text("How would you rate your mood today?")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                Slider(value: Binding<Double>(
//                    get: { Double(moodRating) },
//                    set: { newValue in moodRating = Int(newValue) }
//                ), in: 1...10, step: 1)
//                .accentColor(.white)
//                Text("Current mood: \(moodDescriptions[moodRating] ?? "")")
//            }
//            .frame(maxWidth: .infinity) // Ensure the width is consistent
//            .padding()
//            .background(RoundedRectangle(cornerRadius: 10).fill(Color("Navy Blue")))
//            .foregroundColor(.white)
//        }
//    }
//
//    var waterSection: some View {
//        Section {
//            VStack(alignment: .center, spacing: 8) {
//                Text("How much water did you drink today?")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                HStack(spacing: 20) {
//                    decrementButton(for: $waterIntake)
//                    VStack {
//                        Image(systemName: "drop.fill").font(.largeTitle)
//                        Text("\(waterIntake) L").font(.title)
//                    }
//                    incrementButton(for: $waterIntake)
//                }
//            }
//            .frame(maxWidth: .infinity) // Ensure the width is consistent
//            .padding()
//            .background(RoundedRectangle(cornerRadius: 10).fill(Color("Navy Blue")))
//            .foregroundColor(.white)
//        }
//    }
//
//    var sleepSection: some View {
//        Section {
//            VStack(alignment: .center, spacing: 8) {
//                Text("How much sleep did you get last night?")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                HStack(spacing: 20) {
//                    decrementButton(for: $hoursOfSleep)
//                    VStack {
//                        Image(systemName: "moon.zzz.fill").font(.largeTitle)
//                        Text("\(hoursOfSleep) hrs").font(.title)
//                    }
//                    incrementButton(for: $hoursOfSleep)
//                }
//            }
//            .frame(maxWidth: .infinity) // Ensure the width is consistent
//            .padding()
//            .background(RoundedRectangle(cornerRadius: 10).fill(Color("Navy Blue")))
//            .foregroundColor(.white)
//        }
//    }
//
//    var stepSection: some View {
//        Section {
//            VStack(alignment: .center, spacing: 8) {
//                Text("Steps Taken")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                Text("\(steps) steps")
//                    .font(.title)
//            }
//            .frame(maxWidth: .infinity) // Ensure the width is consistent
//            .padding()
//            .background(RoundedRectangle(cornerRadius: 10).fill(Color("Navy Blue")))
//            .foregroundColor(.white)
//        }
//    }
//
//
//    func decrementButton(for binding: Binding<Int>) -> some View {
//        Button(action: {
//            if binding.wrappedValue > 0 { binding.wrappedValue -= 1 }
//        }) {
//            Image(systemName: "minus.circle").font(.largeTitle).foregroundColor(.iceBlue)
//        }
//    }
//
//    func incrementButton(for binding: Binding<Int>) -> some View {
//        Button(action: {
//            binding.wrappedValue += 1
//        }) {
//            Image(systemName: "plus.circle").font(.largeTitle).foregroundColor(.iceBlue)
//        }
//    }
//
//    
//    func fetchSteps() {
//        guard let userID = viewModel.currentUser?.id else {
//            print("User not logged in")
//            return
//        }
//        let db = Firestore.firestore()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        let todayString = formatter.string(from: Date())
//
//        let stepsDocument = db.collection("steps").document(userID)
//        stepsDocument.getDocument { (document, error) in
//            if let document = document, document.exists, let data = document.data(), let todaySteps = data[todayString] as? Int {
//                self.steps = todaySteps
//            } else {
//                print("Document does not exist or failed to cast steps data")
//            }
//        }
//    }
//    
//    func saveCheckInData() {
//        guard let userID = viewModel.currentUser?.id else { return }
//        let db = Firestore.firestore()
//        let today = Date()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        let dateString = formatter.string(from: today)
//
//        let checkInData: [String: Any] = [
//            "moodRating": moodRating,
//            "waterIntake": waterIntake,
//            "hoursOfSleep": hoursOfSleep,
//            "steps": steps,
//            "timestamp": FieldValue.serverTimestamp()
//        ]
//        
//        db.collection("users").document(userID).collection("daily_check_in").document(dateString).setData(checkInData) { error in
//            if let error = error {
//                print("Error saving check-in: \(error)")
//            } else {
//                print("Check-in saved successfully")
//                updateLastCheckIn(timestamp: today)
//            }
//        }
//    }
//    
//    func updateLastCheckIn(timestamp: Date) {
//        guard let userID = viewModel.currentUser?.id else { return }
//        let db = Firestore.firestore()
//        let userRef = db.collection("users").document(userID)
//
//        userRef.getDocument { document, error in
//            guard let document = document, error == nil else {
//                print("Error fetching user data: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//
//            // Initialize or update the weeklyStatus array
//            var weeklyStatus = document.get("weeklyStatus") as? [Int] ?? [0, 0, 0, 0, 0, 0, 0]
//            let lastCheck = document.get("lastCheck") as? Timestamp
//            var dailyCheckInStreak = document.get("dailyCheckInStreak") as? Int ?? 0
//
//            let calendar = Calendar.current
//            let currentWeekOfYear = calendar.component(.weekOfYear, from: timestamp)
//            let currentDayOfWeek = calendar.component(.weekday, from: timestamp)
//            let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: timestamp))
//
//            // Calculate index (0-based, Monday as first day)
//            let index = (currentDayOfWeek + 5) % 7  // Adjusting index since Sunday is 1 in Gregorian calendar
//
//            // Check if the last check-in was yesterday for the streak
//            if let lastCheckDate = lastCheck?.dateValue(), calendar.isDate(lastCheckDate, inSameDayAs: yesterday!) {
//                dailyCheckInStreak += 1 // Increment the streak
//            } else {
//                dailyCheckInStreak = 1 // Reset the streak
//            }
//
//            // Check if the last check-in was in the current week for the weekly status
//            if let lastCheckDate = lastCheck?.dateValue(), calendar.component(.weekOfYear, from: lastCheckDate) == currentWeekOfYear {
//                weeklyStatus[index] = 1  // Update only the current day
//            } else {
//                // Reset and update for the new week
//                weeklyStatus = [0, 0, 0, 0, 0, 0, 0]
//                weeklyStatus[index] = 1
//            }
//
//            // Update Firestore with new streak and weekly status
//            userRef.updateData([
//                "lastCheck": FieldValue.serverTimestamp(),
//                "weeklyStatus": weeklyStatus,
//                "dailyCheckInStreak": dailyCheckInStreak
//            ]) { error in
//                if let error = error {
//                    print("Error updating check-in data: \(error)")
//                } else {
//                    print("Check-in data and streak updated successfully")
//                }
//                Task {
//                    await viewModel.fetchUser()
//                }
//            }
//        }
//    }
//
//
//}
//
//struct MoodEntry: Identifiable {
//    var id = UUID()
//    var date: Date
//    var mood: Int
//
//    var formattedDate: String {
//        date.formatted(date: .abbreviated, time: .omitted)
//    }
//}
