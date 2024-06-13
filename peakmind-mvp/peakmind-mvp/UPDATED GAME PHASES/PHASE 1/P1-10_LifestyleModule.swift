//
//  P1-10_LifestyleModule.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 4/21/24.
//

import SwiftUI

struct P1_10_LifestyleModule: View {
    var closeAction: () -> Void
    @State private var selectedPage = 0
    let pageTexts = [
        "• Feeling overwhelmed by anxiety? You're not alone. But the good news is, there are powerful tools you can use to take charge of your well-being.",
        "• We often prioritize supporting others with anxiety, but remember, self-care is essential too! Let's explore strategies that combine mental exercises, practical actions, and relaxation techniques to significantly improve your quality of life.",
        "• There's always room to grow your mental well-being. By learning to manage anxiety, you can unlock a happier and healthier you. \n• Ready to feel your best? Make consistency your secret weapon! Sticking to your wellness routine unlocks a happier, healthier you.",
        "• Ever wonder why anxiety hits you sometimes? It's not random! Your anxieties are influenced by a combination of things: specific triggers, your environment, and even your upbringing. Understanding these factors empowers you to manage your anxiety more effectively.\n",
        "• Deep breaths, mindful moments, getting lost in a book, nature walks, or puzzling it out - these are just a few tools to combat anxiety. The best part? You get to pick what works for YOU on your journey to conquering anxiety!"
    ]

    var body: some View {
        MultiSectionView(title: "Mt. Anxiety: Phase One",
                         sectionHeader: "Your Lifestyle",
                         pageTexts: pageTexts,
                         nextScreen: P1_MentalHealthMod(closeAction: closeAction)
            .navigationBarBackButtonHidden(true), closeAction: closeAction)
    }
}
//
//#Preview {
//    P1_10_LifestyleModule()
//}
