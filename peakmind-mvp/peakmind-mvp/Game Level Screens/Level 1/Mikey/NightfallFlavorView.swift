//
//  NightfallFlavorView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/17/24.
//

import SwiftUI

struct NightfallFlavorView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    let titleText = "Mt. Anxiety: Level One"
    let narrationText = "You hear the howls of wolves in the distance. They seem to be getting louder and louder."
    @State private var animatedText = ""
    @State var navigateToNext = false
    var closeAction: () -> Void


    var body: some View {
        AnimatedTextView(title: titleText,
                         narration: narrationText,
                         nextScreen: SherpaFullMoonView(viewModel: _viewModel, closeAction: closeAction)
            .navigationBarBackButtonHidden(true), closeAction: closeAction)
    }
}
//
//struct NightfallFlavorView_Previews: PreviewProvider {
//    static var previews: some View {
//        NightfallFlavorView(, closeAction: <#() -> Void#>)
//    }
//}
