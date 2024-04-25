//
//  PersonalizedPlanNew.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/17/24.
//

import SwiftUI
import FirebaseFirestore

struct PersonalizedPlanNew: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var tasks: [TaskFirebase] = []
    @State private var goals: [GoalFirebase] = []
    @State private var currentTasksExpanded2 = false
    @State private var goalsExpanded2 = false
    @State private var habitsExpanded2 = false
    @State private var tasks2: [Task2] = [Task2(name: "Task 1", isCompleted: false), Task2(name: "Task 2", isCompleted: false)]
    @State private var goals2: [Task2] = [Task2(name: "Goal 1", isCompleted: false), Task2(name: "Goal 2", isCompleted: false)]
    @State private var habits2: [Task2] = [Task2(name: "Eat 3 meals today", isCompleted: false),
                                           Task2(name: "Go on a walk outside", isCompleted: false),
                                           Task2(name: "Drink a gallon of water today", isCompleted: false),
                                           Task2(name: "Sleep 8 hours tonight", isCompleted: false)]
    

    var body: some View {
        ZStack {
            Image("MainBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
                .opacity(1)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    taskListView2(title: "Current Tasks", expanded: $currentTasksExpanded2, color: Color("Navy Blue"))
                    goalListView2(title: "Goals", expanded: $goalsExpanded2, color: Color("Medium Blue"))
                    habitListView2(title: "Habits", expanded: $habitsExpanded2, color: Color("Ice Blue"))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 25)
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.black.opacity(0.5)))
                .padding(.horizontal, 25)
                .padding(.vertical, 20)
            }
        }
        .onAppear() {
            //print("this")
            Task{
                try fetchTasks()
            }
            
            Task{
                try await fetchGoals()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text("Your Plan")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
            }
        }
    }
    
    var uncompletedTasks: [TaskFirebase] {
        Array(tasks.filter { !$0.isCompleted }.prefix(5))
    }

    @ViewBuilder
        private func taskListView2(title: String, expanded: Binding<Bool>, color: Color) -> some View {
            DisclosureGroup(title, isExpanded: expanded) {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(uncompletedTasks.indices, id: \.self) { index in
                        TaskCardFirebase(task: $tasks[$tasks.firstIndex(where: { $0.id == uncompletedTasks[index].id })!])
                            .padding(.leading, 0)
                            .padding(.top, index == 0 ? 10 : 0)
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(color))
            .foregroundColor(.white)
        }

    @ViewBuilder
    private func goalListView2(title: String, expanded: Binding<Bool>, color: Color) -> some View {
        DisclosureGroup(title, isExpanded: expanded) {
            VStack(alignment: .leading, spacing: 5) {
                ForEach(goals.indices, id: \.self) { index in
                    if !goals[index].isCompleted {
                        GoalCardFirebase(goal: $goals[index])
                            .padding(.leading, 0)
                            .padding(.top, index == 0 ? 10 : 0)
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(color))
        .foregroundColor(.white)
    }

    @ViewBuilder
    private func habitListView2(title: String, expanded: Binding<Bool>, color: Color) -> some View {
        DisclosureGroup(title, isExpanded: expanded) {
            VStack(alignment: .leading, spacing: 5) {
                ForEach(habits2.indices, id: \.self) { index in
                    if !habits2[index].isCompleted {
                        TaskCard22(task: $habits2[index])
                            .padding(.leading, 0)
                            .padding(.top, index == 0 ? 10 : 0)
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(color))
        .foregroundColor(.white)
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
    
    func fetchGoals() async throws {
        guard let currentUser = viewModel.currentUser else {
            print("No current user")
            return
        }

        let db = Firestore.firestore()
        let userId = currentUser.id

        let snapshot = try await db.collection("goals").document(userId).collection("user_goals").getDocuments()

        goals = snapshot.documents.compactMap { document in
            do {
                var goalData = document.data()
                goalData["id"] = document.documentID // Include the random ID from Firestore as the id property
                
                // Convert Firestore Timestamps to Date
                let expectedDateTimestamp = goalData["expectedDate"] as? Timestamp ?? Timestamp(date: Date())
                let expectedDate = expectedDateTimestamp.dateValue()
                
                var actualDateCompleted: Date?
                if let actualDateTimestamp = goalData["actualDateCompleted"] as? Timestamp {
                    actualDateCompleted = actualDateTimestamp.dateValue()
                }
                
                let isCompleted = goalData["isCompleted"] as? Bool ?? false
                
                // Create GoalFirebase object
                let goal = GoalFirebase(id: goalData["id"] as? String ?? "",
                                         goalText: goalData["goalText"] as? String ?? "",
                                         expectedDate: expectedDate,
                                         actualDateCompleted: actualDateCompleted,
                                         isCompleted: isCompleted)
                return goal
            } catch {
                print("Error decoding goal: \(error.localizedDescription)")
                return nil
            }
        }
    }





    
}

struct TaskFirebase: Identifiable{
    var id: String
    var isCompleted: Bool
    var name: String
    var rank: Int
    var timeCompleted: String // You might want to convert this to Date type if needed
}

struct GoalFirebase: Identifiable, Decodable {
    var id: String // Random ID generated by Firestore
    var goalText: String
    var expectedDate: Date // Convert Firestore Timestamp to Date
    var actualDateCompleted: Date? // Optional Date for actual date completed
    var isCompleted: Bool
}


struct TaskCardFirebase: View {
    @Binding var task: TaskFirebase
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            if showConfetti {
                ConfettiView(animate: showConfetti)
            }


            HStack {
                Text(task.name)
                Spacer()
                CheckboxFirebase(rank: $task.rank, isCompleted: $task.isCompleted, taskId: $task.id, showConfetti: $showConfetti)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
            .foregroundColor(.black)
        }
    }
}

struct GoalCardFirebase: View {
    @Binding var goal: GoalFirebase
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            if showConfetti {
                ConfettiView(animate: showConfetti)
            }


            HStack {
                Text(goal.goalText)
                Spacer()
                CheckboxGoalFirebase(isCompleted: $goal.isCompleted, taskId: $goal.id, showConfetti: $showConfetti)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
            .foregroundColor(.black)
        }
    }
}


struct Task2: Identifiable {
    var id = UUID()
    var name: String
    var isCompleted: Bool
}

struct TaskCard22: View {
    @Binding var task: Task2
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            if showConfetti {
                ConfettiView(animate: showConfetti)
            }


            HStack {
                Text(task.name)
                Spacer()
                Checkbox2(isCompleted: $task.isCompleted, showConfetti: $showConfetti)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
            .foregroundColor(.black)
        }
    }
}


struct CheckboxFirebase: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Binding var rank: Int
    @Binding var isCompleted: Bool
    @Binding var taskId: String
    @Binding var showConfetti: Bool

    var body: some View {
        Image(systemName: isCompleted ? "checkmark.square.fill" : "square")
            .onTapGesture {
                self.isCompleted.toggle()
                if self.isCompleted {
                    //showConfetti = true
                    //DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                      //  showConfetti = false
                    //}
                    // Call updateTask function to update Firestore
                    updateTask()
                }
            }
    }
    
    func updateTask() {
        // Fetch userId from viewModel
        guard let userId = viewModel.currentUser?.id else {
            print("No current user")
            return
        }

        // Access Firestore instance
        let db = Firestore.firestore()

        // Reference to the document in ai_tasks collection
        let documentRef = db.collection("ai_tasks").document(userId)

        // Update the specific fields in the document using the rank as key identifier
        documentRef.getDocument { document, error in
            if let error = error {
                print("Error getting document: \(error.localizedDescription)")
                return
            }

            guard let document = document, document.exists else {
                print("Document does not exist")
                return
            }

            var taskData = document.data() ?? [:]

            // Update the task object with taskId
            if let taskToUpdate = taskData[String(self.rank)] as? [String: Any] {
                // Safely unwrap taskData[String(self.rank)]
                if var taskToUpdate = taskToUpdate as? [String: Any] {
                    // Update isCompleted and timeCompleted for the specific task
                    taskToUpdate["isCompleted"] = self.isCompleted
                    taskToUpdate["timeCompleted"] = self.isCompleted ? Timestamp(date: Date()) : FieldValue.delete()

                    // Update the taskData with modified taskToUpdate
                    taskData[String(self.rank)] = taskToUpdate

                    // Update the document with the modified task data
                    documentRef.setData(taskData) { error in
                        if let error = error {
                            print("Error updating task: \(error.localizedDescription)")
                        } else {
                            print("Task updated successfully")
                        }
                    }
                } else {
                    print("Task data is not of type [String: Any]")
                }
            } else {
                print("Task not found with rank")
            }
        }
    }



}
struct CheckboxGoalFirebase: View {
    @EnvironmentObject var viewModel: AuthViewModel
    //@Binding var id: String
    @Binding var isCompleted: Bool
    @Binding var taskId: String
    @Binding var showConfetti: Bool

    var body: some View {
        Image(systemName: isCompleted ? "checkmark.square.fill" : "square")
            .onTapGesture {
                self.isCompleted.toggle()
                if self.isCompleted {
                    showConfetti = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showConfetti = false
                    }
                    // Call updateTask function to update Firestore
                    updateGoal()
                }
            }
    }
    
    func updateGoal() {
        // Fetch userId from viewModel
        guard let userId = viewModel.currentUser?.id else {
            print("No current user")
            return
        }

        // Access Firestore instance
        let db = Firestore.firestore()

        // Reference to the document in goals subcollection under user's document
        let documentRef = db.collection("goals").document(userId).collection("user_goals").document(taskId)

        // Update the specific fields in the document
        documentRef.getDocument { document, error in
            if let error = error {
                print("Error getting document: \(error.localizedDescription)")
                return
            }

            guard let document = document, document.exists else {
                print("Document does not exist")
                return
            }

            var goalData = document.data() ?? [:]

            // Update the goal object with its ID
            if var goalToUpdate = goalData as? [String: Any] {
                // Update isCompleted and timeCompleted for the specific goal
                goalToUpdate["isCompleted"] = self.isCompleted
                goalToUpdate["timeCompleted"] = self.isCompleted ? Timestamp(date: Date()) : FieldValue.delete()

                // Update the document with the modified goal data
                documentRef.setData(goalToUpdate) { error in
                    if let error = error {
                        print("Error updating goal: \(error.localizedDescription)")
                    } else {
                        print("Goal updated successfully")
                    }
                }
            } else {
                print("Goal data is not of type [String: Any]")
            }
        }
    }






}


struct Checkbox2: View {
    
    @Binding var isCompleted: Bool
    
    @Binding var showConfetti: Bool

    var body: some View {
        Image(systemName: isCompleted ? "checkmark.square.fill" : "square")
            .onTapGesture {
                self.isCompleted.toggle()
                if self.isCompleted {
                    showConfetti = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showConfetti = false
                    }
                    
                }
            }
    }
    

}



struct TaskDetailView22: View {
    var taskTitle: String

    var body: some View {
        ScrollView {
            Text(taskTitle)
                .padding()
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PersonalizedPlanNew_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PersonalizedPlanNew()
        }
    }
}
