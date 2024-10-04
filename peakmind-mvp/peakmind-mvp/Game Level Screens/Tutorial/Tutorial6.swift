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
            JournalView()
            VStack {
                Text("This is your journal, come here to spark your creativity.")
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
