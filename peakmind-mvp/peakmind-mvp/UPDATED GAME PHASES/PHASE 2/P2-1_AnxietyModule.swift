//
//  P2-1_AnxietyModule.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 4/21/24.
//

import SwiftUI

struct P2_1_AnxietyModule: View {
    @State private var selectedPage = 0
    var closeAction: () -> Void

    let pageTexts = [
        "• Ever wonder why we get butterflies before a big presentation? That's anxiety in action! It's your body's built-in alarm system, triggering a fight, flight, or freeze response when it perceives danger (even if it's just a presentation!).",
        "• Anxiety isn't one-size-fits-all! There are many different types, each with its own unique set of triggers and symptoms. Let's explore and see how understanding its different forms can empower you to manage it effectively.",
        "• Anxiety affects the body and mind, including symptoms like rapid heartbeat, excessive sweating, and intrusive thoughts.\n• Anxiety is often influenced by genetic factors as well. Trauma, abuse, neglect, and poverty among other life experiences are known to increase anxiety.",
        "• Anxiety disorders affect 18% of adults in the United States. With over 40 million adults experiencing this, it’s important to learn how to cope.\n• Managing anxiety includes grounding, mindfulness, and understanding the different factors influencing it."
    ]

    var body: some View {
        MultiSectionView(title: "Mt. Anxiety: Phase Two",
                         sectionHeader: "What is Anxiety?",
                         pageTexts: pageTexts,
                         nextScreen: P2_1_AnxietyModule(closeAction: closeAction)
            .navigationBarBackButtonHidden(true), closeAction: closeAction)
    }
}

//#Preview {
//    P2_1_AnxietyModule()
//}
