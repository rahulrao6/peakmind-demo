//
//  P1_MentalHealthMod.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 4/21/24.
//

import SwiftUI

struct P1_MentalHealthMod: View {
    var closeAction: () -> Void
    @State private var selectedPage = 0
    let pageTexts = [
        "• Mental health involves our emotional, psychological, and social well-being. It shapes how we perceive the world and think about ourselves.\n• Every decision we make is influenced by our mental health, making it so important to learn coping strategies and how to manage it correctly!",
        "• Managing our mental health requires a conscious effort since we have different personal and environmental needs.\n• Our mental health impacts how we interact with others, shaping personal relationships and social interactions.",
        "• Just like physical health, our mental health is equally as important. Everyone deserves to be happy.\n• Using coping strategies, support groups, and learning about our specific mental health struggles will lead to a happier lifestyle."
    ]
    
    var body: some View {
        Text("Mt. Anxiety: Phase One - What is Mental Health?")
            .font(.title)
            .padding()
            .navigationBarBackButtonHidden(true)
    }
}


//struct P1_MentalHealthMod_Previews: PreviewProvider {
//    static var previews: some View {
//        P1_MentalHealthMod(closeAction: print(""))
//    }
//}
