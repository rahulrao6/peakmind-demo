//
//  P2-12_CopingModule.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 4/21/24.
//

import SwiftUI

struct P2_12_CopingModule: View {
    @State private var selectedPage = 0
    var closeAction: () -> Void

    let pageTexts = [
        "• Learning to recognize and change negative thought patterns that contribute to anxiety. This approach helps you think about anxiety-inducing situations in a more positive and realistic way.",
        "• Progressive Muscle Relaxation: Reduce physical tension linked to anxiety by tensing and then relaxing different muscle groups. This method improves physical relaxation and mental calmness.",
        "• Mindfulness Meditation: Incorporate mindfulness into your daily routine to enhance your awareness of the present moment. This practice helps you acknowledge and manage anxious thoughts without overreacting to them.",
        "• Healthy Lifestyle Choices: Maintain a routine that includes regular exercise, adequate sleep, and nutritious food. These habits support overall physical health, which can significantly impact mental well-being.",
        "• Social Support: Strengthen relationships with family and friends to build a support network. Sharing your experiences with anxiety can alleviate feelings of isolation and provide emotional support."
        
    ]

    var body: some View {
        MultiSectionView(title: "Mt. Anxiety: Phase Two",
                         sectionHeader: "Anxiety Coping Strategies",
                         pageTexts: pageTexts,
                         nextScreen: P2_12_CopingModule(closeAction: closeAction)
            .navigationBarBackButtonHidden(true), closeAction: closeAction)
    }
}

//#Preview {
//    P2_12_CopingModule()
//}
