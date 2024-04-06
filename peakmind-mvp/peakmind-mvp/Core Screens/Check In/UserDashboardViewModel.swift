//
//  UserDashboardViewModel.swift
//  peakmind-mvp
//
//  Created by Katharina Reimer on 4/2/24.
//

import Foundation

struct TrackedFeature: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var day: Int // TODO: make this based on date
    var score: Int
}

class UserDashboardViewModel: ObservableObject {
    @Published var weeklyMood = [TrackedFeature(day: 0, score: 3),
                                 TrackedFeature(day: 1, score: -3),
                                 TrackedFeature(day: 2, score: 2),
                                 TrackedFeature(day: 3, score: 1),
                                 TrackedFeature(day: 4, score: 2),
                                 TrackedFeature(day: 5, score: 3),
                                 TrackedFeature(day: 6, score: 1)]
    @Published var weeklyHabits = [TrackedFeature(day: 0, score: 3),
                                 TrackedFeature(day: 1, score: 3),
                                 TrackedFeature(day: 2, score: 7),
                                 TrackedFeature(day: 3, score: 10),
                                 TrackedFeature(day: 4, score: 8),
                                 TrackedFeature(day: 5, score: 3),
                                 TrackedFeature(day: 6, score: 10)]
    
    
    init() {}
}
