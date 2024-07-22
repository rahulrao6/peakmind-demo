////
////  AuthViewModel.swift
////  peakmind-mvp
////
////  Created by Raj Jagirdar on 2/17/24.
////
//
//import Foundation
//import Firebase
//import FirebaseAuth
//import FirebaseFirestoreSwift
//import Foundation
//import FirebaseAuth
//import GoogleSignIn
//import Firebase
//
//protocol AuthenticationFormProtocol {
//    var formIsValid: Bool {get}
//}
//
//@MainActor
//class AuthViewModel : ObservableObject {
//    
//    @Published var userSession: FirebaseAuth.User?
//    @Published var currentUser : UserData?
//    //static let share = GoogleAuthenticationStruct()
//    @Published var authErrorMessage: String? // New property for error messages
//    @Published var chatRooms: [ChatRoom] = []
//    @Published var communitiesViewModel = CommunitiesViewModel() // Add this line
//
//    
//    init() {
//        
//        self.userSession = Auth.auth().currentUser
//        
//        Task {
//            await fetchUser()
//        }
//    }
//    
//    func signIn(withEmail email: String, password: String) async throws {
//        do {
//            let result = try await Auth.auth().signIn(withEmail: email, password: password)
//            self.userSession = result.user
//            Task{
//                await fetchUser()
//            }
//        } catch {
//            self.authErrorMessage = "Failed to log in: \(error.localizedDescription)"
//        }
//    }
//    
//    
//    func createUser(withEmail email: String, password: String, username: String, selectedAvatar: String, selectedBackground: String, hasCompletedInitialQuiz: Bool, hasSetInitialAvatar: Bool, LevelOneCompleted: Bool, LevelTwoCompleted: Bool) async throws {
//        do {
//            let result = try await Auth.auth().createUser(withEmail: email, password: password)
//            self.userSession = result.user
//            let user = UserData(id: result.user.uid, email: email, username: username, selectedAvatar: selectedAvatar, selectedBackground: selectedBackground, hasCompletedInitialQuiz: hasCompletedInitialQuiz, hasSetInitialAvatar: hasSetInitialAvatar, inventory: [], LevelOneCompleted: LevelOneCompleted, LevelTwoCompleted: LevelTwoCompleted, selectedWidgets: [], lastCheck: nil, weeklyStatus: [0,0,0,0,0,0,0], hasCompletedTutorial: false, completedLevels: [], completedLevels2: [], dailyCheckInStreak: 0)
//            let encodedUser = try Firestore.Encoder().encode(user)
//            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
//            await fetchUser()
//            
//        } catch {
//            self.authErrorMessage = "Failed to create user: \(error.localizedDescription)"
//            throw error
//
//        }
//    }
//    
////    func createUser2(withEmail email: String, password: String, username: String, avatar: String, background: String) async {
////        do {
////            let result = try await Auth.auth().createUser(withEmail: email, password: password)
////            self.userSession = result.user
////            let newUser = UserData(id: result.user.uid, email: email, username: username, selectedAvatar: avatar, selectedBackground: background, hasCompletedInitialQuiz: false, hasSetInitialAvatar: false, inventory: [], LevelOneCompleted: false, LevelTwoCompleted: false)
////            let encodedUser = try Firestore.Encoder().encode(newUser)
////            try await Firestore.firestore().collection("users").document(newUser.id).setData(encodedUser)
////            self.currentUser = newUser
////        } catch {
////            print("Debug failed to create user \(error.localizedDescription)")
////        }
////    }
//    
//    func signOut() {
//        
//        do {
//            try Auth.auth().signOut()
//            self.userSession = nil
//            self.currentUser = nil
//        } catch {
//            self.authErrorMessage = "Failed to sign out: \(error.localizedDescription)"
//        }
//        
//    }
//    
//    func clearError() {
//        self.authErrorMessage = nil
//    }
//    
//    func deleteAccount() async {
//        guard let user = Auth.auth().currentUser else {
//            print("DEBUG: No user is currently signed in.")
//            return
//        }
//        
//        do {
//            // Delete user data from Firestore first
//            let userId = user.uid
//            try await Firestore.firestore().collection("users").document(userId).delete()
//            
//            // Proceed with deleting the user account
//            try await user.delete()
//            signOut()
//            // Clear any related user data in the app
//            DispatchQueue.main.async { [weak self] in
//                self?.userSession = nil
//                self?.currentUser = nil
//            }
//            
//            print("User account and data successfully deleted.")
//        } catch let error {
//            print("DEBUG: Failed to delete account with error \(error.localizedDescription)")
//        }
//    }
//
//
//    func markLevelCompleted(levelID: String) async throws {
//        guard let currentUserID = userSession?.uid else {
//            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])
//        }
//
//        let db = Firestore.firestore()
//        let userRef = db.collection("users").document(currentUserID)
//
//        // Update the local model first
//        if let index = currentUser?.completedLevels.firstIndex(where: { $0 == levelID }) {
//            print("Level already marked as completed.")
//        } else {
//            currentUser?.completedLevels.append(levelID)
//        }
//
//        // Synchronize with Firestore
//        try await userRef.updateData([
//            "completedLevels": FieldValue.arrayUnion([levelID])
//        ]) { error in
//            if let error = error {
//                print("Error updating completed levels: \(error.localizedDescription)")
//            } else {
//                print("Level marked as completed successfully.")
//            }
//        }
//
//        // Refresh user data to ensure UI is updated
//        await fetchUser()
//    }
//    
//    func markLevelCompleted2(levelID: String) async throws {
//        guard let currentUserID = userSession?.uid else {
//            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])
//        }
//
//        let db = Firestore.firestore()
//        let userRef = db.collection("users").document(currentUserID)
//
//        // Update the local model first
//        if let index = currentUser?.completedLevels.firstIndex(where: { $0 == levelID }) {
//            print("Level already marked as completed.")
//        } else {
//            currentUser?.completedLevels2.append(levelID)
//        }
//
//        // Synchronize with Firestore
//        try await userRef.updateData([
//            "completedLevels2": FieldValue.arrayUnion([levelID])
//        ]) { error in
//            if let error = error {
//                print("Error updating completed levels: \(error.localizedDescription)")
//            } else {
//                print("Level marked as completed successfully.")
//            }
//        }
//
//        // Refresh user data to ensure UI is updated
//        await fetchUser()
//    }
//
//
//    
//    func resetPassword(email : String) {
//        Auth.auth().sendPasswordReset(withEmail: email) { error in
//            if let err = error {
//                print("Error: \(err.localizedDescription)")
//            }
//        }
//    }
//    
//    func saveSelectedWidgets(selected: [String]) async {
//        guard let user = currentUser else {
//            print("No authenticated user found.")
//            return
//        }
//        let db = Firestore.firestore()
//        let userRef = db.collection("users").document(user.id)
//        
//        do {
//            try await userRef.setData(["selectedWidgets": selected], merge: true)
//            // Update local user data and refresh
//            Task{
//                await fetchUser()
//
//            }
//            print("Widget selection updated successfully.")
//        } catch {
//            print("Error updating widget selection: \(error)")
//        }
//    }
//
//    
//    func fetchUser() async {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        
//        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else {return}
//    
//        self.currentUser = try? snapshot.data(as: UserData.self)
//        
//        print("Debug current user is \(String(describing: self.currentUser))")
//        communitiesViewModel.loadCommunities()
//
//        
//    }
//    
//    
//    func setUserDetails(result_fetch: AuthDataResult) async throws {
//        print("called the setUserDetails func")
//        self.userSession = result_fetch.user
//        Task{
//            await fetchUser()
//        }
//    }
//    
////    func fetchMessages(completion: @escaping ([ChatMessage]) -> Void) {
////        guard let currentUser = currentUser else {
////            print("No current user")
////            completion([])
////            return
////        }
////
////        let messagesCollection = Firestore.firestore().collection("messages").document(currentUser.id).collection("chats")
////
////        messagesCollection.getDocuments { snapshot, error in
////            guard let snapshot = snapshot else {
////                if let errodxzr = error {
////                    print("Error getting documents: \(error)")
////                } else {
////                    print("Snapshot is nil")
////                }
////                completion([])
////                return
////            }
////
////            var messages: [ChatMessage] = []
////
////            for document in snapshot.documents {
////                let data = document.data()
////                if let messageContent = data["message"] as? String,
////                   let sender = data["user"] as? String {
////                    let message = ChatMessage(sender: sender, content: messageContent)
////                    messages.append(message)
////                } else {
////                    print("Error: Document data is missing or not in the expected format")
////                }
////            }
////
////            DispatchQueue.main.async {
////                completion(messages)
////            }
////        }
////    }
//
//
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
//              Task{
//                  guard let snapshot = try? await Firestore.firestore().collection("users").document(firebaseUser.uid).getDocument() else {return}
//                  
//                  self.currentUser = try? snapshot.data(as: UserData.self)
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
//    
//
// 
//
//    
//}
import SwiftUI
import AuthenticationServices
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: UserData?
    @Published var isSignedIn: Bool = false
//    @Published var communitiesViewModel = CommunitiesViewModel()
    @Published var authErrorMessage: String? // New property for error messages

    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()

    init() {
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            if let user = user {
                self.fetchUserData(userId: user.uid)
            } else {
                self.isSignedIn = false
                self.currentUser = nil
            }
        }
    }

    func fetchUserData(userId: String) {
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
            }
            if let document = document, document.exists {
                do {
                    self.currentUser = try document.data(as: UserData.self)
                    self.isSignedIn = true
                } catch {
                    print("Error decoding user data: \(error.localizedDescription)")
                }
            } else {
                print("User document does not exist")
            }
        }
    }

    func signInWithEmail(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                self.authErrorMessage = "Failed to sign in: \(error.localizedDescription)"
                return
            }
            if let user = result?.user {
                self.fetchUserData(userId: user.uid)
            }
        }
    }


    func signUpWithEmail(email: String, password: String, username: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                self.authErrorMessage = "Failed to sign up: \(error.localizedDescription)"
                return
            }
            if let user = result?.user {
                let userData = UserData(
                    id: user.uid,
                    email: email,
                    username: username,
                    selectedAvatar: "",
                    selectedBackground: "",
                    hasCompletedInitialQuiz: false,
                    hasSetInitialAvatar: false,
                    inventory: [],
                    friends: [user.uid],
                    LevelOneCompleted: false,
                    LevelTwoCompleted: false,
                    selectedWidgets: [],
                    lastCheck: nil,
                    weeklyStatus: [0, 0, 0, 0, 0, 0, 0],
                    hasCompletedTutorial: false,
                    completedLevels: [],
                    completedLevels2: [],
                    dailyCheckInStreak: 0
                )
                do {
                    try self.db.collection("users").document(user.uid).setData(from: userData)
                    self.currentUser = userData
                    self.isSignedIn = true
                } catch {
                    self.authErrorMessage = "Error saving user data: \(error.localizedDescription)"
                }
            }
        }
    }


    func signOut() {
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
            self.userSession = nil
        } catch {
            print("Failed to sign out: \(error.localizedDescription)")
        }
    }

    // Sign In with Apple Functions
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }

    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity token")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                let credential = OAuthProvider.credential(
                    withProviderID: "apple.com",
                    idToken: idTokenString,
                    rawNonce: nil
                )
                Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
                    guard let self = self else { return }
                    if let error = error {
                        print("Apple sign in error: \(error.localizedDescription)")
                        return
                    }
                    if let user = authResult?.user {
                        self.fetchUserDataOrCreateNew(user: user, email: appleIDCredential.email)
                    }
                }
            }
        case .failure(let error):
            print("Authorization failed: \(error.localizedDescription)")
        }
    }

    private func fetchUserDataOrCreateNew(user: User, email: String?) {
        let userRef = db.collection("users").document(user.uid)
        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user data this is numner 1: \(error.localizedDescription)")
                return
            }
            if let document = document, document.exists {
                do {
                    print("trying to decode")
                    self.currentUser = try document.data(as: UserData.self)
                    print("decoded")
                    self.isSignedIn = true
                    print(self.currentUser)

                } catch {
                    print("Error decoding user data this is number 2: \(error.localizedDescription)")
                }
            } else {
                let userData = UserData(
                    id: user.uid,
                    email: user.email ?? "",
                    username: user.email ?? "User",
                    selectedAvatar: "",
                    selectedBackground: "",
                    hasCompletedInitialQuiz: false,
                    hasSetInitialAvatar: false,
                    inventory: [], 
                    friends: [user.uid],
                    LevelOneCompleted: false,
                    LevelTwoCompleted: false,
                    selectedWidgets: [],
                    lastCheck: nil,
                    weeklyStatus: [0,0,0,0,0,0,0],
                    hasCompletedTutorial: false,
                    completedLevels: [],
                    completedLevels2: [],
                    dailyCheckInStreak: 0
                )
                do {
                    try self.db.collection("users").document(user.uid).setData(from: userData)
                    self.currentUser = userData
                    self.isSignedIn = true
                    print(self.currentUser)
                } catch {
                    print("Error saving user data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteAccount() async {
        guard let user = Auth.auth().currentUser else {
            print("DEBUG: No user is currently signed in.")
            return
        }

        do {
            // Delete user data from Firestore first
            let userId = user.uid
            try await Firestore.firestore().collection("users").document(userId).delete()

            // Proceed with deleting the user account
            try await user.delete()
            // Clear any related user data in the app
            DispatchQueue.main.async { [weak self] in
                self?.signOut()
                self?.userSession = nil
                self?.currentUser = nil
            }

            print("User account and data successfully deleted.")
        } catch let error {
            print("DEBUG: Failed to delete account with error \(error.localizedDescription)")
        }
    }

    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        _ = GIDConfiguration(clientID: clientID)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            guard let signInResult = signInResult else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }

            let user = signInResult.user
            let idToken = user.idToken?.tokenString
            let accessToken = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(withIDToken: idToken!, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { [weak self] (_, error) in
                guard let self = self else { return }
                if let error = error {
                    print(error.localizedDescription)
                } else if let user = Auth.auth().currentUser {
                    print("calling the fetch/create")
                    self.fetchUserDataOrCreateNew(user: user, email: user.email)
                }
            }
        }
    }

    // Level Functions
    func markLevelCompleted(levelID: String) async throws {
        guard let currentUserID = currentUser?.id else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUserID)

        // Update the local model first
        if let index = currentUser?.completedLevels.firstIndex(where: { $0 == levelID }) {
            print("Level already marked as completed.")
        } else {
            currentUser?.completedLevels.append(levelID)
        }

        // Synchronize with Firestore
        try await userRef.updateData([
            "completedLevels": FieldValue.arrayUnion([levelID])
        ]) { error in
            if let error = error {
                print("Error updating completed levels: \(error.localizedDescription)")
            } else {
                print("Level marked as completed successfully.")
            }
        }

        // Refresh user data to ensure UI is updated
        await fetchUser()
    }

    func markLevelCompleted2(levelID: String) async throws {
        guard let currentUserID = currentUser?.id else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUserID)

        // Update the local model first
        if let index = currentUser?.completedLevels2.firstIndex(where: { $0 == levelID }) {
            print("Level already marked as completed.")
        } else {
            currentUser?.completedLevels2.append(levelID)
        }

        // Synchronize with Firestore
        try await userRef.updateData([
            "completedLevels2": FieldValue.arrayUnion([levelID])
        ]) { error in
            if let error = error {
                print("Error updating completed levels: \(error.localizedDescription)")
            } else {
                print("Level marked as completed successfully.")
            }
        }

        // Refresh user data to ensure UI is updated
        await fetchUser()
    }

    func saveSelectedWidgets(selected: [String]) async {
        guard let user = currentUser else {
            print("No authenticated user found.")
            return
        }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.id ?? "")

        do {
            try await userRef.setData(["selectedWidgets": selected], merge: true)
            // Update local user data and refresh
            Task {
                await fetchUser()
            }
            print("Widget selection updated successfully.")
        } catch {
            print("Error updating widget selection: \(error)")
        }
    }

    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            self.currentUser = try snapshot.data(as: UserData.self)
            print("Debug current user is \(String(describing: self.currentUser))")
            //communitiesViewModel.loadCommunities()
        } catch {
            print("Error fetching user data: \(error.localizedDescription)")
        }
    }

    func setUserDetails(result_fetch: AuthDataResult) async throws {
        print("Called the setUserDetails func")
        self.userSession = result_fetch.user
        Task {
            await fetchUser()
        }
    }

    func resetPassword(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let err = error {
                print("Error: \(err.localizedDescription)")
            }
        }
    }
    func clearError() {
        self.authErrorMessage = nil
    }
    

    func addFriend(friendId: String) {
        guard let currentUser = currentUser else { return }
        db.collection("users").document(currentUser.id ?? "").updateData([
            "friends": FieldValue.arrayUnion([friendId])
        ]) { error in
            if let error = error {
                print("Error adding friend: \(error.localizedDescription)")
            } else {
                self.fetchUserData(userId: currentUser.id ?? "")
            }
        }
    }
    
    func fetchFriends(completion: @escaping ([UserData]) -> Void) {
        guard let currentUser = currentUser else { return }
        db.collection("users").whereField("id", in: currentUser.friends).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching friends: \(error.localizedDescription)")
                completion([])
            } else {
                let friends = snapshot?.documents.compactMap { try? $0.data(as: UserData.self) } ?? []
                completion(friends)
            }
        }
    }
 


}

// UserData model
//struct UserData: Identifiable, Codable {
//    var id: String
//    var email: String
//    var username: String
//    var selectedAvatar: String
//    var selectedBackground: String
//    var hasCompletedInitialQuiz: Bool
//    var hasSetInitialAvatar: Bool
//    var inventory: [String]
//    var LevelOneCompleted: Bool
//    var LevelTwoCompleted: Bool
//    var selectedWidgets: [String]
//    var lastCheck: Date?
//    var weeklyStatus: [Int]
//    var hasCompletedTutorial: Bool
//    var completedLevels: [String]
//    var completedLevels2: [String]
//    var dailyCheckInStreak: Int
//
//    var initials: String {
//        let formatter = PersonNameComponentsFormatter()
//        if let components = formatter.personNameComponents(from: username) {
//            formatter.style = .abbreviated
//            return formatter.string(from: components)
//        }
//        return ""
//    }
//}
