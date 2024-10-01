//
//  Tutorial2.swift
//  peakmind-mvp
//
//  Created by James Wilson on 9/8/24.
//

import SwiftUI

struct Tutorial4: View {
    var closeAction: (String) -> Void

    
    var body: some View {
        ZStack {
            
            VStack {
                Text("This is your routine builder - come here to build better habits.")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(50)
                
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.black)
                            .opacity(0.3)
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
