//
//  ChatView.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 6/21/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct MessageView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var messagesViewModel : MessagesViewModel
    var chatId: String
    
    @State private var messageText = ""

    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(messagesViewModel.messages) { message in
                        HStack {
                            if message.userId == authViewModel.currentUser?.id {
                                Spacer()
                                Text(message.content)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            } else {
                                Text(message.content)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.black)
                                    .cornerRadius(10)
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            HStack {
                TextField("Enter message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 30)
                
                Button(action: {
                    guard let userId = authViewModel.currentUser?.id else { return }
                    let message = Message(userId: userId, content: messageText, timestamp: Timestamp())
                    messagesViewModel.sendMessage(chatId: chatId, message: message)
                    messageText = ""
                }) {
                    Text("Send")
                        .bold()
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationBarTitle("Chat", displayMode: .inline)
        .onAppear {
            messagesViewModel.fetchMessages(chatId: chatId)
        }
    }
}
