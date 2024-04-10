//
//  DangersOfNightfallView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/17/24.
//

import SwiftUI

struct DangersOfNightfallView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    let sherpaText = "Be careful of the dangers at night. In the mountains, there’s wolves, winds, and critters. Be wary of the limited visibility and always stay on a path."
    @State private var animatedText = ""
    @State var navigateToNext = false

    var body: some View {
        AnimatedSpeechBubble(title:"Mt. Anxiety Level One",
                             sherpaText: sherpaText,
                            nextScreen: NightfallFlavorView(viewModel: _viewModel).navigationBarBackButtonHidden(true))
    }
}



struct DangersOfNightfallView_Previews: PreviewProvider {
    static var previews: some View {
        DangersOfNightfallView()
    }
}
