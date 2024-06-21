import FirebaseFirestoreSwift
import FirebaseFirestore
import Foundation

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var content: String
    var timestamp: Timestamp
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case content
        case timestamp
    }
}

struct Chat: Identifiable, Codable {
    @DocumentID var id: String?
    var participants: [String]
    var lastMessage: String?
    var timestamp: Timestamp
}
