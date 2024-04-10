//
//  SherpaContinue.swift
//  peakmind-mvp
//
//  Created by Katharina Reimer on 4/7/24.
//

import SwiftUI

struct SherpaContinue<nextView: View>: View {
    var nextScreen: nextView
    
    var body: some View {
        HStack {
            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
            
            NavigationLink{
                nextScreen
            } label: {
                Text("Tap to continue")
                    .foregroundStyle(.white)
                    .padding()
                    .background(.blue)
                    .cornerRadius(10)
                    .frame(height: 250)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
        }
    }
}
