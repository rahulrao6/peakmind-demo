//
//  LevelCircle.swift
//  peakmind-mvp
//
//  Created by James Wilson on 5/25/24.
//

import SwiftUI



struct LevelCircle: View {
    @State var level: String
    
    var body: some View {
        Circle()
            .frame(width: 100, height: 100)
            .padding(.leading)
            .foregroundStyle(.white)
            .overlay {
                Text(level)
                    .font(.system(size: 50, weight: .heavy, design: .default))
                    .padding(.leading)
            }

    }
}
