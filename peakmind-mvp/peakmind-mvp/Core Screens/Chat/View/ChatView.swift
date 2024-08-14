//import SwiftUI
//import FirebaseFirestore
//
//class ChatMessage: Identifiable, Hashable {
//    let id = UUID()
//    let sender: String
//    let content: String
//    let timestamp: TimeInterval
//
//    init(sender: String, content: String, timestamp: TimeInterval) {
//        self.sender = sender
//        self.content = content
//        self.timestamp = timestamp
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//
//    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
//        return lhs.id == rhs.id
//    }
//}
//
//struct ChatView: View {
//    @EnvironmentObject var viewModel : AuthViewModel
//    @State private var message = ""
//    @State private var receivedMessages: [ChatMessage] = []
//
//    var body: some View {
//        ZStack {
//            Image("MainBG")
//                .resizable()
//                .edgesIgnoringSafeArea(.all)
//
//            if let user = viewModel.currentUser {
//                VStack {
//                    // Wrap the ScrollView in a VStack and add the onTapGesture to dismiss the keyboard
//                    ScrollView {
//                        ScrollViewReader { scrollViewProxy in
//                            VStack(alignment: .leading, spacing: 10) {
//                                ForEach(receivedMessages, id: \.self) { chatMessage in
//                                    MessageBubble(message: chatMessage.content, sender: chatMessage.sender, timestamp: chatMessage.timestamp)
//                                        .id(chatMessage.id)
//                                }
//                            }
//                            .onAppear {
//                                if let lastMessage = receivedMessages.last {
//                                    scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
//                                }
//                            }
//                            .onChange(of: receivedMessages) { _ in
//                                if let lastMessage = receivedMessages.last {
//                                    scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
//                                }
//                            }
//                        }
//                    }
//                    .padding()
//                    .onTapGesture {
//                        // Dismiss the keyboard when the scroll view is tapped
//                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                    }
//
//                    Spacer()
//                    // Sherpa image positioned at the bottom left, behind the message box
//                    HStack {
//                        Image("Sherpa")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 120, height: 120)
//                            .padding(.leading, 0)
//
//                        Spacer()
//                    }
//                    .padding(.bottom, -60)
//                    HStack {
//                        TextField("Enter your message", text: $message)
//                            .padding(8)
//                            .background(Color(.systemGray5))
//                            .clipShape(RoundedRectangle(cornerRadius: 10))
//
//                        Button(action: sendMessage) {
//                            Text("Send")
//                                .padding(8)
//                                .foregroundColor(.white)
//                                .background(Color.blue)
//                                .clipShape(RoundedRectangle(cornerRadius: 10))
//                        }
//                    }
//                    .padding()
//                }
//                .onAppear {
//                    fetchMessages()
//                }
//            }
//        }
//    }
//    
//    // call the messages from the backend to populate the screen
//    func fetchMessages() {
//        
//        //no login
//        guard let currentUser = viewModel.currentUser else {
//            print("No current user")
//            return
//        }
//        
//        //pull from the messages collection under the user id within the chats directory
//        Firestore.firestore().collection("messages").document(currentUser.id).collection("chats")
//        
//        //might need to convert timestamp, and then order by date, but this seems to work
//            .order(by: "timestamp", descending: false) // Order by timestamp
//            .getDocuments { querySnapshot, error in
//                if let error = error {
//                    print("Error getting documents: \(error)")
//                    return
//                } else {
//                    guard let documents = querySnapshot?.documents else {
//                        print("No documents")
//                        return
//                    }
//                    
//                    //Create ChatMessages
//                    var messages: [ChatMessage] = []
//                    
//                    //run through the documents are create the objects needed
//                    for document in documents {
//                        let data = document.data()
//                        if let sender = data["user"] as? String,
//                           let content = data["message"] as? String,
//                           let time = data["timestamp"] as? Double {
//                            let chatMessage = ChatMessage(sender: sender, content: content, timestamp: time)
//                            messages.append(chatMessage)
//                        }
//                    }
//                    
//                    self.receivedMessages = messages
//                }
//            }
//    }
//
//    //Send the message and refresh the page
//    func sendMessage() {
//        
//        let timestamp = NSDate().timeIntervalSince1970
//        // Create the URL
//        guard let url = URL(string: "http://35.188.88.124/api/chat") else {
//            print("Invalid URL")
//            return
//        }
//        print(url)
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        guard let currentUser = viewModel.currentUser else {
//            print("No current user")
//            return
//        }
//
//        //create object for the message
//        let messageDictionary: [String: Any] = ["message": message, "user": currentUser.id, "timestamp": timestamp]
//
//        //convert to json
//        guard let jsonData = try? JSONSerialization.data(withJSONObject: messageDictionary) else {
//            print("Failed to convert message to JSON")
//            return
//        }
//        print(request)
//        Firestore.firestore().collection("messages").document(currentUser.id).collection("chats").addDocument(data: messageDictionary) { error in
//            if let error = error {
//                print("Error adding document: \(error)")
//            } else {
//                print("Document added successfully")
//                fetchMessages()
//            }
//        }
//        
//        request.httpBody = jsonData
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error:", error.localizedDescription)
//                return
//            }
//
//            guard let data = data else {
//                print("No data received")
//                return
//            }
//
//            
//            do {
//                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                if let responseMessage = jsonResponse?["response"] as? String {
//                    DispatchQueue.main.async {
//                        let timestamp = NSDate().timeIntervalSince1970
//                        let sentMessage = ChatMessage(sender: currentUser.id, content: message, timestamp: timestamp)
//                        self.receivedMessages.append(sentMessage) // Add the sent message to receivedMessages
//                        let messageDictionaryResponse: [String: Any] = ["message": responseMessage, "user": "AI", "timestamp": timestamp]
//                        Firestore.firestore().collection("messages").document(currentUser.id).collection("chats").addDocument(data: messageDictionaryResponse) { error in
//                            if let error = error {
//                                print("Error adding document: \(error)")
//                            } else {
//                                print("Document added successfully")
//                                fetchMessages()
//                            }
//                        }
//                    }
//                }
//            } catch {
//                print("Error parsing JSON:", error.localizedDescription)
//            }
//        }.resume()
//
//        // Clear the message field after sending
//        message = ""
//    }
//
//
//
//
//
//
//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatView()
//    }
//}
//

//-------------------------------------------------Redesign by Zak--------------------------------------------------------------

import SwiftUI
import FirebaseFirestore
import Lottie

class ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let sender: String
    let content: String
    let timestamp: TimeInterval
    var rating: Int?  // Changed rating to an Int to represent star rating
    var feedback: String? // to store feedback
    var isFeedbackVisible: Bool = true  // property to control visibility of feedback button
    var feedbackMessageVisible: Bool = false // property to control visibility of feedback message

    init(sender: String, content: String, timestamp: TimeInterval, rating: Int? = nil, feedback: String? = nil) {
        self.sender = sender
        self.content = content
        self.timestamp = timestamp
        self.rating = rating
        self.feedback = feedback
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ChatView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var message = ""
    @State private var receivedMessages: [ChatMessage] = []

    @State private var showingFeedbackSheet = false
    @State private var feedbackText = ""
    @State private var selectedMessage: ChatMessage? = nil

    @State private var feedbackSubmitted = false  // state to show the feedback completion
    @State private var showingSettings = false  // state to show settings popup
    @State private var isTyping = false  // state to track if the user is typing
    @State private var starRating = 0  // State to hold star rating

    @State private var showCopyPopup = false  // State to control copy popup visibility

    var body: some View {
        NavigationStack {
            ZStack {
                Image("MainBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)

                if let user = viewModel.currentUser {
                    VStack {
                        ScrollView {
                            ScrollViewReader { scrollViewProxy in
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(receivedMessages, id: \.self) { chatMessage in
                                        VStack(alignment: .leading, spacing: 5) {
                                            MessageBubble(message: chatMessage.content, sender: chatMessage.sender, timestamp: chatMessage.timestamp)

                                            // Only show feedback and other options for messages from AI/system
                                            if chatMessage.sender == "AI" {
                                                HStack(spacing: 10) {
                                                    if chatMessage.rating == nil {
                                                        Button(action: {
                                                            selectedMessage = chatMessage
                                                            showingFeedbackSheet = true
                                                        }) {
                                                            LottieView(name: "feedback", loopMode: .loop)
                                                                .frame(width: 30, height: 30)  // adjusted size to make the button bigger
                                                        }

                                                        Button(action: {
                                                            UIPasteboard.general.string = chatMessage.content
                                                            showCopyPopup = true
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                                showCopyPopup = false
                                                            }
                                                        }) {
                                                            Image(systemName: "doc.on.doc")
                                                                .resizable()
                                                                .frame(width: 20, height: 20)
                                                                .foregroundColor(.blue)  // color for the copy button
                                                        }
                                                    } else if chatMessage.feedbackMessageVisible {
                                                        Text("Thanks for the feedback")
                                                            .font(.caption)
                                                            .foregroundColor(.gray)
                                                    } else {
                                                        Text("   Rated: \(chatMessage.rating ?? 0) stars")
                                                            .font(.caption)
                                                            .foregroundColor(.gray)
                                                            .padding(.top, 6)
                                                    }
                                                }
                                                .padding(.top, -1)  // adjust this value to change the vertical spacing
                                            }
                                        }
                                        .id(chatMessage.id)
                                    }
                                }
                                .onAppear {
                                    if let lastMessage = receivedMessages.last {
                                        scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                }
                                .onChange(of: receivedMessages) { _ in
                                    if let lastMessage = receivedMessages.last {
                                        scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                        .padding()
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }

                        Spacer()
                        
                        HStack {
                            if !isTyping {  // show Sherpa only when not typing
                                Image("Sherpa")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                            }
                            Spacer()
                        }
                        .padding(.bottom, -58) // padding to reduce the height gap
                        
                        HStack {
                            TextField("Enter your message", text: $message, onEditingChanged: { isEditing in
                                isTyping = isEditing  // update isTyping state when editing starts or ends
                            })
                            .padding(12)
                            .frame(height: 50)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                            Button(action: {
                                sendMessage()
                                isTyping = true  // keep typing state true after sending
                            }) {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color.mediumBlue)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }

                            Button(action: {
                                showingSettings = true
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color(.mediumBlue))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .padding(.bottom, 10) // reduced padding to bring the elements closer to the chat area
                        .padding(.horizontal)
                    }
                    .onAppear {
                        fetchMessages()
                    }
                    .sheet(isPresented: $showingFeedbackSheet) {
                        feedbackSheetView
                    }
                    .actionSheet(isPresented: $showingSettings) {
                        ActionSheet(
                            title: Text("Settings"),
                            buttons: [
                                .destructive(Text("Clear Chat")) {
                                    clearChat()
                                },
                                .cancel()
                            ]
                        )
                    }
                }
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(
                Group {
                    if showCopyPopup {
                        Text("Copied to Clipboard!")
                            .font(.subheadline)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: showCopyPopup)
                            .padding(.bottom, 50)
                    }
                }
                , alignment: .bottom
            )
        }
    }

    var feedbackSheetView: some View {
        NavigationStack {
            ZStack {
                // snow animation (background)
                CustomLottieView(name: "snow_animation", loopMode: .loop)
                    .ignoresSafeArea()

                if feedbackSubmitted {
                    VStack(spacing: 20) {
                        HStack(spacing: 10) {
                            LottieView(name: "checkmark", loopMode: .playOnce)
                                .frame(width: 60, height: 60)
                        }

                        Button(action: {
                            showingFeedbackSheet = false
                            feedbackSubmitted = false
                        }) {
                            Text("Done")
                                .fontWeight(.semibold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.mediumBlue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        .padding(.top)
                    }
                } else {
                    VStack(spacing: 20) {
                        // header with Icon
                        HStack {
                            Image(systemName: "star.circle")
                                .resizable()
                                .frame(width: 40, height: 35)
                                .foregroundColor(.mediumBlue)
                            Text("We value your feedback!")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.mediumBlue)
                        }
                        .padding(.top)

                        // star rating System
                        HStack {
                            ForEach(1..<6) { star in
                                Image(systemName: starRating >= star ? "star.fill" : "star")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.yellow)
                                    .onTapGesture {
                                        starRating = star
                                    }
                            }
                        }
                        .padding(.vertical)

                        // text editor for additional feedback
                        ZStack(alignment: .bottomTrailing) {
                            TextEditor(text: $feedbackText)
                                .frame(height: 200)
                                .padding(5)
                                .background(Color(.iceBlue))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .onChange(of: feedbackText) { newValue in
                                    if newValue.count > 500 {
                                        feedbackText = String(newValue.prefix(500))
                                    }
                                }
                                .onSubmit {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }

                            Text("\(feedbackText.count)/500")
                                .font(.footnote)
                                .foregroundColor(feedbackText.count > 500 ? .red : .gray)
                                .padding(.trailing, 10)
                                .padding(.bottom, 5)
                        }
                        .padding(.horizontal)

                        Spacer()

                        
                        Button(action: {
                            submitFeedback()
                        }) {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                    .font(.headline)
                                Text("Send Feedback")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color(.iceBlue) : Color(.mediumBlue))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .scaleEffect(1.05)
                            .animation(.easeInOut(duration: 0.2), value: 1.05)
                        }
                        .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || starRating == 0)  // disable button when text editor has no non-whitespace characters or no stars selected
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            }
            .padding()
            .navigationBarTitle("Feedback", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                showingFeedbackSheet = false
            })
        }
    }

    func fetchMessages() {
        guard let currentUser = viewModel.currentUser else {
            print("No current user")
            return
        }
        
        Firestore.firestore().collection("messages").document(currentUser.id).collection("chats")
            .order(by: "timestamp", descending: false)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                } else {
                    guard let documents = querySnapshot?.documents else {
                        print("No documents")
                        return
                    }
                    
                    var messages: [ChatMessage] = []
                    
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
    
    func sendMessage() {
        let timestamp = NSDate().timeIntervalSince1970
        guard let url = URL(string: "http://35.188.88.124/api/chat") else {
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

        let messageDictionary: [String: Any] = ["message": message, "user": currentUser.id, "timestamp": timestamp]

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
                        self.receivedMessages.append(sentMessage)
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

        message = ""
        // do not reset the isTyping flag here to keep the sherpa hidden while typing
    }
    
    func clearChat() {
        receivedMessages.removeAll()
        
        guard let currentUser = viewModel.currentUser else {
            print("No current user")
            return
        }
        
        // clear messages from Firestore
        let chatCollection = Firestore.firestore().collection("messages").document(currentUser.id).collection("chats")
        
        chatCollection.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            for document in snapshot!.documents {
                chatCollection.document(document.documentID).delete { error in
                    if let error = error {
                        print("Error deleting document: \(error)")
                    } else {
                        print("Document successfully deleted")
                    }
                }
            }
        }
    }

    // updated function to submit feedback with star rating
    func submitFeedback() {
        guard let selectedMessage = selectedMessage else { return }

        guard let index = receivedMessages.firstIndex(where: { $0.id == selectedMessage.id }) else { return }

        receivedMessages[index].rating = starRating
        receivedMessages[index].feedback = feedbackText

        guard let currentUser = viewModel.currentUser else {
            print("No current user")
            return
        }

        let feedbackData: [String: Any] = [
            "rating": starRating,
            "user": currentUser.id,
            "messageId": selectedMessage.id.uuidString,
            "feedback": feedbackText,
            "timestamp": NSDate().timeIntervalSince1970
        ]

        Firestore.firestore().collection("ratings").document(currentUser.id).collection("feedback").document(selectedMessage.id.uuidString).setData(feedbackData) { error in
            if let error = error {
                print("Error submitting feedback: \(error)")
            } else {
                print("Feedback submitted successfully")
                feedbackSubmitted = true
            }
        }

        feedbackText = ""
        starRating = 0  // reset star rating
        self.selectedMessage = nil
    }
}

struct LottieView: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode = .loop

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)

        let animationView = LottieAnimationView(name: name)
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = loopMode
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        let authViewModel = AuthViewModel()
        ChatView()
            .environmentObject(authViewModel)
    }
}


