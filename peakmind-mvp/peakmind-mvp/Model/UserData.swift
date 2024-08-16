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
    var selectedWidgets: [CustomWidget]
    var lastCheck: Date?
    var weeklyStatus: [Int]
    var hasCompletedTutorial: Bool
    var completedLevels: [String]
    var completedLevels2: [String]
    var dailyCheckInStreak: Int
    var bio: String
    var routines: [Routine] = []


    enum CodingKeys: String, CodingKey {
        case id
        case email
        case username
        case selectedWidgets
        case selectedAvatar
        case selectedBackground
        case friends
        case hasCompletedInitialQuiz
        case hasSetInitialAvatar
        case inventory
        case LevelOneCompleted
        case LevelTwoCompleted
        case lastCheck
        case weeklyStatus
        case hasCompletedTutorial
        case completedLevels
        case completedLevels2
        case dailyCheckInStreak
        case bio
        case routines
    }
    
    
    init(id: String, email: String, username: String, selectedAvatar: String, selectedBackground: String, hasCompletedInitialQuiz: Bool, hasSetInitialAvatar: Bool, inventory: [String], friends: [String], LevelOneCompleted: Bool, LevelTwoCompleted: Bool, selectedWidgets: [CustomWidget], lastCheck: Date?, weeklyStatus: [Int], hasCompletedTutorial: Bool, completedLevels: [String], completedLevels2: [String], dailyCheckInStreak: Int, bio: String, routines: [Routine]) {
        self.id = id
        self.email = email
        self.username = username
        self.selectedAvatar = selectedAvatar
        self.selectedBackground = selectedBackground
        self.hasCompletedInitialQuiz = hasCompletedInitialQuiz
        self.hasSetInitialAvatar = hasSetInitialAvatar
        self.inventory = inventory
        self.friends = friends
        self.LevelOneCompleted = LevelOneCompleted
        self.LevelTwoCompleted = LevelTwoCompleted
        self.selectedWidgets = selectedWidgets
        self.lastCheck = lastCheck
        self.weeklyStatus = weeklyStatus
        self.hasCompletedTutorial = hasCompletedTutorial
        self.completedLevels = completedLevels
        self.completedLevels2 = completedLevels2
        self.dailyCheckInStreak = dailyCheckInStreak
        self.bio = bio
        self.routines = routines
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        username = try container.decode(String.self, forKey: .username)
        friends = try container.decode([String].self, forKey: .friends)
        selectedWidgets = try container.decode([CustomWidget].self, forKey: .selectedWidgets)
        selectedAvatar = try container.decode(String.self, forKey: .selectedAvatar)
        selectedBackground = try container.decode(String.self, forKey: .selectedBackground)
        hasCompletedInitialQuiz = try container.decode(Bool.self, forKey: .hasCompletedInitialQuiz)
        hasSetInitialAvatar = try container.decode(Bool.self, forKey: .hasSetInitialAvatar)
        inventory = try container.decode([String].self, forKey: .inventory)
        LevelOneCompleted = try container.decode(Bool.self, forKey: .LevelOneCompleted)
        LevelTwoCompleted = try container.decode(Bool.self, forKey: .LevelTwoCompleted)
        lastCheck = try? container.decode(Date.self, forKey: .lastCheck)
        weeklyStatus = try container.decode([Int].self, forKey: .weeklyStatus)
        hasCompletedTutorial = try container.decode(Bool.self, forKey: .hasCompletedTutorial)
        completedLevels = try container.decode([String].self, forKey: .completedLevels)
        completedLevels2 = try container.decode([String].self, forKey: .completedLevels2)
        dailyCheckInStreak = try container.decode(Int.self, forKey: .dailyCheckInStreak)
        bio = try container.decode(String.self, forKey: .bio)
        routines = try container.decode([Routine].self, forKey: .routines)

        
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(username, forKey: .username)
        try container.encode(friends, forKey: .friends)

        try container.encode(selectedWidgets, forKey: .selectedWidgets)
        try container.encode(selectedAvatar, forKey: .selectedAvatar)
        try container.encode(selectedBackground, forKey: .selectedBackground)
        try container.encode(hasCompletedInitialQuiz, forKey: .hasCompletedInitialQuiz)
        try container.encode(hasSetInitialAvatar, forKey: .hasSetInitialAvatar)
        try container.encode(inventory, forKey: .inventory)
        try container.encode(LevelOneCompleted, forKey: .LevelOneCompleted)
        try container.encode(LevelTwoCompleted, forKey: .LevelTwoCompleted)
        try container.encodeIfPresent(lastCheck, forKey: .lastCheck)
        try container.encode(weeklyStatus, forKey: .weeklyStatus)
        try container.encode(hasCompletedTutorial, forKey: .hasCompletedTutorial)
        try container.encode(completedLevels, forKey: .completedLevels)
        try container.encode(completedLevels2, forKey: .completedLevels2)
        try container.encode(dailyCheckInStreak, forKey: .dailyCheckInStreak)
        try container.encode(bio, forKey: .bio)
        try container.encode(routines, forKey: .routines)

    }
    
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: username) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}
