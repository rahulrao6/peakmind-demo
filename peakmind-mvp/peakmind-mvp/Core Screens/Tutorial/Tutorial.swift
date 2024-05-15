//import SwiftUI
//import Combine
//import FirebaseFirestore
//
//// Define a data structure for tutorial pages
//struct TutorialPage {
//    var view: AnyView
//    var text: String
//}
//
//// ViewModel to manage tutorial pages and navigation
//class TutorialViewModel: ObservableObject {
//    @Published var currentPage = 0
//    
//    // Array of TutorialPages
//
//    
//
//
//
//}
//
//// Tutorial view that manages the display of tutorial pages
//struct TutorialView: View {
//    @EnvironmentObject var tutorialViewModel: TutorialViewModel
//    @EnvironmentObject var viewModel: AuthViewModel
//    @Binding var isShowingTutorial: Bool
//    @State var currentPage = 0
//
//    let tutorialPages: [TutorialPage] = [
//        TutorialPage(view: AnyView(ChatView().environmentObject(AuthViewModel())), text: "Welcome to our app! This is the chat view."),
//        TutorialPage(view: AnyView(SelfCareHome().environmentObject(AuthViewModel())), text: "This is the self care home!."),
//        TutorialPage(view: AnyView(HomeDashboard().environmentObject(AuthViewModel())), text: "This is the home dashboard!"),
//        TutorialPage(view: AnyView(CommunitiesMainView()), text: "Talk to people here!"),
//        //TutorialPage(view: AnyView(JournalEntriesView()), text: "Change yourself here!")
//    ]
//    
//    var totalTutorialPages: Int {
//        tutorialPages.count
//    }
//    
//    func next() {
//        if currentPage < totalTutorialPages - 1 {
//            self.currentPage += 1
//        } else {
//            self.currentPage = 0  // Reset or handle the tutorial completion
//        }
//    }
//    
//    var body: some View {
//        VStack {
//            TabView(selection: $tutorialViewModel.currentPage) {
//                ForEach(0..<totalTutorialPages, id: \.self) { index in
//                    tutorialPageView(tutorialPages[index], continueAction: {
//                        next()
//                        if currentPage == 0 {
//                            completeTutorial()
//                            isShowingTutorial = false  // Close tutorial after the last page
//                        }
//                    })
//                }
//            }
//            .tabViewStyle(PageTabViewStyle())
//            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color.black.opacity(0.5))
//            .edgesIgnoringSafeArea(.all)
//        }
//    }
//
//    @ViewBuilder
//    private func tutorialPageView(_ page: TutorialPage, continueAction: @escaping () -> Void) -> some View {
//        ZStack {
//            page.view
//                .edgesIgnoringSafeArea(.all)  // Ensures the background view fills the entire screen
//
//            VStack {
//                Spacer()
//                SherpaTutorialBox(tutorialText: page.text, continueAction: continueAction)
//                Spacer()
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color.black.opacity(0.5))
//            .edgesIgnoringSafeArea(.all)  // Ensures the modal and background cover the entire screen
//        }
//    }
//
//    // Function to complete the tutorial and update the user flag in Firestore
//    private func completeTutorial() {
//        guard let user = viewModel.currentUser else {
//            print("No authenticated user found.")
//            return
//        }
//        
//        let db = Firestore.firestore()
//        let userRef = db.collection("users").document(user.id)
//
//        // Set `hasCompletedTutorial` to true
//        userRef.updateData(["hasCompletedTutorial": true]) { error in
//            if let error = error {
//                print("Error updating tutorial completion flag: \(error)")
//            } else {
//                print("Tutorial completion flag updated successfully.")
//                Task {
//                    await viewModel.fetchUser()  // Refresh user data
//                }
//            }
//        }
//    }
//}
//// Preview Provider for SwiftUI previews in Xcode
//struct TutorialView_Previews: PreviewProvider {
//    static var previews: some View {
//        TutorialView(isShowingTutorial: .constant(true))
//            .environmentObject(TutorialViewModel())
//    }
//}
import SwiftUI
import Combine
import FirebaseFirestore

struct TutorialPage {
    var view: AnyView
    var text: String
}

class TutorialViewModel: ObservableObject {
    @Published var currentPage = 0
}

struct TutorialView: View {
    @EnvironmentObject var tutorialViewModel: TutorialViewModel
    @EnvironmentObject var viewModel: AuthViewModel
    @Binding var isShowingTutorial: Bool

    // Initialize tutorial pages with the viewModel
    var tutorialPages: [TutorialPage] {
        [
            TutorialPage(view: AnyView(ChatView().environmentObject(viewModel)), text: "Welcome to our app! This is the chat view."),
            TutorialPage(view: AnyView(SelfCareHome().environmentObject(viewModel)), text: "This is the self care home!"),
            TutorialPage(view: AnyView(HomeDashboard(selectedTab: .constant(2)).environmentObject(viewModel)), text: "This is the home dashboard!"),
            TutorialPage(view: AnyView(AnxietyCommunityView()), text: "Talk to people here!"),

            // Add more pages as necessary
        ]
    }

    func next() {
        if tutorialViewModel.currentPage < tutorialPages.count - 1 {
            tutorialViewModel.currentPage += 1
        } else {
            isShowingTutorial = false  // Close tutorial after the last page
            completeTutorial()
        }
    }
    
    var body: some View {
        VStack {
            TabView(selection: $tutorialViewModel.currentPage) {
                ForEach(0..<tutorialPages.count, id: \.self) { index in
                    tutorialPageView(tutorialPages[index])
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
    private func tutorialPageView(_ page: TutorialPage) -> some View {
        ZStack {
            page.view
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                SherpaTutorialBox(tutorialText: page.text, continueAction: next)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.5))
            .edgesIgnoringSafeArea(.all)
        }
    }

    private func completeTutorial() {
        guard let user = viewModel.currentUser else {
            print("No authenticated user found.")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.id)
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

struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView(isShowingTutorial: .constant(true))
            .environmentObject(TutorialViewModel())
            .environmentObject(AuthViewModel())
    }
}
