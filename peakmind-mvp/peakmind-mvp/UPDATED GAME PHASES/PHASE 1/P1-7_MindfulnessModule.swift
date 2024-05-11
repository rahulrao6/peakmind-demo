//
//  P1-7_MindfulnessModule.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 4/21/24.
//

import SwiftUI

struct P1_7_MindfulnessModule: View {
    @State private var selectedPage = 0
    let pageTexts = [
        "• Mindfulness is the practice of being consciously aware of yourself and present in the moment.\n• Regular mindfulness practice helps reduce stress, improve emotional reactivity, and increase overall mental well-being.",
        "• Techniques include meditation, mindful breathing, and body scans, each helping to anchor the present moment.\n• Integrating mindfulness into daily activities, like eating or walking, can enhance consistency and effectiveness.",
        "• Numerous studies validate mindfulness practices positively impacting our mental health.\n• Choosing different mindfulness tasks to complete every day will lead to being more in tune with your mental health."
    ]

    var body: some View {
        MultiSectionView(title: "Mt. Anxiety: Phase One",
                         sectionHeader: "Mindfulness",
                         pageTexts: pageTexts,
                         nextScreen: P1_MentalHealthMod()
                                        .navigationBarBackButtonHidden(true))
    }
}

#Preview {
    P1_7_MindfulnessModule()
}
