//
//  UserData.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 4/15/24.
//

import Foundation


//struct UserData : Identifiable, Codable {
//    let id: String
//    let email: String
//    let username: String
//    let selectedAvatar: String
//    let selectedBackground: String
//    let hasCompletedInitialQuiz: Bool
//    let hasSetInitialAvatar: Bool
//    let inventory: Array<String>
//    let LevelOneCompleted: Bool
//    let LevelTwoCompleted: Bool
//    let selectedWidgets: Array<String>
//    let lastCheck: Date?
//    let weeklyStatus: [Int]
//    let hasCompletedTutorial: Bool
//    var completedLevels: [String]
//    var completedLevels2: [String]
//    var dailyCheckInStreak: Int
//    
//    var initials: String {
//        let formatter = PersonNameComponentsFormatter()
//        if let components = formatter.personNameComponents(from: username) {
//            formatter.style = .abbreviated
//            return formatter.string(from: components)
//        }
//        return ""
//            
//    }
//}

struct UserData: Identifiable, Codable {
    var id: String
    var email: String
    var username: String
    var selectedAvatar: String
    var selectedBackground: String
    var hasCompletedInitialQuiz: Bool
    var hasSetInitialAvatar: Bool
    var inventory: [String]
    var friends: [String]
    var LevelOneCompleted: Bool
    var LevelTwoCompleted: Bool
    var selectedWidgets: [String]
    var lastCheck: Date?
    var weeklyStatus: [Int]
    var hasCompletedTutorial: Bool
    var completedLevels: [String]
    var completedLevels2: [String]
    var dailyCheckInStreak: Int

    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: username) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}
