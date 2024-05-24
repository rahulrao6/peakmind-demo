//
//  AuthViewModel.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 2/17/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import Foundation
import FirebaseAuth
import GoogleSignIn
import Firebase

protocol AuthenticationFormProtocol {
    var formIsValid: Bool {get}
}

@MainActor
class AuthViewModel : ObservableObject {
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser : UserData?
    //static let share = GoogleAuthenticationStruct()
    @Published var authErrorMessage: String? // New property for error messages

    
    init() {
        
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            Task{
                await fetchUser()
            }
        } catch {
            self.authErrorMessage = "Failed to log in: \(error.localizedDescription)"
        }
    }
    
    
    func createUser(withEmail email: String, password: String, username: String, selectedAvatar: String, selectedBackground: String, hasCompletedInitialQuiz: Bool, hasSetInitialAvatar: Bool, LevelOneCompleted: Bool, LevelTwoCompleted: Bool) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = UserData(id: result.user.uid, email: email, username: username, selectedAvatar: selectedAvatar, selectedBackground: selectedBackground, hasCompletedInitialQuiz: hasCompletedInitialQuiz, hasSetInitialAvatar: hasSetInitialAvatar, inventory: [], LevelOneCompleted: LevelOneCompleted, LevelTwoCompleted: LevelTwoCompleted, selectedWidgets: [], lastCheck: nil, weeklyStatus: [0,0,0,0,0,0,0], hasCompletedTutorial: false, completedLevels: [], completedLevels2: [], dailyCheckInStreak: 0)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
            
        } catch {
            self.authErrorMessage = "Failed to create user: \(error.localizedDescription)"
            throw error

        }
    }
    
//    func createUser2(withEmail email: String, password: String, username: String, avatar: String, background: String) async {
//        do {
//            let result = try await Auth.auth().createUser(withEmail: email, password: password)
//            self.userSession = result.user
//            let newUser = UserData(id: result.user.uid, email: email, username: username, selectedAvatar: avatar, selectedBackground: background, hasCompletedInitialQuiz: false, hasSetInitialAvatar: false, inventory: [], LevelOneCompleted: false, LevelTwoCompleted: false)
//            let encodedUser = try Firestore.Encoder().encode(newUser)
//            try await Firestore.firestore().collection("users").document(newUser.id).setData(encodedUser)
//            self.currentUser = newUser
//        } catch {
//            print("Debug failed to create user \(error.localizedDescription)")
//        }
//    }
    
    func signOut() {
        
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            self.authErrorMessage = "Failed to sign out: \(error.localizedDescription)"
        }
        
    }
    
    func clearError() {
        self.authErrorMessage = nil
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
            signOut()
            // Clear any related user data in the app
            DispatchQueue.main.async { [weak self] in
                self?.userSession = nil
                self?.currentUser = nil
            }
            
            print("User account and data successfully deleted.")
        } catch let error {
            print("DEBUG: Failed to delete account with error \(error.localizedDescription)")
        }
    }


    func markLevelCompleted(levelID: String) async throws {
        guard let currentUserID = userSession?.uid else {
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
        guard let currentUserID = userSession?.uid else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUserID)

        // Update the local model first
        if let index = currentUser?.completedLevels.firstIndex(where: { $0 == levelID }) {
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


    
    func resetPassword(email : String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let err = error {
                print("Error: \(err.localizedDescription)")
            }
        }
    }
    
    func saveSelectedWidgets(selected: [String]) async {
        guard let user = currentUser else {
            print("No authenticated user found.")
            return
        }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.id)
        
        do {
            try await userRef.setData(["selectedWidgets": selected], merge: true)
            // Update local user data and refresh
            Task{
                await fetchUser()

            }
            print("Widget selection updated successfully.")
        } catch {
            print("Error updating widget selection: \(error)")
        }
    }

    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else {return}
    
        self.currentUser = try? snapshot.data(as: UserData.self)
        
        print("Debug current user is \(String(describing: self.currentUser))")
        
        
    }
    
    
    func setUserDetails(result_fetch: AuthDataResult) async throws {
        print("called the setUserDetails func")
        self.userSession = result_fetch.user
        Task{
            await fetchUser()
        }
    }
    
//    func fetchMessages(completion: @escaping ([ChatMessage]) -> Void) {
//        guard let currentUser = currentUser else {
//            print("No current user")
//            completion([])
//            return
//        }
//
//        let messagesCollection = Firestore.firestore().collection("messages").document(currentUser.id).collection("chats")
//
//        messagesCollection.getDocuments { snapshot, error in
//            guard let snapshot = snapshot else {
//                if let errodxzr = error {
//                    print("Error getting documents: \(error)")
//                } else {
//                    print("Snapshot is nil")
//                }
//                completion([])
//                return
//            }
//
//            var messages: [ChatMessage] = []
//
//            for document in snapshot.documents {
//                let data = document.data()
//                if let messageContent = data["message"] as? String,
//                   let sender = data["user"] as? String {
//                    let message = ChatMessage(sender: sender, content: messageContent)
//                    messages.append(message)
//                } else {
//                    print("Error: Document data is missing or not in the expected format")
//                }
//            }
//
//            DispatchQueue.main.async {
//                completion(messages)
//            }
//        }
//    }


    
    func signinWithGoogle() async -> Bool  {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
          fatalError("No client ID found in Firebase configuration")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
          print("There is no root view controller!")
          return false
        }

          do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

            let user = userAuthentication.user
              guard let idToken = user.idToken else { throw fatalError("ID token missing") }
            let accessToken = user.accessToken

            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                           accessToken: accessToken.tokenString)

            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
            print("User \(firebaseUser.uid) signed in with email \(firebaseUser.email ?? "unknown")")
              self.userSession = result.user
              Task{
                  guard let snapshot = try? await Firestore.firestore().collection("users").document(firebaseUser.uid).getDocument() else {return}
                  
                  self.currentUser = try? snapshot.data(as: UserData.self)
                  
                  print("Debug current user is \(String(describing: self.currentUser))")
              }
            return true
          }
          catch {
            print(error.localizedDescription)
            return false
          }


    }
 

    
}
