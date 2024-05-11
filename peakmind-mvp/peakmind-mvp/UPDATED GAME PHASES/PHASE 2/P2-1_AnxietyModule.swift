//
//  P2-1_AnxietyModule.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 4/21/24.
//

import SwiftUI

struct P2_1_AnxietyModule: View {
    @State private var selectedPage = 0
    let pageTexts = [
        "• Anxiety is our bodies natural response to stress. It is what triggers the fight, flight, or freeze response in our brain pathways.\n• There are many different types of anxiety disorders. Different types of anxiety and anxiety disorders result in different symptoms and triggers.",
        "• Anxiety affects the body and mind, including symptoms like rapid heartbeat, excessive sweating, and intrusive thoughts.\n• Anxiety is often influenced by genetic factors as well. Trauma, abuse, neglect, and poverty among other life experiences are known to increase anxiety.",
        "• Anxiety Disorders affect 18% of adults in the United States. With over 40 million adults experiencing this, it’s important to learn how to cope.\n• Managing anxiety includes grounding, mindfulness, and understanding the different factors influencing it."
    ]

    var body: some View {
        MultiSectionView(title: "Mt. Anxiety: Phase Two",
                         sectionHeader: "What is Anxiety?",
                         pageTexts: pageTexts,
                         nextScreen: P2_1_AnxietyModule()
                                        .navigationBarBackButtonHidden(true))
    }
}

#Preview {
    P2_1_AnxietyModule()
}
