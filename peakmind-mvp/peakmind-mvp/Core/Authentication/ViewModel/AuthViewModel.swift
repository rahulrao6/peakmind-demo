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
    @Published var currentUser : User?
    //static let share = GoogleAuthenticationStruct()

    
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
            print("Debug: failed to log in with error \(error.localizedDescription)")
        }
    }
    
    
    func createUser(withEmail email: String, password: String, fullname: String, location: String, color: String, firstPeak: String, username: String, selectedAvatar: String, selectedBackground: String, hasCompletedInitialQuiz: Bool) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email, location: location, color: color, firstPeak: firstPeak, username: username, selectedAvatar: selectedAvatar, selectedBackground: selectedBackground, hasCompletedInitialQuiz: hasCompletedInitialQuiz)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
            
        } catch {
            print("Debug failed to create user \(error.localizedDescription)")
            
        }
    }
    
    func signOut() {
        
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
        
    }
    
    func deleteAccount() {
        let user = Auth.auth().currentUser

        user?.delete { error in
            if let error = error {
                print("DEBUG: Failed to delete account with error \(error.localizedDescription)")
                return
            }
            
            // User deletion successful, now delete document from Firestore
            if let userId = self.currentUser?.id {
                Firestore.firestore().collection("users").document(userId).delete { error in
                    if let error = error {
                        print("Error removing document: \(error)")
                        return
                    }
                    print("Document successfully removed!")
                    
                    // Reset user session and current user
                    self.userSession = nil
                    self.currentUser = nil
                }
            } else {
                print("Error: User ID is nil")
            }
        }
    }


    
    func resetPassword(email : String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let err = error {
                print("Error: \(err.localizedDescription)")
            }
        }
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else {return}
    
        self.currentUser = try? snapshot.data(as: User.self)
        
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
                  
                  self.currentUser = try? snapshot.data(as: User.self)
                  
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
