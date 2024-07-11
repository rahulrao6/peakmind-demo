import Foundation
import SwiftUI
import FirebaseFirestore

struct MessageView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var messagesViewModel: MessagesViewModel
    var chatId: String
    
    @State private var messageText = ""
    
    var body: some View {
        ZStack {
            Image("MainBG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                VStack {
                    HStack {
                        Image("RajIcon")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        
                        Text("RajDaGoat")
                            .font(.system(size: 22, weight: .bold, design: .default))
                        
                        Spacer()
                    }
                    .padding(.top, 70)
                    .padding(.horizontal, 25)
                }
                .frame(maxWidth: .infinity, minHeight: 130) // Adjust the height as needed
                .background(LinearGradient(gradient: Gradient(colors: [.white, Color("Ice Blue")]), startPoint: .top, endPoint: .bottom))
                .edgesIgnoringSafeArea(.top) // Extend the VStack to the very top
                
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(messagesViewModel.messages) { message in
                            HStack {
                                if message.userId == authViewModel.currentUser?.id {
                                    Spacer()
                                    Text(message.content)
                                        .padding()
                                        .background(Color("SentMessage"))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                } else {
                                    Text(message.content)
                                        .padding()
                                        .background(Color.white.opacity(0.8))
                                        .foregroundColor(.black)
                                        .cornerRadius(10)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top, -65) // Reduce padding between scroll view and footer
                
                ZStack {
                    Rectangle()
                        .foregroundColor(Color("SentMessage"))
                        .frame(maxWidth: .infinity, maxHeight: 80)
                        .edgesIgnoringSafeArea(.bottom)
                    
                    HStack {
                        TextField("Enter message...", text: $messageText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(minHeight: 45)
                        
                        Button(action: {
                            guard let userId = authViewModel.currentUser?.id else { return }
                            let message = Message(userId: userId, content: messageText, timestamp: Timestamp())
                            messagesViewModel.sendMessage(chatId: chatId, message: message)
                            messageText = ""
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40) // Set the height and width for alignment
                                .foregroundColor(Color("Ice Blue"))
                        }
                        .padding(.horizontal, 10)
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity) // Make sure the ZStack takes full width
            }
            .onAppear {
                messagesViewModel.fetchMessages(chatId: chatId)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(chatId: "sampleChatId")
            .environmentObject(AuthViewModel())
            .environmentObject(MessagesViewModel())
    }
}
