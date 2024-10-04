//
//  Tutorial2.swift
//  peakmind-mvp
//
//  Created by James Wilson on 9/8/24.
//

import SwiftUI

struct Tutorial3: View {
    var closeAction: (String) -> Void
    var viewModel: AuthViewModel = AuthViewModel()

    
    var body: some View {
        ZStack {
            OnboardingView(authViewModel: viewModel)
            VStack {
                Spacer()

                Text("Tap to Continue")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.white)
                    
                Text("This is Flow Mode! Come here whenever you need to focus on a task and don’t want to get distracted!")
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
