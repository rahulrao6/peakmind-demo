//
//  Level3Reflection.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/17/24.
//

import SwiftUI

struct Level3Reflection: View {
    @EnvironmentObject var viewModel: AuthViewModel

    let titleText = "Mt. Anxiety: Level Three Reflection"
    let narrationText = "In this level you learned about high stress situations and panic. You also learned how triggers work and how they flare up anxiety. Amazing work so far."
    @State private var animatedText = ""
    @State var navigateToNext = false


    var body: some View {
        AnimatedTextView(title: titleText,
                         narration: narrationText,
                         nextScreen: SherpaFullMoonView(viewModel: _viewModel)
                                        .navigationBarBackButtonHidden(true))
    }
}

struct Level3Reflection_Previews: PreviewProvider {
    static var previews: some View {
        Level3Reflection()
    }
}
