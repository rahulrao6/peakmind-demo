//
//  P2-6_AnxietyModule.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 4/21/24.
//

import SwiftUI

struct P2_6_AnxietyModule: View {
    @State private var selectedPage = 0
    let pageTexts = [
        "• There are various different factors that are likely to ignite anxious thoughts. Let’s walk through the different types that are most prevalent.\n• The first of these factors is pessimism, which is where you tend to expect bad outcomes to happen.",
        "• Another factor is catastrophizing, which is when we take a small problem and perceive it as much larger than it really is.\n• Guilt and shame are another influencing factor, it is when you believe others will perceive you negatively.",
        "• Worry is a very frequent igniting factor. It includes when one frequently thinks about possible negative events.\n• Obsessive Thinking is when one can’t stop focusing on a particular problem or behavior.",
        "• Perfectionism is when we have unrealistic expectations and expect us not to make mistakes.\n• These different anxiety igniting factors are so important to recognize within yourself to identify what you experience."
    ]

    var body: some View {
        MultiSectionView(title: "Mt. Anxiety: Phase Two",
                         sectionHeader: "Anxiety Igniting Thoughts",
                         pageTexts: pageTexts,
                         nextScreen: P2_1_AnxietyModule()
                                        .navigationBarBackButtonHidden(true))
    }
}

#Preview {
    P2_6_AnxietyModule()
}
