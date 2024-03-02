import Foundation
import SwiftUI

struct JournalEntry: Identifiable, Codable {
    var id: UUID
    var title: String
    var content: String
    var date: Date
    var mood: String
    var tags: [String] // Ensure this property exists

    // Initialize all properties. UUID() provides a default value for id.
    init(id: UUID = UUID(), title: String, content: String, date: Date, mood: String, tags: [String]) {
        self.id = id
        self.title = title
        self.content = content
        self.date = date
        self.mood = mood
        self.tags = tags
    }
    
    // Example moods with system icons and colors (SwiftUI.Color cannot be directly Codable)
    var moodDetails: (iconName: String, color: UIColor) {
        switch mood {
        case "Happy":
            return ("sun.max.fill", .systemYellow)
        case "Sad":
            return ("cloud.rain.fill", .systemBlue)
        case "Anxious":
            return ("wind", .systemGray)
        case "Energized":
            return ("bolt.fill", .systemOrange)
        case "Calm":
            return ("moon.fill", .systemPurple)
        default:
            return ("questionmark.circle", .systemGray)
        }
    }
}
