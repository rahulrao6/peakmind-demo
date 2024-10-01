//
//  GameUnavailable.swift
//  peakmind-mvp
//
//  Created by James Wilson on 9/30/24.
//

import SwiftUI

struct GameUnavailable: View {
    var closeAction: () -> Void
    
    var body: some View {
        Text("This minigame is coming soon!")
        Button("Close") {
            closeAction()
        }
    }
}
