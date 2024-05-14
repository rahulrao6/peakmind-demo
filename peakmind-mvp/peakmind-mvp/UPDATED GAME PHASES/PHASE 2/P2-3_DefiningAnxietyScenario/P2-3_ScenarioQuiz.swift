//
//  P2-3_ScenarioQuiz.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 4/22/24.
//

import SwiftUI

struct P2_3_ScenarioQuiz: View {
    var closeAction: () -> Void

    var body: some View {
        ScenarioQuizTemplate(titleText: "Mt. Anxiety: Phase Two",
                             questionText: "What might this situation make you experience?",
                             options: [
                                "No symptoms",
                                "Social anxiety",
                                "Generalized anxiety",
                                "Phobia of new places"
                            ],
                             nextScreen: VStack{}, closeAction: closeAction)
    }
}


