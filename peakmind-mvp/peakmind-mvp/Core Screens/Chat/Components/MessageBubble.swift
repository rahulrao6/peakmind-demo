//
//  MessageBubble.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 2/26/24.
//

import SwiftUI

struct MessageBubble: View {
    let message: String
    let sender: String
    let timestamp: Double
    var isAISender: Bool {
        return sender == "Sherpa" || sender == "AI"
    }

    
    func timeAgo() -> String {
        let date = Date(timeIntervalSince1970: timestamp/1000)
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    var body: some View {
        HStack {
            if !isAISender {
                Spacer()
                
                HStack {
                    //Text(timeAgo())
                        //.padding(3)
                        //.foregroundColor(.white)
                        //.font(.footnote)
                        //.padding(.trailing, -4)
                        //.font(.system(size: 10))
                        //.italic()
                }
                    //.clipShape(ChatBubbleShape(isFromCurrentUser: true))
                    //.padding(2)
                Text(message)
                    .padding(10)
                    .background(Color("SentMessage"))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))

                    //.clipShape(ChatBubbleShape(isFromCurrentUser: false))
                    .padding(5)
            } else {
                HStack {
                    Text(message)
                        .padding(10)
                        .background(Color("ReceivedMessage"))
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 15))

                        //.clipShape(ChatBubbleShape(isFromCurrentUser: true))
                        .padding(5)
                    
                    Text(timeAgo())
                        //.padding(3)
                        .foregroundColor(.white)
                    //.font(.footnote)
                        .padding(.leading, -4)
                        .italic()
                        .font(.system(size: 10))
                        //.clipShape(ChatBubbleShape(isFromCurrentUser: true))
                        //.padding(2)
                    
                    
                }
                Spacer()
            }
        }
    }
}

#Preview {
    MessageBubble(message: "hi", sender: "ewf", timestamp: 22.1)
}
