//
//  User.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 2/17/24.
//

import Foundation


struct User : Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    let location: String
    let color: String
    let firstPeak: String
    let username: String
    let selectedAvatar: String
    let selectedBackground: String
    let hasCompletedInitialQuiz: Bool
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
            
    }
}

extension User {
    static var MOCK_USER = User(id: NSUUID().uuidString, fullname: "Raj Jagirdar", email: "gmail@raj.com", location: "New York", color: "#000", firstPeak: "Depression", username: "slayer5540", selectedAvatar: "asian", selectedBackground: "blue", hasCompletedInitialQuiz: false)
}
