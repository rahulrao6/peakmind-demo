import SwiftUI

struct MessageListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var messagesViewModel = MessagesViewModel()
    @State private var selectedUserId: String = ""
    @State private var friends: [UserData] = []
    
    var body: some View {
        VStack {
            List(friends) { friend in
                NavigationLink(destination: MessageView(chatId: getChatId(with: friend.id)).environmentObject(authViewModel).environmentObject(messagesViewModel)) {
                    Text(friend.username)
                }
            }
            
            HStack {
                TextField("Enter user ID to chat with", text: $selectedUserId)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    guard let userId = authViewModel.currentUser?.id else { return }
                    messagesViewModel.createChat(with: [userId, selectedUserId])
                }) {
                    Text("Create Chat")
                }
            }
            .padding()
        }
        .onAppear {
            guard let userId = authViewModel.currentUser?.id else { return }
            authViewModel.fetchFriends { friends in
                self.friends = friends
            }
            messagesViewModel.fetchChats(for: userId)
        }
    }
    
    func getChatId(with friendId: String) -> String {
        if let existingChat = messagesViewModel.chats.first(where: { $0.participants.contains(friendId) }) {
            return existingChat.id ?? ""
        } else {
            messagesViewModel.createChat(with: [authViewModel.currentUser?.id ?? "", friendId])
            return messagesViewModel.chats.first(where: { $0.participants.contains(friendId) })?.id ?? ""
        }
    }
}

struct MessageListView_Previews: PreviewProvider {
    static var previews: some View {
        MessageListView()
            .environmentObject(AuthViewModel())
    }
}
