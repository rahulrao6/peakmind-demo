//
//  P1-4_StressModule.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 4/21/24.
//

import SwiftUI

struct P1_4_StressModule: View {
    @State private var selectedPage = 0
    var closeAction: () -> Void

    let pageTexts = [
        "• Life can be stressful! It's totally normal for our bodies and minds to react to challenges, and everyone experiences stress from time to time.\n• Recognizing what triggers your stress is crucial; common triggers include work or school related pressures, financial strain, and big life changes.",
        "• Feeling stressed? It can show up in surprising ways! Headaches, muscle tension, even anxiety can be signs your body and mind are saying slow down! \n• Managing your stress involves mindfulness techniques, regular rest, and acknowledging the emotions you’re feeling.",
        "• It's important to customize your stress management to fit your personal lifestyle, increasing its effectiveness!\n• Understanding what triggers your stress and how to prevent those triggers is essential for emotional growth."
    ]

    var body: some View {
        MultiSectionView(title: "Mt. Anxiety: Phase One",
                         sectionHeader: "Stress & Triggers",
                         pageTexts: pageTexts,
                         nextScreen: P1_MentalHealthMod(closeAction: closeAction)
                                        .navigationBarBackButtonHidden(true),
        closeAction: closeAction)
    }
}
//
//#Preview {
//    P1_4_StressModule(closeAction: print(""))
//}
