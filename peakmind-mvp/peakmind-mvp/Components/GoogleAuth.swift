////
////
////
//
//import Foundation
//import FirebaseAuth
//import GoogleSignIn
//import Firebase
//
//struct GoogleAuthenticationStruct {
//    static let share = GoogleAuthenticationStruct()
//    let viewModel = AuthViewModel()
//
//
//    init() {}
//    
//    func signinWithGoogle() async throws {
//        // google sign in
//        guard let clientID = FirebaseApp.app()?.options.clientID else {
//            fatalError("no firebase clientID found")
//        }
//
//        // Create Google Sign In configuration object.
//        let config = GIDConfiguration(clientID: clientID)
//        GIDSignIn.sharedInstance.configuration = config
//        
//        //get rootView
//        let scene = await UIApplication.shared.connectedScenes.first as? UIWindowScene
//        guard let rootViewController = await scene?.windows.first?.rootViewController
//        else {
//            fatalError("There is no root view controller!")
//        }
//        
//        //google sign in authentication response
//        let result = try await GIDSignIn.sharedInstance.signIn(
//            withPresenting: rootViewController
//        )
//        let user = result.user
//        guard let idToken = user.idToken?.tokenString else {
//            throw fatalError("Unexpected error occurred, please retry")
//        }
//        
//        //Firebase auth
//        let credential = GoogleAuthProvider.credential(
//            withIDToken: idToken, accessToken: user.accessToken.tokenString
//        )
//        let result_fetch = try await Auth.auth().signIn(with: credential)
//        try await viewModel.setUserDetails(result_fetch: result_fetch)
//        //viewModel.userSession = result_fetch.user
//
//    }
//
//
//
//}
