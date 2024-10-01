//
//  GameUnavailable.swift
//  peakmind-mvp
//
//  Created by James Wilson on 9/30/24.
//

import SwiftUI

struct LevelUnavailable: View {
    var closeAction: () -> Void
    
    var body: some View {
        Text("This level is coming soon!")
        Button("Close") {
            closeAction()
        }
    }
}
