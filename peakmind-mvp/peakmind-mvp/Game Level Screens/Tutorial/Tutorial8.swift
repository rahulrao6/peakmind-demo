//
//  Tutorial2.swift
//  peakmind-mvp
//
//  Created by James Wilson on 9/8/24.
//

import SwiftUI

struct Tutorial8: View {
    var closeAction: (String) -> Void

    
    var body: some View {
        ZStack {
            PersonalizedPlanNew()
            VStack {
                Spacer()

                Text("Tap to Continue")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.white)
                    
                Text("This is your personalized plan, giving you tailored steps to move in the right direction.")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(50)
                
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.white)
                            .opacity(0.3)
                    )
                    .frame(height: 300)
                    .frame(maxWidth: 300)
            
            }
        }.onTapGesture {
            closeAction("")
        }
    }
}
