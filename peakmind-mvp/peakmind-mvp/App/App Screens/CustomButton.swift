//
//  CustomButton.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 2/26/24.
//

import SwiftUI

// MARK: Reusable Custom Button
struct CustomButton: View {
    var title: String
    var onClick: () -> ()
    
    var body: some View {
        Button(action: onClick) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .foregroundColor(.white)
                .background(Color("BG"))
                .cornerRadius(10)
        }
        .padding(.horizontal, 15)
    }
}

