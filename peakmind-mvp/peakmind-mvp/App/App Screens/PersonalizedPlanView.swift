//
//  PersonalizedPlanView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 2/27/24.
//

import SwiftUI
import FirebaseFirestore


struct PersonalizedPlanView: View {
    @State private var currentTasksExpanded = false
    @State private var goalsExpanded = false
    @State private var habitsExpanded = false
    
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var tasks: [String] = []
    @State private var section: [String] = []
    @State private var habits: [String] = ["Eat 3 meals today", "Go on a walk outside", "Drink a gallon of water today", "Sleep 8 hours tonight"]
    

    var body: some View {
        ZStack {
            Image("ChatBG2")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
                .opacity(1)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    taskListView(title: "Current Tasks", expanded: $currentTasksExpanded, category: "Testing Long Current Task Name Example", color: Color("Navy Blue"))
                    sectionView(title: "Goals", expanded: $goalsExpanded, category: "Extended Goal Name for Testing", color: Color("Medium Blue"))
                    habitListView(title: "Habits", expanded: $habitsExpanded, category: "Habit with a Significantly Longer Name", color: Color("Ice Blue"))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 25)
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.black.opacity(0.5)))
                .padding(.horizontal, 25)
                .padding(.vertical, 20)
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
        .onAppear {
            fetchTasks()
        }
    }

    @ViewBuilder
    private func sectionView(title: String, expanded: Binding<Bool>, category: String, color: Color) -> some View {
        DisclosureGroup(title, isExpanded: expanded) {
            VStack(alignment: .leading, spacing: 5) {
                ForEach(Array(section.enumerated()), id: \.offset) { index, section in
                    TaskCard(taskTitle: section, rank: index + 1)
                        .padding(.leading, 0)
                        .padding(.top, index + 1 == 1 ? 10 : 0)  // Adds more space before the first task
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(color))
        .foregroundColor(.white)
    }
    
    @ViewBuilder
    private func taskListView(title: String, expanded: Binding<Bool>, category: String, color: Color) -> some View {
        DisclosureGroup(title, isExpanded: expanded) {
            VStack(alignment: .leading, spacing: 5) {
                ForEach(Array(tasks.enumerated().prefix(5)), id: \.offset) { index, task in
                    TaskCard(taskTitle: task, rank: index + 1)
                        .padding(.leading, 0)
                        .padding(.top, index + 1 == 1 ? 10 : 0)  // Adds more space before the first task
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(color))
        .foregroundColor(.white)
    }
    
    @ViewBuilder
    private func habitListView(title: String, expanded: Binding<Bool>, category: String, color: Color) -> some View {
        DisclosureGroup(title, isExpanded: expanded) {
            VStack(alignment: .leading, spacing: 5) {
                ForEach(Array(habits.enumerated().prefix(5)), id: \.offset) { index, task in
                    TaskCard(taskTitle: task, rank: index + 1)
                        .padding(.leading, 0)
                        .padding(.top, index + 1 == 1 ? 10 : 0)  // Adds more space before the first task
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
        db.collection("ai_tasks").document(userId).getDocument { document, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                if let document = document, document.exists {
                    if let data = document.data() {
                        let sortedTasks = data.sorted(by: { $0.key < $1.key }).map { $0.value as! String }
                        self.tasks = sortedTasks
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }

}

struct TaskCard: View {
    var taskTitle: String
    var rank: Int


    var body: some View {
        NavigationLink(destination: TaskDetailView(taskTitle: taskTitle)) {
            HStack {
                Text("\(rank).") // Display the rank
                Text(truncatedTaskName(taskTitle))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
            .foregroundColor(.black)

        }
        .buttonStyle(PlainButtonStyle())
    }

    // Function to truncate task names manually
    private func truncatedTaskName(_ name: String) -> String {
        let maxLength = 25  // Set the max length you prefer
        return name.count > maxLength ? String(name.prefix(maxLength - 3)) + "..." : name
    }
}

struct TaskDetailView: View {
    var taskTitle: String  // Full task description

    var body: some View {
        ScrollView {  // Using ScrollView in case the content is too long
            Text(taskTitle)
                .padding()  // Add padding for better readability
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}


struct PersonalizedPlanView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PersonalizedPlanView()
        }
    }
}
