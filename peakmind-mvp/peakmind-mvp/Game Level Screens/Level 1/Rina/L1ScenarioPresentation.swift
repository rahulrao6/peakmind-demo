//
//  L1ScenarioPresentation.swift
//  peakmind-mvp
//
//  Created by Katharina Reimer on 4/11/24.
//

import SwiftUI

struct L1ScenarioPresentation: View {
    var body: some View {
        ScenarioTemplate(titleText: "Mt. Anxiety Level One",
                         scenarioText: "Alex feels very stressed out about a deadline coming up in a few days. Alex is overwhelmed with everything.",
                         nextScreen: L1ScenarioQuiz())
    }
}

#Preview {
    L1ScenarioPresentation()
}
