//
//  Level1Reflection.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/17/24.
//

import SwiftUI

struct Level1Reflection: View {
    @EnvironmentObject var viewModel: AuthViewModel

    let titleText = "Mt. Anxiety: Level One Reflection"
    let narrationText = "You’ve learned so much already about how anxiety works.\nAmazing work starting your first habit to understanding how anxiety works.\nThroughout this journey, you will gain a toolbox on how to manage your anxiety."
    @State private var animatedText = ""
    @State var navigateToNext = false

//  adadfasdfas
    var body: some View {
        AnimatedTextView(title: titleText,
                         narration: narrationText,
                         nextScreen: SherpaFullMoonView(viewModel: _viewModel)
                                        .navigationBarBackButtonHidden(true))
    }
}

struct Level1Reflection_Previews: PreviewProvider {
    static var previews: some View {
        Level1Reflection()
    }
}
