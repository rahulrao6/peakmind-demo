//
//  PersonalizedPlanView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 2/27/24.
//

import SwiftUI

struct PersonalizedPlanView: View {
    @State private var currentTasksExpanded = false
    @State private var goalsExpanded = false
    @State private var habitsExpanded = false

    var body: some View {
        ZStack {
            Image("ChatBG2")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
                .opacity(1)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    sectionView(title: "Current Tasks", expanded: $currentTasksExpanded, category: "Testing Long Current Task Name Example", color: Color("Navy Blue"))
                    sectionView(title: "Goals", expanded: $goalsExpanded, category: "Extended Goal Name for Testing", color: Color("Medium Blue"))
                    sectionView(title: "Habits", expanded: $habitsExpanded, category: "Habit with a Significantly Longer Name", color: Color("Ice Blue"))
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
    }

    @ViewBuilder
    private func sectionView(title: String, expanded: Binding<Bool>, category: String, color: Color) -> some View {
        DisclosureGroup(title, isExpanded: expanded) {
            VStack(alignment: .leading, spacing: 5) {
                ForEach(1...5, id: \.self) { index in
                    TaskCard(taskTitle: "\(category) \(index)")
                        .padding(.leading, 0)
                        .padding(.top, index == 1 ? 10 : 0)  // Adds more space before the first task
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(color))
        .foregroundColor(.white)
    }

}

struct TaskCard: View {
    var taskTitle: String

    var body: some View {
        NavigationLink(destination: TaskDetailView(taskTitle: taskTitle)) {
            Text(truncatedTaskName(taskTitle))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                .foregroundColor(.black)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // Function to truncate task names manually
    private func truncatedTaskName(_ name: String) -> String {
        let maxLength = 20  // Set the max length you prefer
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
