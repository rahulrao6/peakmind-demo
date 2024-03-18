//
//  PersonalizedPlanNew.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/17/24.
//

import SwiftUI

struct PersonalizedPlanNew: View {
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
            Image("ChatBG2")
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
    private func taskListView2(title: String, expanded: Binding<Bool>, color: Color) -> some View {
        DisclosureGroup(title, isExpanded: expanded) {
            VStack(alignment: .leading, spacing: 5) {
                ForEach(tasks2.indices, id: \.self) { index in
                    if !tasks2[index].isCompleted {
                        TaskCard22(task: $tasks2[index])
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
    private func goalListView2(title: String, expanded: Binding<Bool>, color: Color) -> some View {
        DisclosureGroup(title, isExpanded: expanded) {
            VStack(alignment: .leading, spacing: 5) {
                ForEach(goals2.indices, id: \.self) { index in
                    if !goals2[index].isCompleted {
                        TaskCard22(task: $goals2[index])
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
                Checkbox2(isChecked: $task.isCompleted, showConfetti: $showConfetti)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
            .foregroundColor(.black)
        }
    }
}




struct Checkbox2: View {
    @Binding var isChecked: Bool
    @Binding var showConfetti: Bool

    var body: some View {
        Image(systemName: isChecked ? "checkmark.square.fill" : "square")
            .onTapGesture {
                self.isChecked.toggle()
                if self.isChecked {
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



