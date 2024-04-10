//
//  SherpaFullMoonID.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/17/24.
//

import SwiftUI

struct SherpaFullMoonView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    let sherpaText = "It seems there is a full moon. That must be why all of the werewolves are out. Times like these can be stressful but you will get through it. Take it one step at a time."
    @State private var animatedText = ""
    @State var navigateToNext = false


    var body: some View {
        AnimatedSpeechBubble(title: "Mt. Anxiety Level One",
                             sherpaText: sherpaText,
                             nextScreen: AnxietyGoalSetting(viewModel: _viewModel)
                                            .navigationBarBackButtonHidden(true))
    }
}



struct SherpaFullMoonView_Previews: PreviewProvider {
    static var previews: some View {
        SherpaFullMoonView()
    }
}
