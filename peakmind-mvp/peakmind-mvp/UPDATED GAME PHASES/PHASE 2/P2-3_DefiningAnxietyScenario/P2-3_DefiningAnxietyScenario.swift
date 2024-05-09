//
//  P2-3_DefiningAnxietyScenario.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 4/21/24.
//

import SwiftUI

struct P2_3_DefiningAnxietyScenario: View {
    var closeAction: () -> Void

    var body: some View {
        ScenarioTemplate(titleText: "Mt. Anxiety: Phase Two",
                         scenarioTexts: ["Let’s discuss your first scenario of phase two. This will help you prepare for real life events.", "Imagine you're about to have your first day of a new job or school."],
                         nextScreen: P2_3_ScenarioQuiz(), closeAction: closeAction)
    }
}

//#Preview {
//    P2_3_DefiningAnxietyScenario()
//}
