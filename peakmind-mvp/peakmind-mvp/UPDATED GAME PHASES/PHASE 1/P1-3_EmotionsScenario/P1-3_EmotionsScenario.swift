//
//  P1-3_EmotionsScenario.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 4/21/24.
//

import SwiftUI

struct P1_3_EmotionsScenario: View {
    var closeAction: () -> Void
    @State private var activeModal: Screen?

    var body: some View {
        ScenarioTemplate(titleText: "Mt. Anxiety: Phase One",
                         scenarioTexts: ["Now let’s work through a scenario. These help you with decision making related to mental health choices.", "Let's work through a scenario to help you in the future.", "You’ve had a very stressful day at work. You are getting home late and aren’t happy. How would you most handle the situation?"],
                         nextScreen: P1_3_ScenarioQuiz(closeAction: closeAction)){
            activeModal = Screen(screenName: "P1_3_ScenarioQuiz")
        }
        .fullScreenCover(item: $activeModal) { screen in
            destinationView(for: "P1_3_ScenarioQuiz") {
                activeModal = nil
                closeAction()
            }
        }
    }
    @ViewBuilder
    private func destinationView(for screenName: String, close: @escaping () -> Void) -> some View {
        P1_3_ScenarioQuiz(closeAction: closeAction)
    }
}
//
//#Preview {
//    P1_3_EmotionsScenario(closeAction: print(""))
//}
