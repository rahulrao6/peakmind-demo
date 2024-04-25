//
//  P1-10_LifestyleModule.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 4/21/24.
//

import SwiftUI

struct P1_10_LifestyleModule: View {
    @State private var selectedPage = 0
    let pageTexts = [
        "• Making changes to manage anxiety involves cognitive, behavioral, and relaxation strategies that can significantly improve your quality of life.\n• We’re often concerned with taking care of others with anxiety, but its important to remember to care for yourself too.",
        "• Anyone can improve on their mental health if they take the proper steps, learning to cope and manage anxiety.\n• Maintaining consistency with your wellness routines will lead to a happier and healthier life both emotionally and physically.",
        "• Your anxieties are shaped by a series of triggers, environmental factors, and your upbringing. Anyone can learn how these occur.\n• Some coping mechanisms include breathing exercises, mindfulness, reading, walking, or doing puzzles. Your journey to conquering anxiety allows you to pick the right ones for you!"
    ]

    var body: some View {
        MultiSectionView(title: "Mt. Anxiety: Phase One",
                         sectionHeader: "Your Lifestyle",
                         pageTexts: pageTexts,
                         nextScreen: P1_MentalHealthMod()
                                        .navigationBarBackButtonHidden(true))
    }
}

#Preview {
    P1_10_LifestyleModule()
}
