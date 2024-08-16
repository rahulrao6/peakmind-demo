
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

//    private func fetchUserDataOrCreateNew(user: User, email: String?) {
//        let userRef = db.collection("users").document(user.uid)
//        userRef.getDocument { document, error in
//            if let error = error {
//                print("Error fetching user data this is numner 1: \(error.localizedDescription)")
//                return
//            }
//            if let document = document, document.exists {
//                do {
//                    print("trying to decode")
//                    var fetchedUserData = try document.data(as: UserData.self)
//                    print("decoded")
//                    self.currentUser = self.validateAndFixUserData(fetchedUserData)
//                    self.isSignedIn = true
//                    print(self.currentUser)
//
//                } catch {
//                    print("Error decoding user data this is number 2: \(error.localizedDescription)")
//                }
//            } else {
//                let userData = self.getDefaultUserData(id: user.uid, email: email ?? "", username: email ?? "User")
//                do {
//                    try self.db.collection("users").document(user.uid).setData(from: userData)
//                    self.currentUser = userData
//                    self.isSignedIn = true
//                    print(self.currentUser)
//                } catch {
//                    print("Error saving user data: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
    private func fetchUserDataOrCreateNew(user: User, email: String?) {
        let userRef = db.collection("users").document(user.uid)
        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }

            guard let document = document else {
                print("Document does not exist")
                return
            }

            if document.exists {
                do {
                    print("Trying to decode")
                    var fetchedUserData = try document.data(as: UserData.self)
                    print("Decoded")
                    fetchedUserData = self.validateAndFixUserData(fetchedUserData)
                    self.currentUser = fetchedUserData
                    self.isSignedIn = true
                    print(self.currentUser ?? "No current user data")
                } catch let decodingError {
                    print("Error decoding user data: \(decodingError.localizedDescription)")
                    print("Document data: \(document.data() ?? [:])") // Log the raw document data

                    // Attempt to fix the document data
                    if let rawData = document.data() {
                        let fixedUserData = self.fixDocumentData(rawData: rawData, userId: user.uid, email: email)
                        self.currentUser = fixedUserData
                        self.isSignedIn = true
                        print(self.currentUser ?? "No current user data")
                        
                        // Save the fixed user data back to Firestore
                        do {
                            try self.db.collection("users").document(user.uid).setData(from: fixedUserData, merge: true)
                        } catch {
                            print("Error saving fixed user data: \(error.localizedDescription)")
                        }
                    }
                }
            } else {
                let userData = self.getDefaultUserData(id: user.uid, email: email ?? "", username: email ?? "User")
                do {
                    try self.db.collection("users").document(user.uid).setData(from: userData)
                    self.currentUser = userData
                    self.isSignedIn = true
                    print(self.currentUser ?? "No current user data")
                } catch {
                    print("Error saving user data: \(error.localizedDescription)")
                }
            }
        }
    }

    private func fixDocumentData(rawData: [String: Any], userId: String, email: String?) -> UserData {
        var fixedUserData: [String: Any] = rawData

        // Ensure all expected fields are present, using defaults if necessary
        if fixedUserData["id"] == nil { fixedUserData["id"] = userId }
        if fixedUserData["email"] == nil { fixedUserData["email"] = email ?? "" }
        if fixedUserData["username"] == nil { fixedUserData["username"] = email ?? "User" }
        if fixedUserData["selectedAvatar"] == nil { fixedUserData["selectedAvatar"] = "" }
        if fixedUserData["selectedBackground"] == nil { fixedUserData["selectedBackground"] = "" }
        if fixedUserData["hasCompletedInitialQuiz"] == nil { fixedUserData["hasCompletedInitialQuiz"] = false }
        if fixedUserData["hasSetInitialAvatar"] == nil { fixedUserData["hasSetInitialAvatar"] = false }
        if fixedUserData["inventory"] == nil { fixedUserData["inventory"] = [] }
        if fixedUserData["friends"] == nil { fixedUserData["friends"] = [userId] }
        if fixedUserData["LevelOneCompleted"] == nil { fixedUserData["LevelOneCompleted"] = false }
        if fixedUserData["LevelTwoCompleted"] == nil { fixedUserData["LevelTwoCompleted"] = false }
        if fixedUserData["selectedWidgets"] == nil { fixedUserData["selectedWidgets"] = [] }
        if fixedUserData["lastCheck"] == nil { fixedUserData["lastCheck"] = nil }
        if fixedUserData["weeklyStatus"] == nil { fixedUserData["weeklyStatus"] = [0, 0, 0, 0, 0, 0, 0] }
        if fixedUserData["hasCompletedTutorial"] == nil { fixedUserData["hasCompletedTutorial"] = false }
        if fixedUserData["completedLevels"] == nil { fixedUserData["completedLevels"] = [] }
        if fixedUserData["completedLevels2"] == nil { fixedUserData["completedLevels2"] = [] }
        if fixedUserData["dailyCheckInStreak"] == nil { fixedUserData["dailyCheckInStreak"] = 0 }
        if fixedUserData["bio"] == nil { fixedUserData["bio"] = "" }
        if fixedUserData["routines"] == nil { fixedUserData["routines"] = [] }

        // Convert the fixed data dictionary back to UserData
        do {
            let fixedData = try JSONSerialization.data(withJSONObject: fixedUserData, options: [])
            let fixedUserData = try JSONDecoder().decode(UserData.self, from: fixedData)
            return fixedUserData
        } catch {
            print("Error converting fixed data to UserData: \(error.localizedDescription)")
            // Return a default UserData object in case of failure
            return getDefaultUserData(id: userId, email: email ?? "", username: email ?? "User")
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
        if !userData.hasCompletedInitialQuiz {
            fixedUserData.hasCompletedInitialQuiz = defaultUserData.hasCompletedInitialQuiz
        }
        if !userData.hasSetInitialAvatar {
            fixedUserData.hasSetInitialAvatar = defaultUserData.hasSetInitialAvatar
        }
        if !userData.LevelOneCompleted {
            fixedUserData.LevelOneCompleted = defaultUserData.LevelOneCompleted
        }
        if !userData.LevelTwoCompleted {
            fixedUserData.LevelTwoCompleted = defaultUserData.LevelTwoCompleted
        }
        if !userData.hasCompletedTutorial {
            fixedUserData.hasCompletedTutorial = defaultUserData.hasCompletedTutorial
        }
        if userData.dailyCheckInStreak == 0 {
            fixedUserData.dailyCheckInStreak = defaultUserData.dailyCheckInStreak
        }
        if userData.lastCheck == nil {
            fixedUserData.lastCheck = defaultUserData.lastCheck
        }
        if userData.routines.isEmpty {
            fixedUserData.routines = defaultUserData.routines
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

//      func getDefaultUserData(id: String, email: String, username: String) -> UserData {
//          return UserData(
//              id: id,
//              email: email,
//              username: username,
//              selectedAvatar: "",
//              selectedBackground: "",
//              hasCompletedInitialQuiz: false,
//              hasSetInitialAvatar: false,
//              inventory: [],
//              friends: [id],
//              LevelOneCompleted: false,
//              LevelTwoCompleted: false,
//              selectedWidgets: [],
//              lastCheck: nil,
//              weeklyStatus: [0, 0, 0, 0, 0, 0, 0],
//              hasCompletedTutorial: false,
//              completedLevels: [],
//              completedLevels2: [],
//              dailyCheckInStreak: 0,
//              bio: ""
//          )
//      }
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
            bio: "", routines: []
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
    
    func saveWidgets(widgets: [CustomWidget]) async {
        guard let userID = currentUser?.id else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)

        do {
            try await userRef.updateData(["selectedWidgets": widgets.map { try Firestore.Encoder().encode($0) }])
            print("Widgets saved successfully.")
        } catch {
            print("Error saving widgets: \(error)")
        }
        
        await fetchWidgets()
    }

    func fetchWidgets() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)

        do {
            let document = try await userRef.getDocument()
            if let data = document.data() {
                let widgetsData = data["selectedWidgets"] as? [[String: Any]] ?? []
                let widgets = try widgetsData.map { try Firestore.Decoder().decode(CustomWidget.self, from: $0) }
                DispatchQueue.main.async {
                    self.currentUser?.selectedWidgets = widgets
                }
                print("Widgets fetched successfully.")
            }
        } catch {
            print("Error fetching widgets: \(error.localizedDescription)")
        }
    }
    

   
    func saveDailyWidgetData(widget: CustomWidget) async throws {
        guard let userId = currentUser?.id else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        // Reference to the document for the specific day
        let dailyDocRef = db.collection("users").document(userId).collection("daily_widget_data").document(dateString)
        
        // Create or update the data for this widget
        let widgetData: [String: Any] = [
            "name": widget.name,
            "value": widget.value
        ]
        
        do {
            // Use merge: true to ensure that the document is updated with the new data
            try await dailyDocRef.setData([widget.id.uuidString: widgetData], merge: true)
            print("Daily widget data saved successfully.")
        } catch {
            print("Error saving daily widget data: \(error.localizedDescription)")
            throw error
        }
    }

    func saveAllDailyWidgetData() async throws {
        guard let userId = currentUser?.id, let widgets = currentUser?.selectedWidgets else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        // Reference to the document for the specific day
        let dailyDocRef = db.collection("users").document(userId).collection("daily_widget_data").document(dateString)
        
        // Prepare all widget data
        var allWidgetData: [String: Any] = [:]
        for widget in widgets {
            let widgetData: [String: Any] = [
                "name": widget.name,
                "value": widget.value
            ]
            allWidgetData[widget.id.uuidString] = widgetData
        }
        
        do {
            // Use merge: true to ensure that the document is updated with the new data
            try await dailyDocRef.setData(allWidgetData, merge: true)
            print("All daily widget data saved successfully.")
        } catch {
            print("Error saving all daily widget data: \(error.localizedDescription)")
            throw error
        }
    }

    func saveDailyWidgetDataLocally(widget: CustomWidget) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())

        // Get the current data for the day from UserDefaults
        var dailyData = UserDefaults.standard.dictionary(forKey: dateString) as? [String: Any] ?? [:]
        
        // Update the specific widget's data
        let widgetData: [String: Any] = [
            "name": widget.name,
            "value": widget.value
        ]
        
        dailyData[widget.id.uuidString] = widgetData
        
        // Save the updated daily data back to UserDefaults
        UserDefaults.standard.set(dailyData, forKey: dateString)
    }

    func saveAllDailyWidgetDataLocally() {
        guard let widgets = currentUser?.selectedWidgets else { return }
        
        for widget in widgets {
            saveDailyWidgetDataLocally(widget: widget)
        }
    }

    func uploadLocalDailyData() async {
        guard let userId = currentUser?.id else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())

        // Retrieve the saved daily data from UserDefaults
        let dailyData = UserDefaults.standard.dictionary(forKey: dateString) as? [String: Any] ?? [:]
        
        if !dailyData.isEmpty {
            let dailyDocRef = db.collection("users").document(userId).collection("daily_widget_data").document(dateString)
            
            do {
                try await dailyDocRef.setData(dailyData, merge: true)
                print("Local daily data uploaded successfully.")
                // Remove the data from UserDefaults after successful upload
                UserDefaults.standard.removeObject(forKey: dateString)
            } catch {
                print("Error uploading local daily data: \(error.localizedDescription)")
            }
        }
    }
     
    
    // MARK: - Routine and Habit Management

    
    func createRoutine(name: String, description: String, habits: [Habits]) async throws {
        guard let currentUserID = currentUser?.id else { throw NSError(domain: "AuthViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current user ID not found"]) }

        var newRoutine = Routine(name: name, description: description, habits: habits)
        newRoutine.habits[0].isUnlocked = true  // Unlock the first habit by default

        // Ensure that the currentUser's routines array exists
        if currentUser?.routines == nil {
            currentUser?.routines = []
        }

        // Append the new routine to the user's routines
        currentUser?.routines.append(newRoutine)

        // Prepare the Firestore document reference
        let userRef = db.collection("users").document(currentUserID)
        
        do {
            // Convert the new routine to a dictionary
            let routineData = try Firestore.Encoder().encode(newRoutine)
            
            // Update the Firestore document
            try await userRef.updateData([
                "routines": FieldValue.arrayUnion([routineData])
            ])
            
            print("Routine created successfully.")
        } catch {
            print("Failed to encode or save routine: \(error.localizedDescription)")
            throw error
        }
    }
    
    func updateRoutine(_ routine: Routine?) async throws {
        guard let routine = routine else { throw NSError(domain: "AuthViewModel", code: 6, userInfo: [NSLocalizedDescriptionKey: "Routine is nil"]) }
        guard let userID = currentUser?.id else { throw NSError(domain: "AuthViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current user ID not found"]) }
        guard var routines = currentUser?.routines else { throw NSError(domain: "AuthViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "No routines found"]) }

        if let index = routines.firstIndex(where: { $0.id == routine.id }) {
            routines[index] = routine
        } else {
            throw NSError(domain: "AuthViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "Routine not found"])
        }

        let userRef = db.collection("users").document(userID)

        do {
            let encodedRoutines = try Firestore.Encoder().encode(routines)
            try await userRef.updateData(["routines": encodedRoutines])
            DispatchQueue.main.async {
                self.currentUser?.routines = routines
            }
        } catch {
            print("Failed to update routine: \(error.localizedDescription)")
            throw error
        }
    }

    func deleteRoutine(_ routine: Routine?) async throws {
        guard let routine = routine else { throw NSError(domain: "AuthViewModel", code: 6, userInfo: [NSLocalizedDescriptionKey: "Routine is nil"]) }
        guard let userID = currentUser?.id else { throw NSError(domain: "AuthViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current user ID not found"]) }
        guard var routines = currentUser?.routines else { throw NSError(domain: "AuthViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "No routines found"]) }

        routines.removeAll(where: { $0.id == routine.id })

        let userRef = db.collection("users").document(userID)
        do {
            let encodedRoutines = try Firestore.Encoder().encode(routines)
            try await userRef.updateData(["routines": encodedRoutines])
            DispatchQueue.main.async {
                self.currentUser?.routines = routines
            }
        } catch {
            print("Failed to delete routine: \(error.localizedDescription)")
            throw error
        }
    }

//    func completeHabit(routineID: String, habitID: String) async throws {
//        guard let currentUserID = currentUser?.id else {
//            throw NSError(domain: "AuthViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current user ID not found"])
//        }
//        guard var routines = currentUser?.routines else {
//            throw NSError(domain: "AuthViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "No routines found"])
//        }
//        guard let routineIndex = routines.firstIndex(where: { $0.id == routineID }) else {
//            throw NSError(domain: "AuthViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "Routine not found"])
//        }
//        guard let habitIndex = routines[routineIndex].habits.firstIndex(where: { $0.id == habitID }) else {
//            throw NSError(domain: "AuthViewModel", code: 3, userInfo: [NSLocalizedDescriptionKey: "Habit not found"])
//        }
//
//        var habit = routines[routineIndex].habits[habitIndex]
//
//        // Check previous habits
//        for otherHabit in routines[routineIndex].habits where otherHabit.isUnlocked && otherHabit.id != habitID {
//            if otherHabit.lastCompletedDate == nil || !Calendar.current.isDateInToday(otherHabit.lastCompletedDate!) {
//                throw NSError(domain: "AuthViewModel", code: 4, userInfo: [NSLocalizedDescriptionKey: "Cannot complete habit, previous unlocked habit not completed."])
//            }
//        }
//
//        let today = Date()
//        if let lastCompleted = habit.lastCompletedDate, Calendar.current.isDateInToday(lastCompleted) {
//            throw NSError(domain: "AuthViewModel", code: 5, userInfo: [NSLocalizedDescriptionKey: "Habit already completed today."])
//        }
//
//        habit.currentStreak += 1
//        habit.lastCompletedDate = today
//
//        routines[routineIndex].habits[habitIndex] = habit
//
//        if habit.currentStreak >= habit.requiredStreak && habitIndex + 1 < routines[routineIndex].habits.count {
//            routines[routineIndex].habits[habitIndex + 1].isUnlocked = true
//        }
//
//        let userRef = db.collection("users").document(currentUserID)
//        do {
//            // Convert routines to a dictionary representation
//            let routinesDicts = routines.map { routine -> [String: Any] in
//                var routineDict: [String: Any] = [
//                    "id": routine.id,
//                    "name": routine.name,
//                    "habits": routine.habits.map { habit -> [String: Any] in
//                        var habitDict: [String: Any] = [
//                            "id": habit.id,
//                            "name": habit.name,
//                            "requiredStreak": habit.requiredStreak,
//                            "currentStreak": habit.currentStreak,
//                            "isUnlocked": habit.isUnlocked
//                        ]
//                        if let lastCompletedDate = habit.lastCompletedDate {
//                            habitDict["lastCompletedDate"] = Timestamp(date: lastCompletedDate)
//                        }
//                        return habitDict
//                    }
//                ]
//                if let description = routine.description {
//                    routineDict["description"] = description
//                }
//                if let targetDate = routine.targetDate {
//                    routineDict["targetDate"] = Timestamp(date: targetDate)
//                }
//                return routineDict
//            }
//            
//            try await userRef.updateData(["routines": routinesDicts])
//            
//            DispatchQueue.main.async {
//                self.currentUser?.routines = routines
//            }
//        } catch {
//            print("Failed to update habit completion: \(error.localizedDescription)")
//            throw error
//        }
//    }
    func completeHabit(routineID: String, habitID: String) async throws {
        guard let currentUserID = currentUser?.id else {
            throw NSError(domain: "AuthViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current user ID not found"])
        }
        guard var routines = currentUser?.routines else {
            throw NSError(domain: "AuthViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "No routines found"])
        }
        guard let routineIndex = routines.firstIndex(where: { $0.id == routineID }) else {
            throw NSError(domain: "AuthViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "Routine not found"])
        }
        guard let habitIndex = routines[routineIndex].habits.firstIndex(where: { $0.id == habitID }) else {
            throw NSError(domain: "AuthViewModel", code: 3, userInfo: [NSLocalizedDescriptionKey: "Habit not found"])
        }

        var habit = routines[routineIndex].habits[habitIndex]

        // Handle different frequency types
        let today = Date()
        let calendar = Calendar.current
        var shouldCompleteHabit = false

        switch habit.frequency {
        case .daily:
            if let lastCompleted = habit.lastCompletedDate, calendar.isDateInToday(lastCompleted) {
                throw NSError(domain: "AuthViewModel", code: 5, userInfo: [NSLocalizedDescriptionKey: "Habit already completed today."])
            }
            shouldCompleteHabit = true
        case .weekly:
            if let lastCompleted = habit.lastCompletedDate, calendar.isDate(today, equalTo: lastCompleted, toGranularity: .weekOfYear) {
                throw NSError(domain: "AuthViewModel", code: 6, userInfo: [NSLocalizedDescriptionKey: "Habit already completed this week."])
            }
            shouldCompleteHabit = true
        }

        if shouldCompleteHabit {
            habit.currentStreak += 1
            habit.lastCompletedDate = today
            routines[routineIndex].habits[habitIndex] = habit

            if habit.currentStreak >= habit.requiredStreak && habitIndex + 1 < routines[routineIndex].habits.count {
                routines[routineIndex].habits[habitIndex + 1].isUnlocked = true
            }

            let userRef = db.collection("users").document(currentUserID)
            do {
                let routinesDicts = try routines.map { try Firestore.Encoder().encode($0) }
                try await userRef.updateData(["routines": routinesDicts])
                DispatchQueue.main.async {
                    self.currentUser?.routines = routines
                }
            } catch {
                print("Failed to update habit completion: \(error.localizedDescription)")
                throw error
            }
        }
    }


//    func checkAndResetStreaks() async throws {
//        guard let currentUserID = currentUser?.id else {
//            throw NSError(domain: "AuthViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current user ID not found"])
//        }
//        
//        guard var routines = currentUser?.routines else {
//            throw NSError(domain: "AuthViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "No routines found"])
//        }
//
//        let today = Date()
//        var hasChanges = false
//
//        for routineIndex in routines.indices {
//            for habitIndex in routines[routineIndex].habits.indices {
//                if let lastCompletedDate = routines[routineIndex].habits[habitIndex].lastCompletedDate,
//                   !Calendar.current.isDateInYesterday(lastCompletedDate) && !Calendar.current.isDateInToday(lastCompletedDate) {
//                    routines[routineIndex].habits[habitIndex].currentStreak = 0
//                    routines[routineIndex].habits[habitIndex].isUnlocked = habitIndex == 0
//                    hasChanges = true
//                }
//            }
//        }
//
//        if hasChanges {
//            let userRef = db.collection("users").document(currentUserID)
//            do {
//                // Convert routines to a dictionary representation
//                let routinesDicts = routines.map { routine -> [String: Any] in
//                    var routineDict: [String: Any] = [
//                        "id": routine.id,
//                        "name": routine.name,
//                        "habits": routine.habits.map { habit -> [String: Any] in
//                            var habitDict: [String: Any] = [
//                                "id": habit.id,
//                                "name": habit.name,
//                                "requiredStreak": habit.requiredStreak,
//                                "currentStreak": habit.currentStreak,
//                                "isUnlocked": habit.isUnlocked
//                            ]
//                            if let lastCompletedDate = habit.lastCompletedDate {
//                                habitDict["lastCompletedDate"] = Timestamp(date: lastCompletedDate)
//                            }
//                            return habitDict
//                        }
//                    ]
//                    if let description = routine.description {
//                        routineDict["description"] = description
//                    }
//                    if let targetDate = routine.targetDate {
//                        routineDict["targetDate"] = Timestamp(date: targetDate)
//                    }
//                    return routineDict
//                }
//                
//                try await userRef.updateData(["routines": routinesDicts])
//                
//                DispatchQueue.main.async {
//                    self.currentUser?.routines = routines
//                }
//            } catch {
//                print("Failed to update streaks: \(error.localizedDescription)")
//                throw error
//            }
//        }
//    }
    
    func checkAndResetStreaks() async throws {
        guard let currentUserID = currentUser?.id else {
            throw NSError(domain: "AuthViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current user ID not found"])
        }

        guard var routines = currentUser?.routines else {
            throw NSError(domain: "AuthViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "No routines found"])
        }

        let today = Date()
        let calendar = Calendar.current
        var hasChanges = false

        for routineIndex in routines.indices {
            for habitIndex in routines[routineIndex].habits.indices {
                let habit = routines[routineIndex].habits[habitIndex]
                if let lastCompletedDate = habit.lastCompletedDate {
                    switch habit.frequency {
                    case .daily:
                        if !calendar.isDateInYesterday(lastCompletedDate) && !calendar.isDateInToday(lastCompletedDate) {
                            routines[routineIndex].habits[habitIndex].currentStreak = 0
                            routines[routineIndex].habits[habitIndex].isUnlocked = habitIndex == 0
                            hasChanges = true
                        }
                    case .weekly:
                        if !calendar.isDate(today, equalTo: lastCompletedDate, toGranularity: .weekOfYear) {
                            routines[routineIndex].habits[habitIndex].currentStreak = 0
                            routines[routineIndex].habits[habitIndex].isUnlocked = habitIndex == 0
                            hasChanges = true
                        }
                    }
                }
            }
        }

        if hasChanges {
            let userRef = db.collection("users").document(currentUserID)
            do {
                let routinesDicts = try routines.map { try Firestore.Encoder().encode($0) }
                try await userRef.updateData(["routines": routinesDicts])
                DispatchQueue.main.async {
                    self.currentUser?.routines = routines
                }
            } catch {
                print("Failed to update streaks: \(error.localizedDescription)")
                throw error
            }
        }
    }

    
    func isHabitCompletedToday(_ habit: Habits) -> Bool {
         guard let lastCompletedDate = habit.lastCompletedDate else {
             return false
         }
         return Calendar.current.isDateInToday(lastCompletedDate)
     }
    
    func scheduleNotificationForNewTracker(widgetName: String) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Don't forget to log your daily status for \(widgetName)."
        content.body = "Remember to check in on your \(widgetName) tracker today."
        content.sound = .default
        var dateComponents = DateComponents()
        dateComponents.hour = 18    // Set the hour (24-hour format)
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for new tracker: \(widgetName)")
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
