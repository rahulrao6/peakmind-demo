//
//  P1-3_ScenarioQuiz.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 4/22/24.
//

import SwiftUI

struct P1_3_ScenarioQuiz: View {
    var closeAction: () -> Void

    var body: some View {
        ScenarioQuizTemplate(titleText: "Mt. Anxiety: Phase One",
                             questionText: "How would you handle the situation?",
                             options: [
                                "Engage in physical activity",
                                "Call a friend or family member",
                                "Complete mindfulness activities",
                                "Ignore the stress."
                            ],
                             nextScreen: VStack{}, closeAction: closeAction)
    }
}

//#Preview {
//    P1_3_ScenarioQuiz()
//}
