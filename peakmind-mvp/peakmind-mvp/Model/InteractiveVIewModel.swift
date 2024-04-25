//
//  InteractiveVIewModel.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 4/25/24.
//

import Foundation
import SwiftUI

// ViewModel for handling the logic and state of the Cause and Effect view
class InteractiveViewModel: ObservableObject {
    @Published var causeEffectPairs: [CauseEffectPair] = [
        CauseEffectPair(cause: "Cause", effect: "Effect"),
        CauseEffectPair(cause: "Cause", effect: "Effect"),
        CauseEffectPair(cause: "Cause", effect: "Effect")
    ]
}
