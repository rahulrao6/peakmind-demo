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

    var body: some View {
        HStack {
            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
            
            SpeechBubble(text: $speech, width: 200.0)
                .offset(CGSize(width: 50, height: 200))
        }
    }
}

//#Preview {
//    SherpaTalking(speech: "blah blah blah")
//}
