////
////  AuthViewModel2.swift
////  peakmind-mvp
////
////  Created by Raj Jagirdar on 4/15/24.
////
//
//import Foundation
//import Foundation
//import Firebase
//import FirebaseAuth
//import FirebaseFirestoreSwift
//import GoogleSignIn
//
//@MainActor
//class AuthViewModel2: ObservableObject {
//    @Published var userSession: FirebaseAuth.User?
//    @Published var currentUser: UserData?  // Use UserData model for consistency
//
//    init() {
//        self.userSession = Auth.auth().currentUser
//        if userSession != nil {
//            Task { await fetchUser() }
//        }
//    }
//    
//    func signIn(withEmail email: String, password: String) async {
//        do {
//            let result = try await Auth.auth().signIn(withEmail: email, password: password)
//            self.userSession = result.user
//            await fetchUser()
//        } catch {
//            print("Debug: failed to log in with error \(error.localizedDescription)")
//            // Implement better error handling or user feedback mechanism
//        }
//    }
//    
//    func createUser(withEmail email: String, password: String, fullname: String, username: String, avatar: String, background: String) async {
//        do {
//            let result = try await Auth.auth().createUser(withEmail: email, password: password)
//            self.userSession = result.user
//            let newUser = UserData(id: result.user.uid, fullname: fullname, email: email, username: username, selectedAvatar: avatar, selectedBackground: background, hasCompletedInitialQuiz: false, hasSetInitialAvatar: false, inventory: [], LevelOneCompleted: false, LevelTwoCompleted: false)
//            let encodedUser = try Firestore.Encoder().encode(newUser)
//            try await Firestore.firestore().collection("users").document(newUser.id).setData(encodedUser)
//            self.currentUser = newUser
//        } catch {
//            print("Debug failed to create user \(error.localizedDescription)")
//        }
//    }
//    
//    func signOut() {
//        do {
//            try Auth.auth().signOut()
//            self.userSession = nil
//            self.currentUser = nil
//        } catch {
//            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
//        }
//    }
//    
//    func fetchUser() async {
//        guard let uid = userSession?.uid else { return }
//        do {
//            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
//            self.currentUser = try snapshot.data(as: UserData.self)
//        } catch {
//            print("Failed to fetch user data: \(error)")
//        }
//    }
//    
//    func deleteAccount() async {
//        guard let currentUser = self.currentUser else { return }
//        do {
//            try await Auth.auth().currentUser?.delete()
//            try await Firestore.firestore().collection("users").document(currentUser.id).delete()
//            self.userSession = nil
//            self.currentUser = nil
//        } catch {
//            print("DEBUG: Failed to delete account with error \(error.localizedDescription)")
//        }
//    }
//
//    func resetPassword(email: String) {
//        Auth.auth().sendPasswordReset(withEmail: email) { error in
//            if let error = error {
//                print("Error resetting password: \(error.localizedDescription)")
//            }
//        }
//    }
//
//    func signinWithGoogle() async -> Bool  {
//        guard let clientID = FirebaseApp.app()?.options.clientID else {
//          fatalError("No client ID found in Firebase configuration")
//        }
//        let config = GIDConfiguration(clientID: clientID)
//        GIDSignIn.sharedInstance.configuration = config
//
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let window = windowScene.windows.first,
//              let rootViewController = window.rootViewController else {
//          print("There is no root view controller!")
//          return false
//        }
//
//          do {
//            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
//
//            let user = userAuthentication.user
//              guard let idToken = user.idToken else { throw fatalError("ID token missing") }
//            let accessToken = user.accessToken
//
//            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
//                                                           accessToken: accessToken.tokenString)
//
//            let result = try await Auth.auth().signIn(with: credential)
//            let firebaseUser = result.user
//            print("User \(firebaseUser.uid) signed in with email \(firebaseUser.email ?? "unknown")")
//              self.userSession = result.user
//              
//              Task{
//                  guard let snapshot = try? await Firestore.firestore().collection("users").document(firebaseUser.uid).getDocument() else {return}
//                  
//                  self.currentUser = try? snapshot.data(as: User.self)
//                  
//                  print("Debug current user is \(String(describing: self.currentUser))")
//              }
//            return true
//          }
//          catch {
//            print(error.localizedDescription)
//            return false
//          }
//
//
//    }
//}
