//
//  CommunitiesMainView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 4/22/24.
//

import SwiftUI

struct CommunitiesMainView: View {
    var body: some View {
        Image("CommPreview")  // Ensure "CommPreview" is the correct name of your image asset
            .resizable()
            .scaledToFill()
            .frame(minWidth: UIScreen.main.bounds.width, minHeight: UIScreen.main.bounds.height)
            .clipped()
            .edgesIgnoringSafeArea(.all)  // This will extend the image to the edge of the display, ignoring the safe area
    }
}

struct CommunitiesMainView_Previews: PreviewProvider {
    static var previews: some View {
        CommunitiesMainView()
    }
}
