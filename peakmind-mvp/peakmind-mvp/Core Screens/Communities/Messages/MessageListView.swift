import SwiftUI

struct MessageListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var messagesViewModel = MessagesViewModel()
    @State private var selectedUserId: String = ""
    @State private var friends: [UserData] = []

    var body: some View {
        ZStack {
            Color("SentMessage").edgesIgnoringSafeArea(.all) // Set the background color
            
            VStack {
                Text("Your Messages")
                    .font(.system(size: 25, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(friends) { friend in
                            NavigationLink(destination: MessageView(chatId: getChatId(with: friend.id), userName: friend.username, userProfileImage: friend.selectedAvatar).environmentObject(authViewModel).environmentObject(messagesViewModel)) {
                                HStack {
                                    Image("RajIcon")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(Color("Medium Blue"))
                                    Text(friend.username)
                                        .font(.system(size: 15, weight: .semibold, design: .default))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading) // Make the username boxes the same width
                                }
                                .padding()
                                .background(Color("Ice Blue"))
                                .cornerRadius(10)
                            }
                            .frame(maxWidth: .infinity) // Ensure the entire row has the same width
                        }
                    }
                    .padding(.horizontal)
                }

                HStack {
                    TextField("Enter user ID to chat with", text: $selectedUserId)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 10)
                        .frame(height: 48) // Set the height for alignment

                    Button(action: {
                        guard let userId = authViewModel.currentUser?.id else { return }
                        messagesViewModel.createChat(with: [userId, selectedUserId]) { chatId in
                            // Handle chat creation if needed
                        }
                    }) {
                        Text("Create Chat")
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .frame(height: 40) // Set the height for alignment
                            .background(Color("Medium Blue"))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 10) // Ensure equal padding on left and right
                .padding(.bottom, 15)

                .frame(maxWidth: .infinity, alignment: .center) // Center align the HStack

            }
            .background(Color.clear)
            .onAppear {
                guard let userId = authViewModel.currentUser?.id else { return }
                authViewModel.fetchFriends { friends in
                    self.friends = friends
                }
                messagesViewModel.fetchChats(for: userId)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
    }

    func getChatId(with friendId: String) -> String {
        if let existingChat = messagesViewModel.chats.first(where: { $0.participants.contains(friendId) }) {
            return existingChat.id ?? ""
        } else {
            var chatId: String = ""
            messagesViewModel.createChat(with: [authViewModel.currentUser?.id ?? "", friendId]) { createdChatId in
                chatId = createdChatId ?? ""
            }
            return chatId
        }
    }
}

struct MessageListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MessageListView()
                .environmentObject(AuthViewModel())
        }
    }
}
