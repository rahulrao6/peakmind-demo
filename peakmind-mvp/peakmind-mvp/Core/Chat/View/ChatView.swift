import SwiftUI
import FirebaseFirestore

class ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let sender: String
    let content: String
    let timestamp: TimeInterval

    init(sender: String, content: String, timestamp: TimeInterval) {
        self.sender = sender
        self.content = content
        self.timestamp = timestamp
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ChatView: View {
    @EnvironmentObject var viewModel : AuthViewModel
    @State private var message = ""
    @State private var receivedMessages: [ChatMessage] = []

    var body: some View {
        ZStack {
            Image("ChatBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)

            if let user = viewModel.currentUser {
                VStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(receivedMessages, id: \.self) { chatMessage in
                                MessageBubble(message: chatMessage.content, sender: chatMessage.sender, timestamp: chatMessage.timestamp)
                            }
                        }
                    }
                    .padding()

                    Spacer()
                    // Sherpa image positioned at the bottom left, behind the message box
                    HStack {
                        Image("Sherpa")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .padding(.leading, 0)

                        Spacer()
                    }
                    .padding(.bottom, -60)
                    HStack {
                        TextField("Enter your message", text: $message)
                            .padding(8)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        Button(action: sendMessage) {
                            Text("Send")
                                .padding(8)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding()
                }
                .onAppear {
                    fetchMessages()
                }
            }
        }
    }
    
    // call the messages from the backend to populate the screen
    func fetchMessages() {
        
        //no login
        guard let currentUser = viewModel.currentUser else {
            print("No current user")
            return
        }
        
        //pull from the messages collection under the user id within the chats directory
        Firestore.firestore().collection("messages").document(currentUser.id).collection("chats")
        
        //might need to convert timestamp, and then order by date, but this seems to work
            .order(by: "timestamp", descending: false) // Order by timestamp
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                } else {
                    guard let documents = querySnapshot?.documents else {
                        print("No documents")
                        return
                    }
                    
                    //Create ChatMessages
                    var messages: [ChatMessage] = []
                    
                    //run through the documents are create the objects needed
                    for document in documents {
                        let data = document.data()
                        if let sender = data["user"] as? String,
                           let content = data["message"] as? String,
                           let time = data["timestamp"] as? Double {
                            let chatMessage = ChatMessage(sender: sender, content: content, timestamp: time)
                            messages.append(chatMessage)
                        }
                    }
                    
                    self.receivedMessages = messages
                }
            }
    }

    //Send the message and refresh the page
    func sendMessage() {
        
        let timestamp = NSDate().timeIntervalSince1970
        // Create the URL
        guard let url = URL(string: "http://localhost:3000/api/chat") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let currentUser = viewModel.currentUser else {
            print("No current user")
            return
        }

        //create object for the message
        let messageDictionary: [String: Any] = ["message": message, "user": currentUser.id, "timestamp": timestamp]

        //convert to json
        guard let jsonData = try? JSONSerialization.data(withJSONObject: messageDictionary) else {
            print("Failed to convert message to JSON")
            return
        }
        Firestore.firestore().collection("messages").document(currentUser.id).collection("chats").addDocument(data: messageDictionary) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
                fetchMessages()
            }
        }
        
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error:", error.localizedDescription)
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let responseMessage = jsonResponse?["response"] as? String {
                    DispatchQueue.main.async {
                        let timestamp = NSDate().timeIntervalSince1970
                        let sentMessage = ChatMessage(sender: currentUser.id, content: message, timestamp: timestamp)
                        self.receivedMessages.append(sentMessage) // Add the sent message to receivedMessages
                        let messageDictionaryResponse: [String: Any] = ["message": responseMessage, "user": "AI", "timestamp": timestamp]
                        Firestore.firestore().collection("messages").document(currentUser.id).collection("chats").addDocument(data: messageDictionaryResponse) { error in
                            if let error = error {
                                print("Error adding document: \(error)")
                            } else {
                                print("Document added successfully")
                                fetchMessages()
                            }
                        }
                    }
                }
            } catch {
                print("Error parsing JSON:", error.localizedDescription)
            }
        }.resume()

        // Clear the message field after sending
        message = ""
    }


}



struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}

