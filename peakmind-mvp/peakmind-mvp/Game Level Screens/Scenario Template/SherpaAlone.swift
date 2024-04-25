//
//  SherpaAlone.swift
//  peakmind-mvp
//
//  Created by Katharina Reimer on 4/11/24.
//

import SwiftUI

struct SherpaAlone: View {
    var body: some View {
        HStack {
            Image("Sherpa")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
        }
    }
}

#Preview {
    SherpaAlone()
}
