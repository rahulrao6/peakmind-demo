//
//  InteractiveViewModel.swift
//  peakmind-mvp
//
//  Created by Mingwei Li on 4/22/24.
//

import Foundation
import SwiftUI

// ViewModel for handling the logic and state of the Cause and Effect view
class InteractiveViewModel: ObservableObject {
    @Published var causeEffectPairs: [CauseEffectPair] = [
        CauseEffectPair(cause: "         Cause", effect: "        Effect"),
        CauseEffectPair(cause: "         Cause", effect: "        Effect"),
        CauseEffectPair(cause: "         Cause", effect: "        Effect")
    ]
}
