import SwiftUI
import Combine
import FirebaseFirestore

// Define a data structure for tutorial pages
struct TutorialPage {
    var view: AnyView
    var text: String
}

// ViewModel to manage tutorial pages and navigation
class TutorialViewModel: ObservableObject {
    @Published var currentPage = 0
    
    // Array of TutorialPages
    let tutorialPages: [TutorialPage] = [
        TutorialPage(view: AnyView(ChatView()), text: "Welcome to our app! This is the chat view."),
        TutorialPage(view: AnyView(SelfCareHome()), text: "This is the self care home!."),
        TutorialPage(view: AnyView(HomeDashboard()), text: "This is the home dashboard!"),
        TutorialPage(view: AnyView(CommunitiesMainView()), text: "Talk to people here!"),
        //TutorialPage(view: AnyView(JournalEntriesView()), text: "Change yourself here!")
    ]
    
    var totalTutorialPages: Int {
        tutorialPages.count
    }

    func next() {
        if currentPage < totalTutorialPages - 1 {
            currentPage += 1
        } else {
            currentPage = 0  // Reset or handle the tutorial completion
        }
    }
}

// Tutorial view that manages the display of tutorial pages
struct TutorialView: View {
    @EnvironmentObject var tutorialViewModel: TutorialViewModel
    @EnvironmentObject var viewModel: AuthViewModel
    @Binding var isShowingTutorial: Bool

    var body: some View {
        VStack {
            TabView(selection: $tutorialViewModel.currentPage) {
                ForEach(0..<tutorialViewModel.totalTutorialPages, id: \.self) { index in
                    tutorialPageView(tutorialViewModel.tutorialPages[index], continueAction: {
                        tutorialViewModel.next()
                        if tutorialViewModel.currentPage == 0 {
                            completeTutorial()
                            isShowingTutorial = false  // Close tutorial after the last page
                        }
                    })
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.5))
            .edgesIgnoringSafeArea(.all)
        }
    }

    @ViewBuilder
    private func tutorialPageView(_ page: TutorialPage, continueAction: @escaping () -> Void) -> some View {
        ZStack {
            page.view
                .edgesIgnoringSafeArea(.all)  // Ensures the background view fills the entire screen

            VStack {
                Spacer()
                SherpaTutorialBox(tutorialText: page.text, continueAction: continueAction)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.5))
            .edgesIgnoringSafeArea(.all)  // Ensures the modal and background cover the entire screen
        }
    }

    // Function to complete the tutorial and update the user flag in Firestore
    private func completeTutorial() {
        guard let user = viewModel.currentUser else {
            print("No authenticated user found.")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.id)

        // Set `hasCompletedTutorial` to true
        userRef.updateData(["hasCompletedTutorial": true]) { error in
            if let error = error {
                print("Error updating tutorial completion flag: \(error)")
            } else {
                print("Tutorial completion flag updated successfully.")
                Task {
                    await viewModel.fetchUser()  // Refresh user data
                }
            }
        }
    }
}
// Preview Provider for SwiftUI previews in Xcode
struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView(isShowingTutorial: .constant(true))
            .environmentObject(TutorialViewModel())
    }
}
