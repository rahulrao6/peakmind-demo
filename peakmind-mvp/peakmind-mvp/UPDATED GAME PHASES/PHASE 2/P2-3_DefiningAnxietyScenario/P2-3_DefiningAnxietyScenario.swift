import SwiftUI

struct P2_3_DefiningAnxietyScenario: View {
    var closeAction: () -> Void
    @State private var activeModal: Screen?

    var body: some View {
        ScenarioTemplate(titleText: "Mt. Anxiety: Phase Two",
                         scenarioTexts: ["Let’s discuss your first scenario of phase two. This will help you prepare for real life events.", "Imagine you're about to have your first day of a new job or school."],
                         nextScreen: P2_3_ScenarioQuiz(closeAction: closeAction)){
            activeModal = Screen(screenName: "P2_3_ScenarioQuiz")
        }
        .fullScreenCover(item: $activeModal) { screen in
            destinationView(for: "P2_3_ScenarioQuiz") {
                activeModal = nil
                closeAction()
            }
        }
    }
    @ViewBuilder
    private func destinationView(for screenName: String, close: @escaping () -> Void) -> some View {
        P2_3_ScenarioQuiz(closeAction: closeAction)
    }
}
//
//#Preview {
//    P1_3_EmotionsScenario(closeAction: print(""))
//}
