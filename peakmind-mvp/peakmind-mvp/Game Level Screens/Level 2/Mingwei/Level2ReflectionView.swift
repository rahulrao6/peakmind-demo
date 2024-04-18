//
//  Level1Reflection.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/17/24.
//

import SwiftUI

struct Level2ReflectionView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    let titleText = "Mt. Anxiety: Level Two Reflection"
    let narrationText = "In this level, you’ve learned about physical elements of anxiety and how to manage them. Physical aspects of anxiety can be controlled with proper coping, breathing, and progressive muscle relaxation."
    @State private var animatedText = ""
    @State var navigateToNext = false


    var body: some View {
        AnimatedTextView(title: titleText,
                         narration: narrationText,
                         nextScreen: SherpaFullMoonView(viewModel: _viewModel)
                                        .navigationBarBackButtonHidden(true))
    }
}

struct Level2ReflectionView_Previews: PreviewProvider {
    static var previews: some View {
        Level2ReflectionView()
    }
}
