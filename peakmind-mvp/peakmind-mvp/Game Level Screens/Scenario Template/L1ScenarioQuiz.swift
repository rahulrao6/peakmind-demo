//
//  L1ScenarioQuiz.swift
//  peakmind-mvp
//
//  Created by Katharina Reimer on 4/11/24.
//

import SwiftUI

struct L1ScenarioQuiz: View {
    var body: some View {
        ScenarioQuizTemplate(titleText: "Mt. Anxiety Level One",
                             questionText: "How can Alex best manage his stress?",
                             options: [
                                "Overwork",
                                "Meditate",
                                "Avoid",
                                "Isolate"
                            ],
                             nextScreen: VStack{})
    }
}

#Preview {
    L1ScenarioQuiz()
}
