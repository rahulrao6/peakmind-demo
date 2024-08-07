
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
    @Published var questions: [PPQuestion] = []
    @Published var answers: [PPAnswer] = []
    @Published var ppPlans: [PPPlan] = []

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
                let userData = self.getDefaultUserData(id: user.uid, email: email, username: username)
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
                    var fetchedUserData = try document.data(as: UserData.self)
                    print("decoded")
                    self.currentUser = self.validateAndFixUserData(fetchedUserData)
                    self.isSignedIn = true
                    print(self.currentUser)

                } catch {
                    print("Error decoding user data this is number 2: \(error.localizedDescription)")
                }
            } else {
                let userData = self.getDefaultUserData(id: user.uid, email: email ?? "", username: email ?? "User")
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
    
    func updateBio(newBio: String) {
        guard let userId = currentUser?.id else { return }
        let userRef = db.collection("users").document(userId)
        
        userRef.updateData(["bio": newBio]) { error in
            if let error = error {
                print("Error updating bio: \(error.localizedDescription)")
            } else {
                self.currentUser?.bio = newBio
                print("Bio updated successfully")
            }
        }
    }
    
    func fetchFollowing(completion: @escaping ([UserData]) -> Void) {
        guard let currentUser = currentUser else { return }
        db.collection("users").whereField("id", in: currentUser.friends).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching following: \(error.localizedDescription)")
                completion([])
            } else {
                let following = snapshot?.documents.compactMap { try? $0.data(as: UserData.self) } ?? []
                completion(following)
            }
        }
    }

    func fetchFollowers(completion: @escaping ([UserData]) -> Void) {
        guard let currentUser = currentUser else { return }
        db.collection("users").whereField("friends", arrayContains: currentUser.id ?? "").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching followers: \(error.localizedDescription)")
                completion([])
            } else {
                let followers = snapshot?.documents.compactMap { try? $0.data(as: UserData.self) } ?? []
                completion(followers)
            }
        }
    }

    func validateAndFixUserData(_ userData: UserData) -> UserData {
          var fixedUserData = userData
          let defaultUserData = getDefaultUserData(id: userData.id, email: userData.email, username: userData.username)
          
          if userData.selectedAvatar.isEmpty {
              fixedUserData.selectedAvatar = defaultUserData.selectedAvatar
          }
          if userData.selectedBackground.isEmpty {
              fixedUserData.selectedBackground = defaultUserData.selectedBackground
          }
          if userData.inventory.isEmpty {
              fixedUserData.inventory = defaultUserData.inventory
          }
          if userData.friends.isEmpty {
              fixedUserData.friends = defaultUserData.friends
          }
          if userData.selectedWidgets.isEmpty {
              fixedUserData.selectedWidgets = defaultUserData.selectedWidgets
          }
          if userData.weeklyStatus.isEmpty {
              fixedUserData.weeklyStatus = defaultUserData.weeklyStatus
          }
          if userData.completedLevels.isEmpty {
              fixedUserData.completedLevels = defaultUserData.completedLevels
          }
          if userData.completedLevels2.isEmpty {
              fixedUserData.completedLevels2 = defaultUserData.completedLevels2
          }
          if userData.bio.isEmpty {
              fixedUserData.bio = defaultUserData.bio
          }

          // Update Firestore document if needed
          let userRef = db.collection("users").document(userData.id)
          do {
              try userRef.setData(from: fixedUserData, merge: true)
          } catch {
              print("Error updating user data: \(error.localizedDescription)")
          }
          
          return fixedUserData
      }

      func getDefaultUserData(id: String, email: String, username: String) -> UserData {
          return UserData(
              id: id,
              email: email,
              username: username,
              selectedAvatar: "",
              selectedBackground: "",
              hasCompletedInitialQuiz: false,
              hasSetInitialAvatar: false,
              inventory: [],
              friends: [id],
              LevelOneCompleted: false,
              LevelTwoCompleted: false,
              selectedWidgets: [],
              lastCheck: nil,
              weeklyStatus: [0, 0, 0, 0, 0, 0, 0],
              hasCompletedTutorial: false,
              completedLevels: [],
              completedLevels2: [],
              dailyCheckInStreak: 0,
              bio: ""
          )
      }
    
    func savePersonalizedPlan(plan: PPPlan, answers: [PPAnswer]) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let tasksData = plan.tasks.map { task in
            return [
                "id": task.id,
                "isCompleted": task.isCompleted,
                "name": task.name,
                "rank": task.rank,
                "timeCompleted": task.timeCompleted
            ] as [String : Any]
        }

        let planData: [String: Any] = [
            "userId": userId,
            "planId": "\(plan.id)",
            "planTitle": plan.title,
            "planDescription": plan.description,
            "timestamp": Timestamp(),
            "tasks": tasksData
        ]

        db.collection("new_personalized_plan").document(userId).setData(planData) { error in
            if let error = error {
                print("Error saving personalized plan: \(error.localizedDescription)")
            } else {
                print("Personalized plan saved successfully.")
                //self.saveAnswers(answers: answers)
            }
        }
    }
    
    func fetchPersonalizedPlan(completion: @escaping (Result<PPPlan, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }

        let planRef = db.collection("new_personalized_plan").document(userId)

        planRef.getDocument { document, error in
            if let document = document, document.exists {
                do {
                    if let data = document.data() {
                        let planId = data["planId"] as? String ?? ""
                        let planTitle = data["planTitle"] as? String ?? ""
                        let planDescription = data["planDescription"] as? String ?? ""
                        let tasksData = data["tasks"] as? [[String: Any]] ?? []

                        var tasks: [TaskFirebase] = []
                        for taskData in tasksData {
                            let task = TaskFirebase(
                                id: taskData["id"] as? String ?? "",
                                isCompleted: taskData["isCompleted"] as? Bool ?? false,
                                name: taskData["name"] as? String ?? "",
                                rank: taskData["rank"] as? Int ?? 0,
                                timeCompleted: taskData["timeCompleted"] as? String ?? ""
                            )
                            tasks.append(task)
                        }

                        let plan = PPPlan(
                            title: planTitle,
                            description: planDescription,
                            tasks: tasks
                        )
                        completion(.success(plan))
                    }
                } catch {
                    completion(.failure(error))
                }
            } else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
                }
            }
        }
    }
    
    func fetchQuestions() {
        db.collection("personalized_plan_questions").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching questions: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }

            self.questions = documents.compactMap { doc -> PPQuestion? in
                return try? doc.data(as: PPQuestion.self)
            }
            
            self.initializeAnswers()
        }
    }
    
    private func initializeAnswers() {
        self.answers = self.questions.map { PPAnswer(questionId: $0.id ?? "", type:  $0.type, answer: 0, followUpAnswer: "") }
    }

    func saveAnswers(answers: [PPAnswer]) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let batch = db.batch()
        let answersRef = db.collection("users").document(userId).collection("answers")
        let userDocRef = db.collection("users").document(userId)

        for answer in answers {
            let answerData: [String: Any] = [
                "questionId": answer.questionId,
                "answer": answer.answer,
                "type": answer.type,
                "followUpAnswer": answer.followUpAnswer,
                "timestamp": Timestamp()
            ]
            batch.setData(answerData, forDocument: answersRef.document(answer.id.uuidString))
        }
        
        userDocRef.updateData(["hasCompletedInitialQuiz": true]) { error in
            if let error = error {
                print("Error updating hasCompletedInitialQuiz: \(error.localizedDescription)")
            } else {
                print("hasCompletedInitialQuiz updated successfully.")
            }
        }
        
        batch.commit { error in
            if let error = error {
                print("Error saving answers: \(error.localizedDescription)")
            } else {
                print("Answers saved successfully.")
            }
        }
    }
    
    func fetchPlans(completion: @escaping (Result<[PPPlan], Error>) -> Void) {
            guard let url = URL(string: "http://34.70.2.21:8080/generate_plan") else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }
            
            guard let userId = Auth.auth().currentUser?.uid else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = ["user_id": userId]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    }
                    return
                }
                
                do {
                    let plans = try JSONDecoder().decode([PPPlan].self, from: data)
                    DispatchQueue.main.async {
                        self?.ppPlans = plans
                        completion(.success(plans))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
            
            task.resume()
        }
    
//    func saveQuestions() {
//        let questionsRef = db.collection("personalized_plan_questions")
//
//        for question in ppQuestions {
//            do {
//                try questionsRef.document("\(question.id)").setData(from: question)
//            } catch let error {
//                print("Error writing question to Firestore: \(error)")
//            }
//        }
//    }


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
