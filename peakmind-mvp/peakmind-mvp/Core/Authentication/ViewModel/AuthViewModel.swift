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

protocol AuthenticationFormProtocol {
    var formIsValid: Bool {get}
}

@MainActor
class AuthViewModel : ObservableObject {
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser : User?
    
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
    
    func createUser(withEmail email: String, password: String, fullname: String, location: String, color: String, firstPeak: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email, location: location, color: color, firstPeak: firstPeak)
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
    
}
