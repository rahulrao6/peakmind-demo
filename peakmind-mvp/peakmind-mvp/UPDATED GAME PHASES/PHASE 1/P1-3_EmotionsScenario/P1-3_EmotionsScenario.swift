//
//  P1-3_EmotionsScenario.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 4/21/24.
//

import SwiftUI

struct P1_3_EmotionsScenario: View {
    var closeAction: () -> Void

    var body: some View {
        ScenarioTemplate(titleText: "Mt. Anxiety: Phase One",
                         scenarioTexts: ["Now let’s work through a scenario. These help you with decision making related to mental health choices.", "Let's work through a scenario to help you in the future.", "You’ve had a very stressful day at work. You are getting home late and aren’t happy. How would you most handle the situation?"],
                         nextScreen: P1_3_ScenarioQuiz(),
                         closeAction: closeAction)
    }
}
//
//#Preview {
//    P1_3_EmotionsScenario(closeAction: print(""))
//}
