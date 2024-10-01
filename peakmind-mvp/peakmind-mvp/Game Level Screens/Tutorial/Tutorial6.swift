//
//  Tutorial2.swift
//  peakmind-mvp
//
//  Created by James Wilson on 9/8/24.
//

import SwiftUI

struct Tutorial6: View {
    var closeAction: (String) -> Void
    
    
    var body: some View {
        ZStack {
            
            VStack {
                Text("This is where you can find your rewards. All tasks in PeakMind get you closer to your next reward.")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
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
