//
//  AnxietyModuleView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/17/24.
//

import SwiftUI

struct AnxietyModuleView: View {
    @State private var selectedPage = 0
    var closeAction: () -> Void

    let pageTexts = [
        "• Anxiety is your body's natural response to stress.\n• Historically, anxiety played a role in triggering life-saving reactions for our ancestors.\n• Anxiety can be temporary or become recurring over long periods of time.",
        "• Anxiety can cause a variety of effects on your mental health.\n• You deserve to live with your anxiety at a manageable level.\n• Each age experiences anxiety differently, with different brain chemicals formulating at different points within your life.",
        "• Believe it or not, anxiety is more normal than you think.\n• Over a third of all teenagers and young adults will experience struggles with anxiety.\n• Always remember that you’re not alone on your journey to getting through anxiety.",
        "• Your perception of anxiety is largely based on your cultural upbringing.\n• Where and how you grew up can influence you to be more or less prone to trying different coping strategies out.\n• You may feel a stigma around anxiety, but understand it's fading every day.",
        "• Anxiety comes in many different forms, from general anxiety, panic disorders, to social anxiety.\n• Anxiety disorders often occur after there’s been recurring anxiety for a long enough time.\n• At the end of the day, anxiety is best controlled through your breathing. Take it one step at a time."
    ]

    var body: some View {
        MultiSectionView(title: "Mt. Anxiety: Level One",
                         sectionHeader: "Understanding Anxiety",
                         pageTexts: pageTexts,
                         nextScreen: AnxietyModuleView(closeAction: closeAction)
            .navigationBarBackButtonHidden(true), closeAction: closeAction)
    }
}
//
//struct AnxietyModuleView_Previews: PreviewProvider {
//    static var previews: some View {
//        AnxietyModuleView()
//    }
//}
