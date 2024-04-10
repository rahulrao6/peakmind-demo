//
//  CheckInViewModel.swift
//  peakmind-mvp
//
//  Created by Katharina Reimer on 3/30/24.
//

import Foundation

struct MoodOption: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var name: String
    var scoreMod: Int
}

class CheckInViewModel: ObservableObject {
    // TODO: make these something variable on what widgets chosen
    @Published var moodOptions = [MoodOption(name: "Happy", scoreMod: 3),
                                  MoodOption(name: "Sad", scoreMod: -3),
                                  MoodOption(name: "Angry", scoreMod: -4),
                                  MoodOption(name: "Bored", scoreMod: 0),]
    @Published var moodSelected = Set<MoodOption>()
    @Published var mealCount = 3.0
    @Published var washFace = true
    @Published var glassesWater = 13.0
    @Published var stressLevel = 3.0
    @Published var sleepDuration = 8.0
    @Published var goalResponse = ""
    
    init() {}
    
    func moodScore() -> Int {
        var moodScore = 0
        for i in moodSelected ?? [] {
            moodScore += i.scoreMod
        }
        return moodScore
    }
    
    func submit() {
        // TODO: store the data from all of the changed variables to a dataset
            // should be based on date, every time it submits it should update
            // the data from that date rather than make a new data set
            // ask rina if this doesn't make sense
    }
    
}
