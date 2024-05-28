import FirebaseFirestoreSwift
import Foundation

struct ChatRoom: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var createdBy: String
    var createdAt: Date
}

struct ChatMessages: Identifiable, Codable {
    @DocumentID var id: String?
    var content: String
    var senderId: String
    var senderName: String
    var timestamp: Date
}
