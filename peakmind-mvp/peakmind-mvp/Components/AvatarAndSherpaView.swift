//
//  AvatarAndSherpaView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 4/1/24.
//

import SwiftUI

struct AvatarAndSherpaView2: View {

    var body: some View {            
        HStack {
                Image("Raj") // Ensure this image is in your asset catalog
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .padding(.leading)
                    .offset(x: -30) // Move Sherpa image 20 points down
                    .offset(y: 10) // Move Sherpa image 20 points down
                
                Spacer()
                
                Image("Sherpa") // Ensure this image is in your asset catalog
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)
                    .padding(.trailing)
                    .offset(x: -10) // Move Sherpa image 20 points down

            }
    }
}

#Preview {
    AvatarAndSherpaView2()
}
