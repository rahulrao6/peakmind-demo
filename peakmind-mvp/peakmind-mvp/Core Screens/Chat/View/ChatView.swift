import SwiftUI
import FirebaseFirestore
import Lottie

class ConversationState: ObservableObject {
    @Published var sessionId: String?
    @Published var isConversationActive: Bool = false
    @Published var receivedMessages: [ChatMessage] = []
}

class ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let sender: String
    let content: String
    let timestamp: TimeInterval
    var rating: Int?  // Changed rating to an Int to represent star rating
    var feedback: String? // to store feedback
    var isFeedbackVisible: Bool = true  // property to control visibility of feedback button
    var feedbackMessageVisible: Bool = false // property to control visibility of feedback message
    
    var isFromUser: Bool {
        return sender == "Patient"
    }

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

    @State private var sessionId: String?
    @State private var isConversationActive = false
    @State private var showingFeedbackSheet = false
    @State private var feedbackText = ""
    @State private var selectedMessage: ChatMessage? = nil

    @State private var feedbackSubmitted = false  // state to show the feedback completion
    @State private var showingSettings = false  // state to show settings popup
    @State private var isTyping = false  // state to track if the user is typing
    @State private var starRating = 0  // State to hold star rating

    @State private var showCopyPopup = false  // State to control copy popup visibility
    @State private var conversationHistory: [ConversationPreview] = []
    @State private var showConversationHistory = false  // Toggle conversation history

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView()

                if let user = viewModel.currentUser {
                    VStack {
                        messagesScrollView()

                        Spacer()

                        typingIndicatorAndControls()
                    }
                    .onAppear {
                        startConversation()
                        if let sessionId = self.sessionId {
                            fetchMessages()
                        }
                    }
                    .sheet(isPresented: $showingFeedbackSheet) {
                        FeedbackSheetView(selectedMessage: selectedMessage, receivedMessages: receivedMessages).environmentObject(viewModel)
                    }
                    .actionSheet(isPresented: $showingSettings) {
                        settingsActionSheet()
                    }
                }

                overlayViews()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // Helper function for background image view
    @ViewBuilder
    private func backgroundView() -> some View {
        Image("MainBG")
            .resizable()
            .edgesIgnoringSafeArea(.all)
    }

    // Helper function for messages scroll view
    @ViewBuilder
    private func messagesScrollView() -> some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(receivedMessages, id: \.self) { chatMessage in
                        VStack(alignment: .leading, spacing: 5) {
                            MessageBubble(message: chatMessage.content, sender: chatMessage.sender, timestamp: chatMessage.timestamp)

                            // Only show feedback and other options for messages from AI/system
                            if !chatMessage.isFromUser {
                                feedbackButtons(for: chatMessage)
                            }
                        }
                        .id(chatMessage.id)
                    }
                }
                .onAppear {
                    scrollToLastMessage(scrollViewProxy)
                }
                .onChange(of: receivedMessages) { _ in
                    scrollToLastMessage(scrollViewProxy)
                }
            }
        }
        .padding()
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    // Helper function to scroll to the last message
    private func scrollToLastMessage(_ scrollViewProxy: ScrollViewProxy) {
        if let lastMessage = receivedMessages.last {
            scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }

    // Helper function for typing indicator and controls
    @ViewBuilder
    private func typingIndicatorAndControls() -> some View {
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
                if isConversationActive {
                    continueConversation()
                } else {
                    startConversation()
                }
                isTyping = true
            }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.mediumBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
            }
            .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)  // Disable button if message is empty or whitespace


            Button(action: {
                showingSettings = true
            }) {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color(.mediumBlue))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            Button(action: {
                fetchConversationHistory()
                showConversationHistory.toggle()  // Toggle conversation history
            }) {
                Image(systemName: "clock.fill")
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color(.mediumBlue))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.bottom, 10) // reduced padding to bring the elements closer to the chat area
        .padding(.horizontal)
    }

    // Helper function for feedback buttons
    @ViewBuilder
    private func feedbackButtons(for chatMessage: ChatMessage) -> some View {
        HStack(spacing: 10) {
            if chatMessage.rating == nil {
                Button(action: {
                    selectedMessage = chatMessage
                    showingFeedbackSheet = true
                }) {

                    //LottieView(name: "feedback", loopMode: .loop)
                    Image(systemName: "text.bubble")
                        .frame(width: 20, height: 20)  // adjusted size to make the button bigger

                }

//                Button(action: {
//                    UIPasteboard.general.string = chatMessage.content
//                    showCopyPopup = true
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                        showCopyPopup = false
//                    }
//                }) {
//                    Image(systemName: "doc.on.doc")
//                        .resizable()
//                        .frame(width: 20, height: 20)
//                        .foregroundColor(.blue)  // color for the copy button
//                }
                
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
        .padding(.top, -1)
    }

    // Helper function for settings action sheet
    private func settingsActionSheet() -> ActionSheet {
        ActionSheet(
            title: Text("Settings"),
            buttons: [
                .destructive(Text("End Conversation")) {
                    endConversation()
                },
                .cancel()
            ]
        )
    }

    // Helper function for overlay views (conversation history and copy popup)
    @ViewBuilder
    private func overlayViews() -> some View {
        Group {
            if showConversationHistory {
                conversationHistoryView()
            }
            if showCopyPopup {
                copyPopupView()
            }
        }
    }

    @ViewBuilder
    private func conversationHistoryView() -> some View {
        ZStack {
            // Background image for cohesive look
            Image("PurpleNewBG")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 20) {
                // Header with title, clear, and close buttons
                HStack {
                    Image(systemName: "clock.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color("PurpleButtonGradientColor1"))
                    Text("Previous Conversations")
                        .font(.custom("SFProText-Bold", size: 18))
                        .foregroundColor(Color("PurpleButtonGradientColor2"))
                    Spacer()
                    
                    // Clear button
                    Button(action: clearConversationHistory) {
                        Text("Clear All")
                            .font(.caption)
                            .foregroundColor(Color.red)
                    }
                    
                    // Close button
                    Button(action: {
                        showConversationHistory = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // List of conversation previews
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(conversationHistory.prefix(20), id: \.session_id) { conversation in
                            Button(action: {
                                loadConversation(sessionId: conversation.session_id)
                                showConversationHistory = false
                            }) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(conversation.preview)
                                        .font(.custom("SFProText-Medium", size: 16))
                                        .foregroundColor(Color("TextInsideBoxColor"))
                                        .lineLimit(1)
                                    Text(formatDate(timestamp: conversation.timestamp))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color("PurpleBoxGradientColor1"), Color("PurpleBoxGradientColor2")]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    .cornerRadius(12)
                                    .shadow(color: Color("PurpleButtonGradientColor2").opacity(0.3), radius: 5, x: 0, y: 2)
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(15)
            .padding()
        }
    }

    // Function to clear conversation history from local storage and Firestore
    private func clearConversationHistory() {
        // Clear local conversation history
        conversationHistory.removeAll()

        // Clear from Firestore
        guard let currentUser = viewModel.currentUser else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("chatbot_").document(currentUser.id)
        let sessionsRef = userRef.collection("sessions")
        
        sessionsRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error retrieving documents for deletion: \(error)")
                return
            }
            
            for document in querySnapshot!.documents {
                document.reference.delete { error in
                    if let error = error {
                        print("Error deleting document: \(error)")
                    }
                }
            }
        }
    }


    // Helper function for the copy popup view
    @ViewBuilder
    private func copyPopupView() -> some View {
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
    
    func formatDate(timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp/1000)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    func fetchConversationHistory() {
           guard let currentUser = viewModel.currentUser else {
               print("No current user")
               return
           }

           let db = Firestore.firestore()
           let userRef = db.collection("chatbot_").document(currentUser.id)
           let sessionsRef = userRef.collection("sessions")

           sessionsRef.getDocuments { (querySnapshot, error) in
               if let error = error {
                   print("Error getting documents: \(error)")
               } else {
                   var history: [ConversationPreview] = []
                   for document in querySnapshot!.documents {
                       let data = document.data()
                       if let messages = data["messages"] as? [[String: Any]],
                          let lastMessage = messages.last,
                          let timestamp = lastMessage["timestamp"] as? Double,
                          let content = lastMessage["content"] as? String {
                           let preview = ConversationPreview(
                               session_id: document.documentID,
                               timestamp: timestamp,
                               preview: String(content.prefix(50))
                           )
                           history.append(preview)
                       }
                   }
                   DispatchQueue.main.async {
                       self.conversationHistory = history.sorted(by: { $0.timestamp > $1.timestamp })
                       if self.sessionId == nil, let firstSession = self.conversationHistory.first {
                           self.loadConversation(sessionId: firstSession.session_id)
                       }
                   }
               }
           }
       }

    func loadConversation(sessionId: String) {
        self.sessionId = sessionId
        self.isConversationActive = true
        fetchMessages()
    }


    
    func fetchMessages() {
        guard let currentUser = viewModel.currentUser else {
            print("No current user")
            return
        }
        
        guard let sessionId = self.sessionId else {
            print("No active session")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("chatbot_").document(currentUser.id)
        let sessionRef = userRef.collection("sessions").document(sessionId)
        
        sessionRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting session document: \(error)")
                return
            }
            
            guard let document = document, document.exists else {
                print("Session document does not exist")
                return
            }
            
            if let sessionData = document.data(),
               let messages = sessionData["messages"] as? [[String: Any]] {
                self.receivedMessages = messages.compactMap { messageData in
                    guard let sender = messageData["sender"] as? String,
                          let content = messageData["content"] as? String,
                          let timestamp = messageData["timestamp"] as? TimeInterval else {
                        return nil
                    }
                    return ChatMessage(sender: sender, content: content, timestamp: timestamp)
                }
            }
        }
    }
    
    func startConversation() {
        guard let currentUser = viewModel.currentUser else {
            print("No current user")
            return
        }

        let url = URL(string: "http://104.198.240.182:8080/start_conversation")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["user_id": currentUser.id]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error starting conversation: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            // Print received data for debugging
            if let dataString = String(data: data, encoding: .utf8) {
                print("Received data: \(dataString)")
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Parsed JSON: \(json)")
                    if let message = json["message"] as? String,
                       let sessionId = json["session_id"] as? String {
                        DispatchQueue.main.async {
                            self.sessionId = sessionId
                            self.isConversationActive = true
                            self.fetchMessages()
                        }
                    } else {
                        print("Required fields 'message' or 'session_id' not found in JSON")
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                // Try to parse the response as a plain string
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response as string: \(responseString)")
                }
            }
        }.resume()
    }

    func continueConversation() {
        let currentTime = Date().timeIntervalSince1970
        let newMessage = ChatMessage(sender: "Patient", content: message, timestamp: currentTime)
        receivedMessages.append(newMessage)

        // Log the current timestamp
        print("Timestamp when sending: \(currentTime)")
        
        guard let currentUser = viewModel.currentUser, let sessionId = self.sessionId else {
            print("No current user or session ID")
            return
        }

        let url = URL(string: "http://104.198.240.182:8080/continue_conversation")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "user_id": currentUser.id,
            "session_id": sessionId,
            "message": message
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error continuing conversation: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            // Print received data for debugging
            if let dataString = String(data: data, encoding: .utf8) {
                print("Received data: \(dataString)")
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Parsed JSON: \(json)")
                    if let response = json["response"] as? String {
                        DispatchQueue.main.async {
                            //receivedMessages.append(ChatMessage(sender: "Patient", content: message, timestamp: NSDate().timeIntervalSince1970))
                            self.message = ""
                            self.fetchMessages()
                        }
                    } else {
                        print("Required field 'response' not found in JSON")
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                // Try to parse the response as a plain string
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response as string: \(responseString)")
                }
            }
        }.resume()
    }


        func endConversation() {
            guard let currentUser = viewModel.currentUser, let sessionId = self.sessionId else {
                print("No current user or session ID")
                return
            }

            let url = URL(string: "http://104.198.240.182:8080/end_conversation")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: [String: Any] = [
                "user_id": currentUser.id,
                "session_id": sessionId
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error ending conversation: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("No data received")
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // Safely unwrap the "message" key and cast to String
                        if let message = json["message"] as? String {
                            DispatchQueue.main.async {
                                // Use the 'message' string as needed
                                print("Received message: \(message)")
                            }
                        } else {
                            print("Message key not found or not a String")
                        }
                    } else {
                        print("Failed to cast JSON as [String: Any]")
                    }
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                }

            }.resume()
        }
    
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

struct ConversationPreview: Identifiable {
    let id = UUID()
    let session_id: String
    let timestamp: Double
    let preview: String
}

struct FeedbackSheetView: View {
    @State private var feedbackText: String = ""
    @State private var starRating: Int = 0
    @State private var feedbackSubmitted: Bool = false
    @State private var showingFeedbackSheet: Bool = false
    @FocusState private var isFeedbackTextFocused: Bool
    @State private var isTyping: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    @EnvironmentObject var viewModel: AuthViewModel
    let selectedMessage: ChatMessage?
    let receivedMessages: [ChatMessage]

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Set the background to fully cover with PurpleNewBG
                    Image("PurpleNewBG")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        Spacer()
                            .frame(height: (isTyping || isFeedbackTextFocused) ? 100 : 10)
                        
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
                                Text("We value your feedback!")
                                    .font(.custom("SFProText-Heavy", size: 25)) // Adjust size as needed
                                    .foregroundColor(.white)
                                    .padding(.top)
                                
                                // Star rating system
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
                                
                                // Text editor for additional feedback
                                ZStack(alignment: .topLeading) {
                                    if feedbackText.isEmpty {
                                        Text("Start typing here...")
                                            .foregroundColor(Color.gray.opacity(0.5))
                                            .padding(.vertical, 14)
                                            .padding(.horizontal, 16)
                                            .zIndex(1)
                                    }
                                    
                                    TextEditor(text: $feedbackText)
                                        .font(.custom("SFProText-Bold", size: 16))
                                        .foregroundColor(Color("TextInsideBoxColor"))
                                        .focused($isFeedbackTextFocused)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .frame(height: 200, alignment: .topLeading)
                                        .background(Color.clear)
                                        .scrollContentBackground(.hidden)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color("PurpleBoxGradientColor1"), Color("PurpleBoxGradientColor2")]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                            .cornerRadius(10)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color("PurpleBorderColor"), lineWidth: 3.5)
                                        )
                                        .onChange(of: feedbackText) { newValue in
                                            withAnimation {
                                                isTyping = !feedbackText.isEmpty
                                            }
                                            if newValue.count > 500 {
                                                feedbackText = String(newValue.prefix(500))
                                            }
                                        }
                                        .onSubmit {
                                            isFeedbackTextFocused = false
                                        }
                                    
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            Text("\(feedbackText.count)/500")
                                                .font(.custom("SFProText-Bold", size: 12))
                                                .foregroundColor(Color("TextInsideBoxColor"))
                                                .padding(8)
                                                .background(Color.black.opacity(0.2))
                                                .cornerRadius(8)
                                                .padding(8)
                                        }
                                    }
                                }
                                .frame(height: 200)
                                .padding(.horizontal)
                                
                                Spacer()
                                    .frame(height: (isTyping || isFeedbackTextFocused) ? (keyboardHeight - geometry.safeAreaInsets.bottom) / 2 : 20)
                                
                                // Submit button
                                Button(action: {
                                    isFeedbackTextFocused = false
                                    submitFeedback()
                                }) {
                                    Text("Submit")
                                        .font(.custom("SFProText-Bold", size: 20))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color("PurpleButtonGradientColor1"), Color("PurpleButtonGradientColor2")]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .cornerRadius(15)
                                        .shadow(color: feedbackText.isEmpty ? Color.clear : Color.white.opacity(1), radius: 10, x: 0, y: 0)
                                }
                                .padding(.bottom, 50)
                                .disabled(feedbackText.isEmpty)
                                .opacity(feedbackText.isEmpty ? 0.6 : 1.0)
                            }
                            .padding(.horizontal)
                            .onTapGesture {
                                isFeedbackTextFocused = false
                            }
                            .onAppear {
                                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                                        withAnimation {
                                            keyboardHeight = keyboardFrame.height
                                            isTyping = true
                                        }
                                    }
                                }
                                
                                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                                    withAnimation {
                                        isTyping = false
                                        keyboardHeight = 0
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .navigationBarTitle("", displayMode: .inline)
                    .navigationBarItems(leading: Button("Cancel") {
                        showingFeedbackSheet = false
                    })
                }
            }
        }
    }
    
    // Updated function to submit feedback with star rating
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
        starRating = 0
    }
}


