//
//  Tutorial1.swift
//  peakmind-mvp
//
//  Created by James Wilson on 9/8/24.
//

import SwiftUI

struct Tutorial1: View {
    var closeAction: () -> Void
    
    var body: some View {
        ZStack {
            ChatView()
            VStack {
                Text("This is your AI sherpa companion, get immediate support whenever you need.")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(50)

                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.white)
                            .opacity(0.3)
                    )
                    .frame(height: 300)
                    .frame(maxWidth: 300)
                Text("Tap here to Continue")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.white)
                    
                Spacer()
            }
        }.onTapGesture {
            closeAction()
        }
    }
}

#Preview {
    Tutorial1(closeAction: {})
}
