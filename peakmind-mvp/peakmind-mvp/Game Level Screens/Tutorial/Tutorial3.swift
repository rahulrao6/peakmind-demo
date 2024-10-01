//
//  Tutorial2.swift
//  peakmind-mvp
//
//  Created by James Wilson on 9/8/24.
//

import SwiftUI

struct Tutorial3: View {
    var closeAction: (String) -> Void

    
    var body: some View {
        ZStack {
            TestView()
            VStack {
                Spacer()
                Text("Tap here to Continue")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.black)
                    .onTapGesture {
                        closeAction("")
                    }
                Text("This is the mental health game. Learn about different mental health struggles and how to cope interactively!")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.gray)
                    .padding(50)
                
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.white)
                            .opacity(0.8)
                    )
                    .frame(height: 300)
                    .frame(maxWidth: 300)
                    .padding(.bottom, 50)
                
            }
        }
    }
}
