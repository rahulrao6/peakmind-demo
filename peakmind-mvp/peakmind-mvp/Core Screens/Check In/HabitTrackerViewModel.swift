//
//  HabitTrackerViewModel.swift
//  peakmind-mvp
//
//  Created by Katharina Reimer on 4/1/24.
//

import Foundation

struct Habit: Identifiable, Hashable {
    let id: UUID = UUID()
    var name: String
    var complete: Bool = false
}

class HabitTrackerViewModel: ObservableObject {
    // TODO: make this associated with the user's account
    var dailyHabits: [Habit] = [Habit(name: "Gaslight"),
                                Habit(name: "Gatekeep"),
                                Habit(name: "Girlboss"),
                                Habit(name: "etc"),
                                Habit(name: "etc"),
                                Habit(name: "etc"),
                                Habit(name: "etc")]
    
    var habits: [Habit] = [Habit(name: "Gaslight"),
                          Habit(name: "Gatekeep"),
                          Habit(name: "Girlboss")]
 
    init() {}
    
    func submit() {
        // TODO: store the data from all of the changed variables to a dataset
            // should be based on date, every time it submits it should update
            // the data from that date rather than make a new data set
            // ask rina if this doesn't make sense
        
        
    }
}
