import SwiftUI

struct PlayScreen2: View {
    @EnvironmentObject var viewModel : AuthViewModel
    @State private var animateImage = false
    @State private var showTopText = false
    @State private var showBottomText = false
    @State private var tapToContinueOpacity = 0.0
    @State private var tapCount = 0  // State variable to count taps
    @State private var navigateToQuestions = false  // State variable to control navigation


    var body: some View {
        if let user = viewModel.currentUser {
            NavigationStack() {
                if (!user.LevelOneCompleted) {
                    Module1().navigationBarBackButtonHidden(true).environmentObject(viewModel)
                } else {
                    Level2().navigationBarBackButtonHidden(false)
                }
            }
        }
    }
}

struct PlayScreen2_Previews: PreviewProvider {
    static var previews: some View {
        PlayScreen2()
    }
}
