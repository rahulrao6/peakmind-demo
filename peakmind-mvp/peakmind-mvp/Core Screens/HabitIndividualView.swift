//import SwiftUI
//
//struct HabitIndividualView: View {
//    @State private var count: Int = 0
//    @State private var inputText: String = "0"
//    @State private var hasChanged: Bool = false // State variable to track if a change has been made
//    @State private var showDeleteConfirmation = false // State to show the delete confirmation
//
//    var body: some View {
//        ZStack {
//            // Background gradient
//            LinearGradient(
//                gradient: Gradient(colors: [Color(hex: "112864")!, Color(hex: "23429a")!]),
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .edgesIgnoringSafeArea(.all)
//            
//            VStack {
//                // Add a trash can icon in the top-right corner
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        showDeleteConfirmation = true
//                    }) {
//                        Image(systemName: "trash")
//                            .resizable()
//                            .frame(width: 24, height: 24)
//                            .foregroundColor(.white)
//                            .padding(.trailing, 20)
//                            .padding(.top, 20)
//                    }
//                }
//                .frame(maxWidth: .infinity, alignment: .topTrailing)
//
//                //Spacer() // Add spacer to push content down
//
//                VStack(alignment: .leading) {
//                    // Title: Water Intake
//                    Text("Water Intake")
//                        .font(.custom("SFProText-Heavy", size: 40))
//                        .foregroundColor(.white)
//                        .padding(.top, 20)
//                        .frame(maxWidth: .infinity, alignment: .center) // Center the text horizontally
//
//                    // Circle with "Cups of Water" text
//                    HStack {
//                        ZStack {
//                            Circle()
//                                  .fill(Color.black.opacity(0.3)) // Black fill with 0.3 opacity inside the circle
//                                  .frame(width: 300, height: 300) // Increased size
//
//                            Circle()
//                                .stroke(Color(hex: "b0e8ff")!, lineWidth: 5) // Blue outline and transparent inside
//                                .frame(width: 300, height: 300) // Increased size
//
//                            VStack {
//                                Text("Cups of Water")
//                                    .font(.custom("SFProText-Heavy", size: 28)) // Slightly increased font size
//                                    .foregroundColor(.white) // Set text color to white
//                                    .padding(.top, 5) // Reduce spacing below the text
//                                    .padding(.bottom, -5) // Reduce spacing below the text
//                                
//                                // Minus, text field, and plus buttons in HStack
//                                HStack {
//                                    Button(action: {
//                                        if count > 0 {
//                                            count -= 1
//                                            inputText = "\(count)"
//                                            hasChanged = true // Mark as changed
//                                        }
//                                    }) {
//                                        Image(systemName: "minus.circle.fill")
//                                            .resizable()
//                                            .frame(width: 33, height: 33) // Button size
//                                            .foregroundColor(.red)
//                                    }
//                                    
//                                    TextField("", text: $inputText, onCommit: {
//                                        if let value = Int(inputText) {
//                                            count = value
//                                            hasChanged = true // Mark as changed
//                                        }
//                                    })
//                                    .font(.custom("SFProText-Heavy", size: 80)) // Set the initial font to SFProText-Heavy
//                                    .foregroundColor(.white) // Set text color to white
//                                    .multilineTextAlignment(.center)
//                                    .frame(width: 120) // Adjusted size for better appearance
//                                    .keyboardType(.numberPad)
//                                    .minimumScaleFactor(0.5) // Set the minimum scale factor to allow shrinking
//                                    .lineLimit(1) // Make sure the text stays on one line and shrinks
//                                    .onChange(of: inputText) { newValue in
//                                        if let value = Int(newValue) {
//                                            count = value
//                                            hasChanged = true // Mark as changed
//                                        }
//                                    }
//
//                                    Button(action: {
//                                        count += 1
//                                        inputText = "\(count)"
//                                        hasChanged = true // Mark as changed
//                                    }) {
//                                        Image(systemName: "plus.circle.fill")
//                                            .resizable()
//                                            .frame(width: 33, height: 33) // Button size
//                                            .foregroundColor(.green)
//                                    }
//                                }
//
//                            }
//                        }
//                        .padding(.top, 20) // Optional: Adjust to center vertically
//                    }
//                    .frame(maxWidth: .infinity) // Center the circle horizontally
//
//                    // Conditionally display Save button based on hasChanged state
//                    if hasChanged {
//                        Button(action: {
//                                print("Saved: \(count) cups of water")
//                                hasChanged = false // Reset the change state after saving
//                            }) {
//                                Text("Save")
//                                    .font(.custom("SFProText-Bold", size: 18))
//                                    .foregroundColor(.white)
//                                    .padding()
//                                    .frame(width: 120, height: 50) // Make the button wider
//                                    .background(Color(hex: "161331")!)
//                                    .cornerRadius(10)
//                            }
//                            .padding(.top, 10) // Move Save button closer to the circle
//                            .frame(maxWidth: .infinity) // Center the button horizontally
//                    }
//
//                    // Buttons for Edit Habit and View Analytics
//                    VStack(spacing: 20) {
//                        Button(action: {
//                            print("Edit Habit pressed")
//                        }) {
//                            Text("Edit Habit")
//                                .font(.custom("SFProText-Bold", size: 22))
//                                .foregroundColor(.black)
//                                .padding()
//                                .frame(width: 300, height: 70) // Make the button wider
//                                .background(Color(hex: "b0e8ff")!)
//                                .cornerRadius(10)
//                        }
//
//                        Button(action: {
//                            print("View Analytics pressed")
//                        }) {
//                            Text("View Analytics")
//                                .font(.custom("SFProText-Bold", size: 22))
//                                .foregroundColor(.black)
//                                .padding()
//                                .frame(width: 300, height: 70) // Make the button wider
//                                .background(Color(hex: "b0e8ff")!)
//                                .cornerRadius(10)
//                        }
//                    }
//                    .frame(maxWidth: .infinity) // Center the buttons horizontally
//                    .padding(.top, 20) // Space between Save and the new buttons
//                }
//
//                Spacer() // Add spacer to push content up and down for vertical centering
//            }
//        }
//        // Confirmation dialog for deleting habit
//        .confirmationDialog("Are you sure you want to delete this habit?", isPresented: $showDeleteConfirmation) {
//            Button("Yes", role: .destructive) {
//                print("Habit deleted")
//            }
//            Button("No", role: .cancel) {}
//        }
//    }
//}
//
//
import SwiftUI
import Firebase
struct HabitIndividualView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var count: Int
    @State private var inputText: String
    @State private var hasChanged: Bool = false
    @State private var showDeleteConfirmation = false
    @State private var showAnalyticsView: Bool = false
    @State private var showingEditForm: Bool = false
    @State private var habitsByName: [String: [Habit]] = [:]
    private var db = Firestore.firestore()
    @State private var selectedHabitForAnalytics: Habit? = nil
    @State private var isProgrammaticChange: Bool = false
    let habit: Habit
    let selectedDate: Date

    init(habit: Habit, selectedDate: Date) {
        self.habit = habit
        self.selectedDate = selectedDate
        _count = State(initialValue: habit.count)
        _inputText = State(initialValue: "\(habit.count)")
    }

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
                    // Header with Delete Button
                    HStack {
                        Spacer()
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Image(systemName: "trash")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    
                    // Habit Details
                    VStack(alignment: .center, spacing: 30) {
                        Text(habit.title)
                            .font(.custom("SFProText-Heavy", size: 40))
                            .foregroundColor(.white)
                        
                        // Count Increment Section
                        HStack {
                            Button(action: {
                                if count > 0 {
                                    let increment = -1
                                    print("Minus button tapped, increment: \(increment)")
                                    self.count += increment
                                    self.isProgrammaticChange = true
                                    self.inputText = "\(self.count)"
                                    self.hasChanged = true
                                    self.updateHabit(by: habit.id, increment: increment)
                                    self.isProgrammaticChange = false
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .resizable()
                                    .frame(width: 33, height: 33)
                                    .foregroundColor(.red)
                            }
                            TextField("", text: $inputText, onCommit: {
                                if let value = Int(inputText), !isProgrammaticChange {
                                    let increment = value - self.count
                                    self.count = value
                                    self.hasChanged = true
                                    self.updateHabit(by: habit.id, increment: increment)
                                }
                            })
                            .font(.custom("SFProText-Heavy", size: 80))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(width: 120)
                            .keyboardType(.numberPad)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .onChange(of: inputText) { newValue in
                                if let value = Int(newValue), !isProgrammaticChange {
                                    let increment = value - self.count
                                    self.count = value
                                    self.hasChanged = true
                                    self.updateHabit(by: habit.id, increment: increment)
                                }
                            }

                            Button(action: {
                                let increment = 1
                                print("Plus button tapped, increment: \(increment)")
                                self.count += increment
                                self.isProgrammaticChange = true
                                self.inputText = "\(self.count)"
                                self.hasChanged = true
                                self.updateHabit(by: habit.id, increment: increment)
                                self.isProgrammaticChange = false
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 33, height: 33)
                                    .foregroundColor(.green)
                            }
                                 }
                        
                        // Save Button
                        if hasChanged {
                            Button(action: {
                                saveHabit()
                            }) {
                                Text("Save")
                                    .font(.custom("SFProText-Bold", size: 18))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 120, height: 50)
                                    .background(Color(hex: "161331")!)
                                    .cornerRadius(10)
                            }
                        }
                        
                        // Edit and View Analytics Buttons
                        VStack(spacing: 20) {
                            Button(action: {
                                // Navigate to Edit Habit Form
                                showingEditForm = true
                            }) {
                                Text("Edit Habit")
                                    .font(.custom("SFProText-Bold", size: 22))
                                    .foregroundColor(.black)
                                    .padding()
                                    .frame(width: 300, height: 70)
                                    .background(Color(hex: "b0e8ff")!)
                                    .cornerRadius(10)
                            }

                            Button(action: {
                                selectedHabitForAnalytics = habit
                                showAnalyticsView = true
                            }) {
                                Text("View Analytics")
                                    .font(.custom("SFProText-Bold", size: 22))
                                    .foregroundColor(.black)
                                    .padding()
                                    .frame(width: 300, height: 70)
                                    .background(Color(hex: "b0e8ff")!)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.top, 20)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
            .confirmationDialog("Are you sure you want to delete this habit?", isPresented: $showDeleteConfirmation) {
                Button("Yes", role: .destructive) {
                    deleteHabit()
                }
                Button("No", role: .cancel) {}
            }
            
            .sheet(item: $selectedHabitForAnalytics, onDismiss: {
                selectedHabitForAnalytics = nil
            }) { habit in
                AnalyticsView2(
                    habitHistory: viewModel.habitsByName[habit.title] ?? [],
                    habitTitle: habit.title,
                    habitid: habit.id
                )
                .environmentObject(viewModel)
            }
            
            .sheet(isPresented: $showingEditForm) {
                EditHabitForm(habit: habit, updateAction: { updatedHabit in
                    updateHabit(updatedHabit: updatedHabit)
                })
                .environmentObject(viewModel)
            }
            .onAppear {
                loadHabitHistoryForHabit(habit.title) {
                    print(habitsByName)
                }
            }
        }
    }

    private func updateHabitCount(to newCount: Int) {
        print(inputText)
        print(newCount);
        count = newCount
        inputText = "\(newCount)"
        hasChanged = true
        //updateHabit(by: habit.id, count: newCount)
    }
}
//struct HabitIndividualView: View {
//    @EnvironmentObject var viewModel: AuthViewModel
//    @State private var count: Int
//    @State private var inputText: String
//    @State private var hasChanged: Bool = false
//    @State private var showDeleteConfirmation = false
//    @State private var showAnalyticsView: Bool = false
//    @State private var showingEditForm: Bool = false
//    @State private var habitsByName: [String: [Habit]] = [:]
//    private var db = Firestore.firestore()
//    @State private var selectedHabitForAnalytics: Habit? = nil
//
//    let habit: Habit
//    let selectedDate: Date
//
//    init(habit: Habit, selectedDate: Date) {
//        self.habit = habit
//        self.selectedDate = selectedDate
//        _count = State(initialValue: habit.count)
//        _inputText = State(initialValue: "\(habit.count)")
//    }
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                // Background gradient
//                LinearGradient(
//                    gradient: Gradient(colors: [Color(hex: "112864")!, Color(hex: "23429a")!]),
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                .edgesIgnoringSafeArea(.all)
//                
//                VStack {
//                    // Header with Delete Button
//                    HStack {
//                        Spacer()
//                        Button(action: {
//                            showDeleteConfirmation = true
//                        }) {
//                            Image(systemName: "trash")
//                                .resizable()
//                                .frame(width: 24, height: 24)
//                                .foregroundColor(.white)
//                                .padding()
//                        }
//                    }
//                    
//                    // Habit Details
//                    VStack(alignment: .center, spacing: 30) {
//                        Text(habit.title)
//                            .font(.custom("SFProText-Heavy", size: 40))
//                            .foregroundColor(.white)
//                        
//                        // Count Increment Section
//                        HStack {
//                            Button(action: {
//                                if count > 0 {
////                                    count -= 1
////                                    inputText = "\(count)"
//                                    hasChanged = true
//                                    updateHabit(by: habit.id, increment: -1)
//                                }
//                            }) {
//                                Image(systemName: "minus.circle.fill")
//                                    .resizable()
//                                    .frame(width: 33, height: 33)
//                                    .foregroundColor(.red)
//                            }
//                            
//                            TextField("", text: $inputText, onCommit: {
//                                if let value = Int(inputText) {
//                                    count = value
//                                    hasChanged = true
//                                    updateCount()
//                                }
//                            })
//                            .font(.custom("SFProText-Heavy", size: 80))
//                            .foregroundColor(.white)
//                            .multilineTextAlignment(.center)
//                            .frame(width: 120)
//                            .keyboardType(.numberPad)
//                            .minimumScaleFactor(0.5)
//                            .lineLimit(1)
//                            .onChange(of: inputText) { newValue in
//                                if let value = Int(newValue) {
//                                    let increment = value - count;
//                                    print("change by")
//                                    print(increment)
//                                    count = value
//                                    hasChanged = true
//                                    updateHabit(by: habit.id, increment: increment)
//()
//                                }
//                            }
//
//                            Button(action: {
////                                count += 1
////                                inputText = "\(count)"
//                                hasChanged = true
//                                //updateCount()
//                                updateHabit(by: habit.id, increment: 1)
//                            }) {
//                                Image(systemName: "plus.circle.fill")
//                                    .resizable()
//                                    .frame(width: 33, height: 33)
//                                    .foregroundColor(.green)
//                            }
//                        }
//                        
//                        // Save Button
//                        if hasChanged {
//                            Button(action: {
//                                //saveHabit()
//                            }) {
//                                Text("Save")
//                                    .font(.custom("SFProText-Bold", size: 18))
//                                    .foregroundColor(.white)
//                                    .padding()
//                                    .frame(width: 120, height: 50)
//                                    .background(Color(hex: "161331")!)
//                                    .cornerRadius(10)
//                            }
//                        }
//                        
//                        // Edit and View Analytics Buttons
//                        VStack(spacing: 20) {
//                            Button(action: {
//                                // Navigate to Edit Habit Form
//                                showingEditForm = true
//                            }) {
//                                Text("Edit Habit")
//                                    .font(.custom("SFProText-Bold", size: 22))
//                                    .foregroundColor(.black)
//                                    .padding()
//                                    .frame(width: 300, height: 70)
//                                    .background(Color(hex: "b0e8ff")!)
//                                    .cornerRadius(10)
//                            }
//
//                            Button(action: {
//                                selectedHabitForAnalytics = habit
//                                showAnalyticsView = true
//                            }) {
//                                Text("View Analytics")
//                                    .font(.custom("SFProText-Bold", size: 22))
//                                    .foregroundColor(.black)
//                                    .padding()
//                                    .frame(width: 300, height: 70)
//                                    .background(Color(hex: "b0e8ff")!)
//                                    .cornerRadius(10)
//                            }
//                        }
//                        .padding(.top, 20)
//                    }
//                    
//                    Spacer()
//                }
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .navigationTitle("Habit Details")
//            .confirmationDialog("Are you sure you want to delete this habit?", isPresented: $showDeleteConfirmation) {
//                Button("Yes", role: .destructive) {
//                    deleteHabit()
//                }
//                Button("No", role: .cancel) {}
//            }
//            
//            .sheet(item: $selectedHabitForAnalytics, onDismiss: {
//                selectedHabitForAnalytics = nil
//            }) { habit in
//                AnalyticsView2(
//                    habitHistory: viewModel.habitsByName[habit.title] ?? [],
//                    habitTitle: habit.title,
//                    habitid: habit.id
//                )
//                .environmentObject(viewModel)
//            }
//            
//            
////            .sheet(isPresented: $showAnalyticsView) {
////                AnalyticsView2(
////                    habitHistory: habitsByName[habit.title] ?? [],
////                    habitTitle: habit.title,
////                    habitid: habit.id
////                )
////                .environmentObject(viewModel)
////            }
//            .sheet(isPresented: $showingEditForm) {
//                EditHabitForm(habit: habit, updateAction: { updatedHabit in
//                    updateHabit(updatedHabit: updatedHabit)
//                })
//                .environmentObject(viewModel)
//            }
//            .onAppear{
//                
//                    //loadHabits(for: selectedDate)
//                loadHabitHistoryForHabit(habit.title, completion: {
//                    print(habitsByName)
//                })
//                    print(habitsByName)
//
//
//                
//            }
//        }
//    }
//}

extension HabitIndividualView {
    // Update Count in Firebase
    func updateCount() {
        guard let user = viewModel.currentUser else { return }
        let userID = user.id
        let db = Firestore.firestore()
        
        // Assuming you have a collection "history" under each habit to track daily counts
        let dateKey = getCurrentDateString()
        
        db.collection("users").document(userID).collection("habits").document(habit.id).collection("history").document(dateKey).setData([
            "count": count,
            "date": dateKey
        ], merge: true) { error in
            if let error = error {
                print("Error updating count: \(error.localizedDescription)")
            } else {
                print("Count updated successfully.")
            }
        }
    }
    
    // Save Habit Changes
    func saveHabit() {
        updateCount()
        hasChanged = false
    }
    
    // Edit Habit
    func updateHabit(updatedHabit: Habit) {
        guard let user = viewModel.currentUser else { return }
        let userID = user.id
        let db = Firestore.firestore()
        
        db.collection("users").document(userID).collection("habits").document(updatedHabit.id).setData(updatedHabit.toDictionary(), merge: true) { error in
            if let error = error {
                print("Error updating habit: \(error.localizedDescription)")
            } else {
                print("Habit updated successfully.")
            }
        }
    }
    
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
                habits.removeAll { $0["id"] as? String == habit.id }
                
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
    
    private func dateString(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    // Fetch Habit History
    private func loadHabitHistory() {
        guard let user = viewModel.currentUser else {
            print("No current user")
            return
        }
        let userID = user.id
        
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -30, to: endDate) else {
            print("Failed to calculate start date")
            return
        }
        
        var currentDate = startDate
        let group = DispatchGroup() // To manage asynchronous tasks
        
        while currentDate <= endDate {
            let dateString = dateString(for: currentDate)
            
            group.enter()
            db.collection("users").document(userID).collection("habits").document(dateString).getDocument { document, error in
                defer { group.leave() } // Ensure group.leave() is called
                
                if let error = error {
                    print("Error fetching document for \(dateString): \(error.localizedDescription)")
                    return
                }
                
                guard let document = document, document.exists else {
                    print("No document found for \(dateString)")
                    return
                }
                
                guard let data = document.data(), let habitsData = data["habits"] as? [[String: Any]] else {
                    print("No 'habits' field found in document for \(dateString)")
                    return
                }
                
                let validHabits = habitsData.compactMap { habitData -> Habit? in
                    return createHabit(from: habitData)
                }
                
                if validHabits.isEmpty {
                    print("No valid habits found in document for \(dateString)")
                } else {
                    print("Fetched \(validHabits.count) habits for \(dateString)")
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
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        group.notify(queue: .main) {
            print("Finished loading habit history. habitsByName: \(self.habitsByName)")
        }
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
    
    // Helper to get current date string
    func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    private func updateHabit(by habitId: String, increment: Int) {
        guard let user = viewModel.currentUser else {
            print("No current user")
            return
        }
        print(increment)
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
                        print("newoicounkjbsbdsi \(newCount)")
                        habitData["count"] = newCount
                        habitsData[index] = habitData
                        
                        documentRef.setData(["habits": habitsData], merge: true) { error in
                            if let error = error {
                                print("Error updating habit: \(error.localizedDescription)")
                            } else {
                                print("Habit updated successfully!")
                                //loadHabits(for: selectedDate)
                                //self.updateAllHabitProgress()
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
    
}
