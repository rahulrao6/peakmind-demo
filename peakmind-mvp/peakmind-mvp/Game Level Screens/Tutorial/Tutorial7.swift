//
//  Tutorial2.swift
//  peakmind-mvp
//
//  Created by James Wilson on 9/8/24.
//

import SwiftUI

struct Tutorial7: View {
    var closeAction: (String) -> Void
    
    var body: some View {
        ZStack {
            //CheckIn()
            VStack {
                Text("This is a daily check-in. Do this every day to track your progress and earn rewards.")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.gray)
                    .padding(50)
                
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.white)
                            .opacity(0.9)
                    )
                    .frame(height: 300)
                    .frame(maxWidth: 300)
                Text("Tap here to Continue")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.black)
                    .onTapGesture {
                        closeAction("")
                    }
                Spacer()
            }
        }
    }
}
