//
//  Background.swift
//  peakmind-mvp
//
//  Created by Katharina Reimer on 4/7/24.
//

import SwiftUI

struct Background: View {
    
    var body: some View {
        Image("MainBG")
            .resizable()
            .edgesIgnoringSafeArea(.all)
            .aspectRatio(contentMode: .fill)
    }
}

#Preview {
    Background()
}
