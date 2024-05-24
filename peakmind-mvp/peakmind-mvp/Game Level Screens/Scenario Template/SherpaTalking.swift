//
//  SherpaAlone.swift
//  peakmind-mvp
//
//  Created by Katharina Reimer on 4/10/24.
//

import SwiftUI

struct SherpaTalking: View {
    @State var speech: String
    var closeAction: () -> Void
    @State var showBack: Bool

    var body: some View {
        
        HStack {
            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
            VStack{
                Button {
                    //closeAction()
                } label: {
                    SpeechBubble(text: $speech, width: 200.0)
                        .offset(CGSize(width: 50, height: 200))
                }
                if showBack {
                    Button {
                        closeAction()
                    } label: {
                        Spacer()
                        HStack{
                            Text("Back to map")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .lineLimit(7)
                                .padding()
                                .frame(width: 150, alignment: .topLeading)
                                .background(Color("Dark Blue"))
                                .cornerRadius(10)
                        }
                    }
                }

            }
        }
    }
}
