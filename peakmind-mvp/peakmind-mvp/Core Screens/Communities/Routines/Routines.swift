//
//  Routines.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 8/9/24.
//

import Foundation
import FirebaseFirestore

struct Habits: Identifiable, Codable {
    enum Frequency: String, Codable {
            case daily
            case weekly
        }

        var id: String
        var name: String
        var requiredStreak: Int
        var currentStreak: Int
        var isUnlocked: Bool
        var lastCompletedDate: Date?
        var frequency: Frequency
        var scheduleTime: Date?
        var eventIdentifier: String?
        // Custom initializer
        init(id: String = UUID().uuidString,
             name: String,
             requiredStreak: Int,
             currentStreak: Int = 0,
             isUnlocked: Bool = false,
             lastCompletedDate: Date? = nil,
             frequency: Frequency = .daily,
             scheduleTime: Date? = nil,
             eventIdentifier: String? = nil) {
            self.id = id
            self.name = name
            self.requiredStreak = requiredStreak
            self.currentStreak = currentStreak
            self.isUnlocked = isUnlocked
            self.lastCompletedDate = lastCompletedDate
            self.frequency = frequency
            self.scheduleTime = scheduleTime
            self.eventIdentifier = eventIdentifier
        }

        enum CodingKeys: String, CodingKey {
            case id, name, requiredStreak, currentStreak, isUnlocked, lastCompletedDate, frequency, scheduleTime, eventIdentifier
        }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        requiredStreak = try container.decode(Int.self, forKey: .requiredStreak)
        currentStreak = try container.decode(Int.self, forKey: .currentStreak)
        isUnlocked = try container.decode(Bool.self, forKey: .isUnlocked)
        frequency = try container.decode(Frequency.self, forKey: .frequency)

        // Handle FIRTimestamp conversion
        if let timestamp = try? container.decode(Timestamp.self, forKey: .lastCompletedDate) {
            lastCompletedDate = timestamp.dateValue()
        } else {
            lastCompletedDate = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(requiredStreak, forKey: .requiredStreak)
        try container.encode(currentStreak, forKey: .currentStreak)
        try container.encode(isUnlocked, forKey: .isUnlocked)
        try container.encode(frequency, forKey: .frequency)

        // Convert Date to Timestamp before encoding
        if let date = lastCompletedDate {
            let timestamp = Timestamp(date: date)
            try container.encode(timestamp, forKey: .lastCompletedDate)
        }
    }
}


struct Routine: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var description: String?  // Optional description
    var targetDate: Date?  // Optional target date
    var habits: [Habits]
}

import SwiftUI

struct CreateRoutineView: View {
    @ObservedObject var viewModel: AuthViewModel

    @State private var routineName: String = ""
    @State private var routineDescription: String = ""
    @State private var targetDate = Date()
    @State private var habits: [Habits] = []
    @State private var habitName: String = ""
    @State private var habitStreak: Int = 1
    @State private var habitFrequency: Habits.Frequency = .daily
    @State private var habitScheduleTime = Date()
    @EnvironmentObject var eventKitManager: EventKitManager


    var body: some View {
        VStack(alignment: .leading) {
            Text("Create a New Routine")
                .font(.largeTitle)
                .padding()

            TextField("Routine Name", text: $routineName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("Description", text: $routineDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            DatePicker("Target Completion Date", selection: $targetDate, displayedComponents: .date)
                .padding()

            Text("Habits")
                .font(.headline)
                .padding(.horizontal)


            HStack {
                TextField("Habit Name", text: $habitName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Stepper("Days: \(habitStreak)", value: $habitStreak, in: 1...365)
            }
            .padding()

            DatePicker("Schedule Time", selection: $habitScheduleTime, displayedComponents: [.hourAndMinute])
                .padding(.horizontal)

            Picker("Frequency", selection: $habitFrequency) {
                Text("Daily").tag(Habits.Frequency.daily)
                Text("Weekly").tag(Habits.Frequency.weekly)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            Button(action: addHabit) {
                Text("Add Habit")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)

            List {
                ForEach(habits) { habit in
                    VStack(alignment: .leading) {
                        Text(habit.name)
                            .font(.headline)
                        Text("Streak: \(habit.requiredStreak) days")
                            .font(.subheadline)
                    }
                }
                .onDelete(perform: deleteHabit)
            }

            Spacer()

            Button(action: saveRoutine) {
                Text("Save Routine")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
    }

    private func addHabit() {
        let newHabit = Habits(name: habitName, requiredStreak: habitStreak, frequency: habitFrequency, scheduleTime: habitScheduleTime)
        habits.append(newHabit)
        habitName = ""
        habitStreak = 1
        habitScheduleTime = Date()
    }

    private func deleteHabit(at offsets: IndexSet) {
        habits.remove(atOffsets: offsets)
    }

    private func saveRoutine() {
        Task {
            do {
                let routine = Routine(name: routineName, description: routineDescription, habits: habits)
                try await viewModel.createRoutine(name: routine.name, description: routine.description ?? "", habits: routine.habits)

                var updatedHabits = routine.habits

                // Schedule events for each habit
                for (index, habit) in routine.habits.enumerated() {
                    if let scheduleTime = habit.scheduleTime {
                        let eventIdentifier = await eventKitManager.scheduleRecurringEvent(
                            title: habit.name,
                            startDate: scheduleTime,
                            frequency: habit.frequency == .daily ? .daily : .weekly
                        )
                        // Update the habit with the event identifier
                        updatedHabits[index].eventIdentifier = eventIdentifier
                    }
                }

                // Update the routine with the updated habits
                var updatedRoutine = routine
                updatedRoutine.habits = updatedHabits

                // Update the routine in Firestore
                try await viewModel.updateRoutine(updatedRoutine)

                // Update the local state
                if let index = viewModel.currentUser?.routines.firstIndex(where: { $0.id == routine.id }) {
                    viewModel.currentUser?.routines[index] = updatedRoutine
                } else {
                    viewModel.currentUser?.routines.append(updatedRoutine)
                }
            } catch {
                print("Failed to save routine: \(error.localizedDescription)")
            }
        }
    }
}

import SwiftUI

struct EditRoutineView: View {
    @ObservedObject var viewModel: AuthViewModel
    var routine: Routine

    @State private var routineName: String
    @State private var routineDescription: String
    @State private var targetDate: Date
    @State private var habits: [Habits]
    @State private var habitName: String = ""
    @State private var habitStreak: Int = 1

    init(viewModel: AuthViewModel, routine: Routine) {
        self.viewModel = viewModel
        self.routine = routine
        _routineName = State(initialValue: routine.name)
        _routineDescription = State(initialValue: routine.description ?? "")
        _targetDate = State(initialValue: Date())  // Assuming routine has a target date
        _habits = State(initialValue: routine.habits)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Edit Routine")
                .font(.largeTitle)
                .padding()

            TextField("Routine Name", text: $routineName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("Description", text: $routineDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            DatePicker("Target Completion Date", selection: $targetDate, displayedComponents: .date)
                .padding()

            Text("Habits")
                .font(.headline)
                .padding(.horizontal)

            HStack {
                TextField("Habit Name", text: $habitName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Stepper("Days: \(habitStreak)", value: $habitStreak, in: 1...365)
            }
            .padding()

            Button(action: addHabit) {
                Text("Add Habit")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)

            List {
                ForEach(habits) { habit in
                    VStack(alignment: .leading) {
                        Text(habit.name)
                            .font(.headline)
                        Text("Streak: \(habit.requiredStreak) days")
                            .font(.subheadline)
                    }
                }
                .onDelete(perform: deleteHabit)
            }

            Spacer()

            Button(action: saveRoutine) {
                Text("Save Changes")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
    }

    private func addHabit() {
        let newHabit = Habits(name: habitName, requiredStreak: habitStreak)
        habits.append(newHabit)
        habitName = ""
        habitStreak = 1
    }

    private func deleteHabit(at offsets: IndexSet) {
        habits.remove(atOffsets: offsets)
    }

    private func saveRoutine() {
        Task {
            do {
                guard let index = viewModel.currentUser?.routines.firstIndex(where: { $0.id == routine.id }) else { return }

                viewModel.currentUser?.routines[index].name = routineName
                viewModel.currentUser?.routines[index].habits = habits
               // viewModel.currentUser?.routines[index].description = routineDescription
                // Update in Firestore
                try await viewModel.updateRoutine(viewModel.currentUser?.routines[index])
            } catch {
                print("Failed to save routine: \(error.localizedDescription)")
            }
        }
    }
}
import SwiftUI

struct RoutineTrackingView: View {
    @ObservedObject var viewModel: AuthViewModel
    @EnvironmentObject var eventKitManager: EventKitManager

    @Binding var routine: Routine
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading) {
            Text(routine.name)
                .font(.largeTitle)
                .padding()

            List {
                ForEach($routine.habits) { $habits in
                    HabitRowView(viewModel: viewModel, habits: $habits, routineID: routine.id, errorMessage: $errorMessage).environmentObject(eventKitManager)
                }
            }
        }
        .onAppear {
            checkAndResetStreaks()
        }
        .alert(item: Binding(
            get: { errorMessage.map { ErrorWrapper(error: $0) } },
            set: { errorMessage = $0?.error }
        )) { errorWrapper in
            Alert(title: Text("Error"), message: Text(errorWrapper.error), dismissButton: .default(Text("OK")))
        }
    }

    private func checkAndResetStreaks() {
        Task {
            do {
                try await viewModel.checkAndResetStreaks()
            } catch {
                errorMessage = "Failed to check and reset streaks: \(error.localizedDescription)"
            }
        }
    }
}

struct HabitRowView: View {
    @ObservedObject var viewModel: AuthViewModel
    @EnvironmentObject var eventKitManager: EventKitManager
    @Binding var habits: Habits
    let routineID: String
    @Binding var errorMessage: String?

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(habits.name)
                    .font(.headline)
                Text("Streak: \(habits.currentStreak) / \(habits.requiredStreak) \(habits.frequency == .daily ? "days" : "weeks")")
                    .font(.subheadline)
            }

            Spacer()

            if habits.isUnlocked && !viewModel.isHabitCompletedToday(habits) {
                Button(action: {
                    completeHabit()
                }) {
                    Text("Complete")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            } else {
                Text(habits.isUnlocked ? "Completed" : "Locked")
                    .padding()
                    .background(habits.isUnlocked ? Color.gray : Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }

    private func completeHabit() {
        Task {
            do {
                try await viewModel.completeHabit(routineID: routineID, habitID: habits.id)

                // Remove the calendar event if it exists
                if let eventIdentifier = habits.eventIdentifier {
                    await eventKitManager.removeEvent(withIdentifier: eventIdentifier)
                    habits.eventIdentifier = nil
                }

                // Update the routine in Firestore
                if let routineIndex = viewModel.currentUser?.routines.firstIndex(where: { $0.id == routineID }),
                   let habitIndex = viewModel.currentUser?.routines[routineIndex].habits.firstIndex(where: { $0.id == habits.id }) {
                    viewModel.currentUser?.routines[routineIndex].habits[habitIndex] = habits
                    try await viewModel.updateRoutine(viewModel.currentUser?.routines[routineIndex])
                }
            } catch {
                errorMessage = "Failed to complete habit: \(error.localizedDescription)"
            }
        }
    }
}

struct ErrorWrapper: Identifiable {
    let id = UUID()
    let error: String
}


import SwiftUI
import SwiftUI

struct RoutineListView: View {
    @ObservedObject var viewModel: AuthViewModel
    @EnvironmentObject var eventKitManager: EventKitManager

    var body: some View {
        NavigationView {
            List {
                if let routines = viewModel.currentUser?.routines {
                    ForEach(routines.indices, id: \.self) { index in
                        NavigationLink(
                            destination: RoutineTrackingView(
                                viewModel: viewModel,
                                routine: Binding(
                                    get: { viewModel.currentUser!.routines[index] },
                                    set: { viewModel.currentUser!.routines[index] = $0 }
                                )
                            )
                        ) {
                            VStack(alignment: .leading) {
                                Text(routines[index].name)
                                    .font(.headline)
                                Text("Habits: \(routines[index].habits.count)")
                                    .font(.subheadline)
                            }
                        }
                    }
                    .onDelete(perform: deleteRoutine)
                }
            }
            .navigationTitle("My Routines")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CreateRoutineView(viewModel: viewModel).environmentObject(eventKitManager)) {
                        Text("Add Routine")
                    }
                }
            }
        }
    }

    private func deleteRoutine(at offsets: IndexSet) {
        Task {
            do {
                for index in offsets {
                    if let routine = viewModel.currentUser?.routines[index] {
                        try await viewModel.deleteRoutine(routine)
                        viewModel.currentUser?.routines.remove(at: index)
                    }
                }
            } catch {
                print("Failed to delete routine: \(error.localizedDescription)")
            }
        }
    }
}
