import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

class MessagesViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var chats: [Chat] = []
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    func sendMessage(chatId: String, message: Message) {
        do {
            let _ = try db.collection("chats").document(chatId).collection("messages").addDocument(from: message)
            updateLastMessage(chatId: chatId, lastMessage: message.content)
        } catch {
            print("Error sending message: \(error.localizedDescription)")
        }
    }

    func fetchMessages(chatId: String) {
        listener?.remove()
        listener = db.collection("chats").document(chatId).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else {
                    print("No messages found")
                    return
                }
                self?.messages = documents.compactMap { try? $0.data(as: Message.self) }
            }
    }
    
    func createChat(with participants: [String], completion: @escaping (String?) -> Void) {
        checkChatExists(with: participants) { [weak self] chatId in
            if let chatId = chatId {
                completion(chatId)
            } else {
                let chat = Chat(participants: participants, lastMessage: nil, timestamp: Timestamp())
                do {
                    let documentRef = try self?.db.collection("chats").addDocument(from: chat)
                    completion(documentRef?.documentID)
                } catch {
                    print("Error creating chat: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        }
    }
    
    private func checkChatExists(with participants: [String], completion: @escaping (String?) -> Void) {
        db.collection("chats")
            .whereField("participants", arrayContainsAny: participants)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error checking existing chats: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    let existingChat = querySnapshot?.documents.first { document in
                        let chat = try? document.data(as: Chat.self)
                        return chat?.participants.sorted() == participants.sorted()
                    }
                    completion(existingChat?.documentID)
                }
            }
    }

    func fetchChats(for userId: String) {
        db.collection("chats")
            .whereField("participants", arrayContains: userId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching chats: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else {
                    print("No chats found")
                    return
                }
                self?.chats = documents.compactMap { try? $0.data(as: Chat.self) }
            }
    }
    
    private func updateLastMessage(chatId: String, lastMessage: String) {
        db.collection("chats").document(chatId).updateData([
            "lastMessage": lastMessage,
            "timestamp": Timestamp()
        ]) { error in
            if let error = error {
                print("Error updating last message: \(error.localizedDescription)")
            }
        }
    }
    
    
    
    deinit {
        listener?.remove()
    }
}
