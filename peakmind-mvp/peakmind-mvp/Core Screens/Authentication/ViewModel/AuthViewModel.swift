
import SwiftUI
import AuthenticationServices
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import Pendo

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
    @Published var totalPoints: Int = 0
    @Published var pointsHistory: [PointEntry] = []
    @Published var currentLevel: Int = 0
    @Published var badges: [Badge] = []
    @Published var quests: [Quest] = []
    @Published  var journalEntries: [JournalEntry] = []
    @Published var habitsByName: [String: [Habit]] = [:]
    
    
    //    @Published var communitiesViewModel = CommunitiesViewModel()
    @Published var authErrorMessage: String? // New property for error messages
    private let healthKitManager = HealthKitManager()
    private let EventKitManager1 = EventKitManager()
    
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private var listenerRegistration2: ListenerRegistration?
    
    
    init() {
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            if let user = user {
                self.fetchUserData(userId: user.uid)
                self.healthKitManager.requestAuthorization()
                
                
                Task {
                    //let _ = await self.EventKitManager1.requestAccess(to: .event)
                    let _ = await self.EventKitManager1.requestAccess(to: .reminder)
                    
                }
                self.healthKitManager.fetchHealthData(for: user.uid, numberOfDays: 7)
            } else {
                self.isSignedIn = false
                self.currentUser = nil
            }
        }
    }
    
    func startPendoSession(user: UserData?, userId: String) {
        guard let user = user else { return }
        
        // Prepare visitorData and accountData for Pendo
        let visitorData: [String: AnyHashable] = [
            "name": user.username,
            "email": user.email,
            "bio": user.bio
        ]
        
        let accountData: [String: AnyHashable] = [
            "email": user.email,
            "lastCheckIn": user.lastCheck
        ]
        
        // Start a Pendo session
        PendoManager.shared().startSession(userId, accountId: userId, visitorData: visitorData, accountData: accountData)
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
                    self.startPendoSession(user: self.currentUser, userId: userId)
                    
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
                self.healthKitManager.requestAuthorization()
                self.healthKitManager.fetchHealthData(for: user.uid, numberOfDays: 7)
            }
        }
    }
    
    func saveGameData(phase: Int, level: Int, data: String) {
        guard let userId = currentUser?.id else { return }
        
        
        let db = Firestore.firestore()
        
        // Construct the reference to the document where data will be saved
        let dataRef = db.collection("gameData")
            .document(userId)
            .collection("phases")
            .document(String(phase))
            .collection("levels")
            .document(String(level))
        
        // Data to be saved
        let dataToSave: [String: Any] = [
            "data": data,
            "timestamp": Timestamp(date: Date()) // Optional: Add a timestamp
        ]
        
        // Save the data
        dataRef.setData(dataToSave) { error in
            if let error = error {
                print("Error saving game data: \(error.localizedDescription)")
            } else {
                print("Game data saved successfully for phase \(phase), level \(level).")
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
                    self.healthKitManager.requestAuthorization()
                    self.healthKitManager.fetchHealthData(for: user.uid, numberOfDays: 7)
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
    
    func saveToGAD7(totalScore: Int, answers: [Int]) async throws {
        guard let userId = currentUser?.id else { return }
        
        let db = Firestore.firestore()
        let gad7Data: [String: Any] = [
            "score": totalScore,
            "answers": answers,
            "date": Timestamp(date: Date())
        ]
        
        db.collection("users").document(userId).collection("profiles").document("GAD7").setData(gad7Data) { error in
            if let error = error {
                print("Error saving GAD-7 data: \(error)")
            }
        }
    }
    
    func saveToPHQ9(totalScore: Int, answers: [Int]) async throws {
        guard let userId = currentUser?.id else { return }
        
        let db = Firestore.firestore()
        let phq9Data: [String: Any] = [
            "score": totalScore,
            "answers": answers,
            "date": Timestamp(date: Date())
        ]
        print("savetophq");
        db.collection("users").document(userId).collection("profiles").document("PHQ9").setData(phq9Data) { error in
            if let error = error {
                print("Error saving phq9Data: \(error)")
            }
        }
    }
    
    func saveToNMRQ(totalScore: Int, answers: [Int]) async throws {
        guard let userId = currentUser?.id else { return }
        
        let db = Firestore.firestore()
        let NMRQdata: [String: Any] = [
            "score": totalScore,
            "answers": answers,
            "date": Timestamp(date: Date())
        ]
        
        db.collection("users").document(userId).collection("profiles").document("NMRQ").setData(NMRQdata) { error in
            if let error = error {
                print("Error saving NMRQdata: \(error)")
            }
        }
    }
    
    func saveToPSS(totalScore: Int, answers: [Int]) async throws {
        guard let userId = currentUser?.id else { return }
        
        let db = Firestore.firestore()
        let PSSdata: [String: Any] = [
            "score": totalScore,
            "answers": answers,
            "date": Timestamp(date: Date())
        ]
        
        db.collection("users").document(userId).collection("profiles").document("PSS").setData(PSSdata) { error in
            if let error = error {
                print("Error saving PSS data: \(error)")
            }
        }
    }
    
    // MARK: - Gamification Functions
    
    
    // Log each step
    // Predefined list of all possible badges
    let allBadges = [
        Badge(id: "1", name: "Bronze Badge", description: "Achieve 1000 points", imageURL: "bronzeBadge", dateEarned: nil, pointsRequired: 1000, levelRequired: 1),
        Badge(id: "2", name: "Silver Badge", description: "Achieve 2000 points", imageURL: "silverBadge", dateEarned: nil, pointsRequired: 2000, levelRequired: 2),
        Badge(id: "3", name: "Gold Badge", description: "Achieve 3000 points", imageURL: "goldBadge", dateEarned: nil, pointsRequired: 3000, levelRequired: 3),
        Badge(id: "4", name: "Diamond Badge", description: "Achieve 4000 points", imageURL: "diamondBadge", dateEarned: nil, pointsRequired: 4000, levelRequired: 4)
    ]
    
    // Log each step
    private func log(_ message: String) {
        print("[AuthViewModel] \(message)")
    }
    
    // Award points to user
    func awardPoints(_ points: Int, reason: String) async throws {
        log("Starting to award points")
        guard let userId = currentUser?.id else {
            log("Current user ID not found")
            throw NSError(domain: "AuthViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current user ID not found"])
        }
        
        let userRef = db.collection("points").document(userId)
        let pointEntry = PointEntry(
            id: UUID().uuidString,
            userId: userId,
            date: Date(),
            points: points,
            reason: reason
        )
        
        do {
            // Create an encoder and set the date encoding strategy
            let encoder = Firestore.Encoder()
            encoder.dateEncodingStrategy = .timestamp
            let encodedPointEntry = try encoder.encode(pointEntry)
            
            // Check if the document exists
            let document = try await userRef.getDocument()
            if document.exists {
                // Document exists, update data
                log("Document exists, updating data")
                try await userRef.updateData([
                    "points": FieldValue.arrayUnion([encodedPointEntry]),
                    "totalPoints": FieldValue.increment(Int64(points))
                ])
            } else {
                // Document does not exist, create it with initial data
                log("Document does not exist, creating with initial data")
                try await userRef.setData([
                    "points": [encodedPointEntry],
                    "totalPoints": points
                ])
            }
            
            // Update local data
            log("Updating local total points")
            DispatchQueue.main.async {
                self.totalPoints += points
            }
            
            // Check for level up
            log("Checking for level up")
            try await checkForLevelUp()
        } catch {
            log("Failed to award points: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Check and handle level up
    private func checkForLevelUp() async throws {
        log("Checking for level up")
        guard let userId = currentUser?.id else {
            log("Current user data not found")
            throw NSError(domain: "AuthViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current user data not found"])
        }
        
        let newLevel = calculateLevel(totalPoints)
        
        if newLevel > currentLevel {
            log("Updating user level to \(newLevel)")
            let userRef = db.collection("users").document(userId)
            do {
                try await userRef.updateData([
                    "currentLevel": newLevel
                ])
                
                // Update local data
                DispatchQueue.main.async {
                    self.currentLevel = newLevel
                }
                
                // Award level-up badge
                if let levelBadge = allBadges.first(where: { $0.levelRequired == newLevel }) {
                    try await awardBadge(badge: levelBadge)
                }
            } catch {
                log("Failed to update level: \(error.localizedDescription)")
                throw error
            }
        }
    }
    
    // Calculate user level based on points
    private func calculateLevel(_ points: Int) -> Int {
        return points / 1000 + 1
    }
    
    // Award badge to user
    func awardBadge(badge: Badge) async throws {
        log("Attempting to award badge: \(badge.name)")
        guard let userId = currentUser?.id else {
            log("Current user ID not found")
            throw NSError(domain: "AuthViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current user ID not found"])
        }
        let userRef = db.collection("badges").document(userId)
        
        var badgeToAward = badge
        badgeToAward.dateEarned = Date()
        
        do {
            // Fetch current badges
            let document = try await userRef.getDocument()
            var currentBadges = [Badge]()
            if let data = document.data(), let badgesDict = data["badges"] as? [String: [String: Any]] {
                let decoder = Firestore.Decoder()
                decoder.dateDecodingStrategy = .timestamp
                currentBadges = try badgesDict.values.map { dict in
                    return try decoder.decode(Badge.self, from: dict)
                }
            }
            
            // Check if badge is already in currentBadges
            if currentBadges.contains(where: { $0.id == badge.id }) {
                log("Badge already awarded: \(badge.name)")
                return
            }
            
            // Add the badge
            log("Awarding badge: \(badge.name)")
            let encoder = Firestore.Encoder()
            encoder.dateEncodingStrategy = .timestamp
            let encodedBadge = try encoder.encode(badgeToAward)
            
            // Update Firestore
            try await userRef.setData([
                "badges.\(badge.id)": encodedBadge
            ], merge: true)
            
        } catch {
            log("Failed to award badge: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Check and award any new badges the user has earned
    func checkAndAwardBadges(totalPoints: Int, currentLevel: Int, earnedBadges: [Badge]) async throws {
        for badge in allBadges {
            // Check if user meets requirements
            if totalPoints >= badge.pointsRequired && currentLevel >= badge.levelRequired {
                // Check if user already has this badge
                if !earnedBadges.contains(where: { $0.id == badge.id }) {
                    // Award the badge
                    try await awardBadge(badge: badge)
                }
            }
        }
    }
    
    // Fetch points data for user
    func getPointsData() async throws -> (pointsHistory: [PointEntry], totalPoints: Int) {
        log("Fetching points data")
        guard let userId = currentUser?.id else {
            log("Current user ID not found")
            throw NSError(domain: "AuthViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current user ID not found"])
        }
        
        let pointsRef = db.collection("points").document(userId)
        
        do {
            let document = try await pointsRef.getDocument()
            if let data = document.data() {
                let totalPoints = data["totalPoints"] as? Int ?? 0
                if let pointsArray = data["points"] as? [[String: Any]] {
                    let decoder = Firestore.Decoder()
                    decoder.dateDecodingStrategy = .timestamp
                    let pointsHistory = try pointsArray.map { dict in
                        return try decoder.decode(PointEntry.self, from: dict)
                    }
                    DispatchQueue.main.async {
                        self.totalPoints = totalPoints
                    }
                    return (pointsHistory: pointsHistory, totalPoints: totalPoints)
                }
            }
            return (pointsHistory: [], totalPoints: 0)
        } catch {
            log("Failed to get points data: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Fetch current level for user
    func getCurrentLevel() async throws -> Int {
        log("Fetching current level")
        guard let userId = currentUser?.id else {
            log("Current user ID not found")
            throw NSError(domain: "AuthViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current user ID not found"])
        }
        
        let userRef = db.collection("users").document(userId)
        
        do {
            let document = try await userRef.getDocument()
            if let data = document.data() {
                let currentLevel = data["currentLevel"] as? Int ?? 1
                DispatchQueue.main.async {
                    self.currentLevel = currentLevel
                }
                return currentLevel
            }
            return 1
        } catch {
            log("Failed to get current level: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Fetch badges for user
    func getBadges() async throws -> [Badge] {
        log("Fetching badges")
        guard let userId = currentUser?.id else {
            log("Current user ID not found")
            throw NSError(domain: "AuthViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current user ID not found"])
        }
        
        let badgesRef = db.collection("badges").document(userId)
        
        do {
            let document = try await badgesRef.getDocument()
            if let data = document.data(), let badgesDict = data["badges"] as? [String: [String: Any]] {
                let decoder = Firestore.Decoder()
                decoder.dateDecodingStrategy = .timestamp
                let badges = try badgesDict.values.map { dict in
                    return try decoder.decode(Badge.self, from: dict)
                }
                return badges
            }
            return []
        } catch {
            log("Failed to get badges: \(error.localizedDescription)")
            throw error
        }
    }
    
    func saveJournalEntry(entry: JournalEntry) async throws {
        guard let currentUserID = currentUser?.id else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])
        }
        print("savingjournal")
        
        let db = Firestore.firestore()
        let userRef = db.collection("journal").document(currentUserID)
        let journalRef = userRef.collection("journalEntries").document()
        
        // Convert the journal entry to a dictionary for Firestore
        let data: [String: Any] = [
            "id": journalRef.documentID,
            "question": entry.question,
            "answer": entry.answer,
            "date": Timestamp(date: entry.date)
        ]
        print("savingjournal2")
        
        
        // Save the journal entry to Firestore
        try await journalRef.setData(data)
    }
    
    func fetchJournalEntries(completion: @escaping ([JournalEntry]) -> Void) {
        guard let currentUserID = currentUser?.id else { return }
        
        let db = Firestore.firestore()
        let userRef = db.collection("journal").document(currentUserID)
        let journalCollection = userRef.collection("journalEntries")
        
        // Fetch documents ordered by the date field in descending order
        journalCollection.order(by: "date", descending: true).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching journal entries: \(error.localizedDescription)")
                completion([])
            } else {
                var entries: [JournalEntry] = []
                for document in snapshot!.documents {
                    let data = document.data()
                    if let question = data["question"] as? String,
                       let answer = data["answer"] as? String,
                       let date = (data["date"] as? Timestamp)?.dateValue() {
                        let entry = JournalEntry(id: document.documentID, question: question, answer: answer, date: date)
                        entries.append(entry)
                    }
                }
                completion(entries)
            }
        }
    }
    
    func fetchJournalEntries2() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        
        listenerRegistration2 = db.collection("journal")
            .document(currentUserID)
            .collection("journalEntries")
            .order(by: "date", descending: true) // Sort by date descending
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("Error fetching journal entries: \(error.localizedDescription)")
                    return
                }
                
                self?.journalEntries = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: JournalEntry.self)
                } ?? []
            }
    }
    
    func updateJournalEntry(entry: JournalEntry) async throws {
        guard let currentUserID = currentUser?.id else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])
        }
        
        guard let entryID = entry.id else {
            throw NSError(domain: "UpdateError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Journal entry ID is missing."])
        }
        
        let db = Firestore.firestore()
        let journalEntryRef = db.collection("journal").document(currentUserID).collection("journalEntries").document(entryID)
        
        // Log Firestore path for debugging
        print("Updating journal entry at path: users/\(currentUserID)/journalEntries/\(entryID)")
        
        // Prepare the updated data
        let updatedData: [String: Any] = [
            "question": entry.question,
            "answer": entry.answer,
            "date": Timestamp(date: entry.date) // Ensure date is in Firestore format
        ]
        
        // Attempt to update Firestore
        do {
            print("Updated Data: \(updatedData)")
            try await journalEntryRef.setData(updatedData, merge: true) // Use merge to update fields without overwriting the entire document
            print("Journal entry updated in Firestore.")
        } catch {
            print("Failed to update Firestore document: \(error.localizedDescription)")
            throw error
        }
    }
    
    func checkIfPromptAnswered(completion: @escaping (Bool) -> Void) {
        guard let currentUserID = currentUser?.id else { return }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUserID)
        
        userRef.getDocument { document, error in
            if let error = error {
                print("Error checking prompt answered: \(error)")
                completion(false)
                return
            }
            
            if let data = document?.data(), let lastPromptAnsweredDate = data["lastPromptAnsweredDate"] as? Timestamp {
                let lastDate = lastPromptAnsweredDate.dateValue()
                let calendar = Calendar.current
                if calendar.isDateInToday(lastDate) {
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
    
    func fetchQuestData() {
        guard let userId = currentUser?.id else { return }
        
        
        listenerRegistration = db.collection("quests").document(userId).collection("userQuests")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error fetching quests: \(error)")
                    return
                }
                
                self.quests = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Quest.self)
                } ?? []
                // Only add new quests that are not already in the array
                for quests in self.quests {
                    if !self.quests.contains(where: { $0.id == quests.id }) {
                        self.quests.append(quests)
                    }
                }
                
                
                
                // If no quests exist, create default ones
                if self.quests.isEmpty {
                    self.createDefaultQuests()
                }
            }
    }
    
    func createDefaultQuests() {
        guard let userId = currentUser?.id else { return }
        
        let defaultQuests = [
            Quest(baseName: "Profiles", currentProgress: 0, nextSegmentGoal: 1, totalSegments: [1, 3, 10, 20, 40]),
            Quest(baseName: "Games", currentProgress: 0, nextSegmentGoal: 5, totalSegments: [5, 25, 50, 150, 400]),
            Quest(baseName: "Journal", currentProgress: 0, nextSegmentGoal: 10, totalSegments: [10, 30, 60, 100, 250]),
            Quest(baseName: "Chat", currentProgress: 0, nextSegmentGoal: 3, totalSegments: [3, 10, 20, 40, 100]),
            Quest(baseName: "Habits", currentProgress: 0, nextSegmentGoal: 5, totalSegments: [5, 20, 50, 100, 250]),
            Quest(baseName: "Routine", currentProgress: 0, nextSegmentGoal: 1, totalSegments: [1, 3, 5, 10, 20])
        ]
        
        for var quest in defaultQuests {
            do {
                let _ = try db.collection("quests").document(userId).collection("userQuests").addDocument(from: quest)
            } catch {
                print("Error adding default quest: \(error)")
            }
        }
    }
    
    func saveQuest(_ quest: Quest) {
        guard let questId = quest.id else {
            return
        }
        guard let userId = currentUser?.id else { return }
        
        print("saving quests now")
        print(quest)
        do {
            try db.collection("quests").document(userId).collection("userQuests").document(questId).setData(from: quest)
        } catch {
            print("Error saving quest: \(error)")
        }
    }
    
    func incrementProgress(for questId: String) {
        if let index = quests.firstIndex(where: { $0.id == questId }) {
            quests[index].incrementProgress()
            saveQuest(quests[index])
        }
    }
    
    func claimReward(for questId: String) {
        if let index = quests.firstIndex(where: { $0.id == questId }) {
            quests[index].claimReward()
            saveQuest(quests[index])
        }
        
        Task {
            try await awardPoints(150, reason: "Completed quest")
        }
        fetchQuestData()
        checkAndSyncQuests()
    }
    
    func removeListener() {
        listenerRegistration?.remove()
    }
    func removeListener2() {
        listenerRegistration2?.remove()
    }
    
    // Central function to check and sync quests
    func checkAndSyncQuests() {
        for index in quests.indices {
            let quest = quests[index]
            
            switch quest.baseName {
            case "Journal":
                checkJournalProgress(for: quest) { updatedQuest in
                    //self.quests[index] = updatedQuest
                    self.saveQuest(updatedQuest)
                }
            case "Profiles":
                // Add the check for profiles here
                checkProfileProgress(for: quest) { updatedQuest in
                    self.quests[index] = updatedQuest
                    self.saveQuest(updatedQuest)
                }
            case "Games":
                // Add the check for games here
                checkGameProgress(for: quest) { updatedQuest in
                    //self.quests[index] = updatedQuest
                    self.saveQuest(updatedQuest)
                }
                
            case "Chat":
                // Add the check for games here
                checkChatProgress(for: quest) { updatedQuest in
                    //self.quests[index] = updatedQuest
                    self.saveQuest(updatedQuest)
                    
                }
            case "Habits":
                // Add the check for games here
                checkHabitProgress(for: quest) { updatedQuest in
                    self.quests[index] = updatedQuest
                    self.saveQuest(updatedQuest)
                    
                }
            case "DailyCheckin":
                print("Processing DailyCheckin quest")  // Debugging
                checkDailyCheckinProgress(for: quest) { updatedQuest in
                    self.saveQuest(updatedQuest)
                    
                }
                //case "RoutineCompletion":
                //         checkRoutineCompletionProgress(for: quest) { updatedQuest in
                //           self.saveQuest(updatedQuest)
                //     }
            default:
                break
            }
        }
    }
    
    
    func checkJournalProgress(for quest: Quest, completion: @escaping (Quest) -> Void) {
        fetchJournalEntries { entries in
            var updatedQuest = quest
            let journalEntryCount = entries.count
            
            // Update current progress to match the number of journal entries
            updatedQuest.currentProgress = journalEntryCount
            
            // We need to ensure that the nextSegmentGoal does not move backward
            // Find the next uncompleted segment goal
            if journalEntryCount >= updatedQuest.nextSegmentGoal {
                // Move to the next segment goal (if available)
                if let nextGoalIndex = quest.totalSegments.firstIndex(of: updatedQuest.nextSegmentGoal),
                   nextGoalIndex + 1 < quest.totalSegments.count {
                    updatedQuest.nextSegmentGoal = quest.totalSegments[nextGoalIndex + 1]
                }
            }
            
            // Pass the updated quest back via the completion handler
            completion(updatedQuest)
        }
    }
    func checkHabitProgress(for quest: Quest, completion: @escaping (Quest) -> Void) {
        fetchCompletedHabitsCount { completedHabitsCount in
            var updatedQuest = quest
            updatedQuest.currentProgress = completedHabitsCount
            
            // Update the next segment goal (milestone)
            if updatedQuest.currentProgress >= updatedQuest.nextSegmentGoal {
                if let nextGoalIndex = updatedQuest.totalSegments.firstIndex(of: updatedQuest.nextSegmentGoal),
                   nextGoalIndex + 1 < updatedQuest.totalSegments.count {
                    updatedQuest.nextSegmentGoal = updatedQuest.totalSegments[nextGoalIndex + 1]
                }
            }
            
            completion(updatedQuest)
        }
    }
    func fetchCompletedHabitsCount(completion: @escaping (Int) -> Void) {
        guard let currentUserID = currentUser?.id else {
            print("No current user")
            completion(0)
            return
        }
        
        let db = Firestore.firestore()
        let habitsRef = db.collection("users").document(currentUserID).collection("habits")
        
        // Fetch all available dates in the "habits" collection
        habitsRef.getDocuments { (dateSnapshot, error) in
            if let error = error {
                print("Error fetching habit dates: \(error.localizedDescription)")
                completion(0)
                return
            }
            
            var totalCompletedHabitsCount = 0
            let dateDocuments = dateSnapshot?.documents ?? []
            
            if dateDocuments.isEmpty {
                completion(0)  // No dates found, return 0
                return
            }
            
            // Loop through each date document to access the habits array
            for dateDocument in dateDocuments {
                let habitData = dateDocument.data()
                
                // Assuming the array is stored under a field called "habits"
                if let habitsArray = habitData["habits"] as? [[String: Any]] {
                    for habit in habitsArray {
                        if let count = habit["count"] as? Int, let goal = habit["goal"] as? Int {
                            if count == goal {
                                totalCompletedHabitsCount += 1  // Increment count for completed habits
                            }
                        }
                    }
                }
            }
            
            print("Total completed habits: \(totalCompletedHabitsCount)")  // Debugging
            completion(totalCompletedHabitsCount)
        }
    }
    
    
    
    
    func checkDailyCheckinProgress(for quest: Quest, completion: @escaping (Quest) -> Void) {
        guard let currentUserID = currentUser?.id else {
            print("No current user")
            completion(quest)
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUserID)
        let checkInsRef = userRef.collection("checkIns")
        
        // Fetch the most recent check-in, ordered by date in descending order
        checkInsRef.order(by: "date", descending: true).limit(to: 1).getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching check-in: \(error.localizedDescription)")
                completion(quest)
                return
            }
            
            guard let latestCheckIn = querySnapshot?.documents.first,
                  let checkinTimestamp = latestCheckIn.data()["date"] as? Timestamp else {
                // No check-in found, reset progress
                var updatedQuest = quest
                updatedQuest.currentProgress = 0
                completion(updatedQuest)
                return
            }
            
            var updatedQuest = quest
            let lastCheckinDate = checkinTimestamp.dateValue()
            
            // Check if the latest check-in was today
            if Calendar.current.isDateInToday(lastCheckinDate) {
                if updatedQuest.currentProgress == 0 {
                    // Increment progress only if it hasn't been updated for today
                    updatedQuest.currentProgress += 1
                }
            } else {
                // If the last check-in is not today, reset the progress
                updatedQuest.currentProgress = 0
            }
            
            // Update the next segment goal if needed
            if updatedQuest.currentProgress >= updatedQuest.nextSegmentGoal,
               let nextGoalIndex = updatedQuest.totalSegments.firstIndex(of: updatedQuest.nextSegmentGoal),
               nextGoalIndex + 1 < updatedQuest.totalSegments.count {
                updatedQuest.nextSegmentGoal = updatedQuest.totalSegments[nextGoalIndex + 1]
            }
            
            completion(updatedQuest)
        }
    }
    
    
    func fetchGameProgress(completion: @escaping (Int) -> Void) {
        guard let userId = currentUser?.id else {
            print("No current user")
            completion(0)
            return
        }
        
        let db = Firestore.firestore()
        let gameDataRef = db.collection("gameData").document(userId).collection("phases")
        
        // Fetch all phases for the user
        gameDataRef.getDocuments { (phaseSnapshot, error) in
            if let error = error {
                print("Error getting phases: \(error.localizedDescription)")
                completion(0)
            } else {
                var totalLevelsCompleted = 0
                let phases = phaseSnapshot?.documents ?? []
                
                // Fetch levels for each phase
                let group = DispatchGroup()  // Used to manage async calls
                for phaseDocument in phases {
                    let levelsRef = gameDataRef.document(phaseDocument.documentID).collection("levels")
                    
                    group.enter()  // Enter the dispatch group for each phase
                    levelsRef.getDocuments { (levelSnapshot, levelError) in
                        if let levelError = levelError {
                            print("Error getting levels: \(levelError.localizedDescription)")
                        } else {
                            let levels = levelSnapshot?.documents ?? []
                            totalLevelsCompleted += levels.count  // Count the number of levels in the phase
                        }
                        group.leave()  // Leave the dispatch group once the phase is processed
                    }
                }
                
                // Once all async fetches are completed, call the completion handler
                group.notify(queue: .main) {
                    completion(totalLevelsCompleted)
                }
            }
        }
    }
    
    func checkGameProgress(for quest: Quest, completion: @escaping (Quest) -> Void) {
        fetchGameProgress { gameProgressCount in
            var updatedQuest = quest
            updatedQuest.currentProgress = gameProgressCount
            
            // Check if the user has reached the next segment goal
            if gameProgressCount >= updatedQuest.nextSegmentGoal {
                if let nextGoalIndex = updatedQuest.totalSegments.firstIndex(of: updatedQuest.nextSegmentGoal),
                   nextGoalIndex + 1 < updatedQuest.totalSegments.count {
                    updatedQuest.nextSegmentGoal = updatedQuest.totalSegments[nextGoalIndex + 1]
                }
            }
            
            completion(updatedQuest)
        }
    }
    
    
    func fetchProfileCount(completion: @escaping (Int) -> Void) {
        guard let currentUserID = currentUser?.id else {
            print("No current user")
            completion(0)
            return
        }
        
        let db = Firestore.firestore()
        let profilesRef = db.collection("users").document(currentUserID).collection("profiles")
        
        // Fetch all documents in the profiles collection
        profilesRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching profiles: \(error.localizedDescription)")
                completion(0)
                return
            }
            
            // Count the number of documents in the profiles collection
            let profileCount = querySnapshot?.documents.count ?? 0
            print("Profile count: \(profileCount)")
            completion(profileCount)
        }
    }
    func checkProfileProgress(for quest: Quest, completion: @escaping (Quest) -> Void) {
        fetchProfileCount { profileCount in
            var updatedQuest = quest
            updatedQuest.currentProgress = profileCount
            
            // Update the next segment goal (milestone)
            if updatedQuest.currentProgress >= updatedQuest.nextSegmentGoal {
                if let nextGoalIndex = updatedQuest.totalSegments.firstIndex(of: updatedQuest.nextSegmentGoal),
                   nextGoalIndex + 1 < updatedQuest.totalSegments.count {
                    updatedQuest.nextSegmentGoal = updatedQuest.totalSegments[nextGoalIndex + 1]
                }
            }
            
            completion(updatedQuest)
        }
    }
    
    
    
    
    
    func fetchChatProgress(completion: @escaping (Int) -> Void) {
        guard let currentUser = currentUser else {
            print("No current user")
            completion(0)
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("chatbot_").document(currentUser.id)
        let sessionsRef = userRef.collection("sessions")
        
        sessionsRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting chat sessions: \(error)")
                completion(0)  // Return 0 in case of error
            } else {
                // Count the number of documents (i.e., sessions)
                let sessionCount = querySnapshot?.documents.count ?? 0
                completion(sessionCount)
            }
        }
    }
    
    func checkChatProgress(for quest: Quest, completion: @escaping (Quest) -> Void) {
        fetchChatProgress { sessionCount in
            var updatedQuest = quest
            
            // Update current progress with the number of chat sessions
            updatedQuest.currentProgress = sessionCount
            
            // Only move forward in segments, do not reset to lower goals
            if sessionCount >= updatedQuest.nextSegmentGoal {
                // Move to the next segment goal (if there is a next goal)
                if let nextGoalIndex = updatedQuest.totalSegments.firstIndex(of: updatedQuest.nextSegmentGoal),
                   nextGoalIndex + 1 < updatedQuest.totalSegments.count {
                    updatedQuest.nextSegmentGoal = updatedQuest.totalSegments[nextGoalIndex + 1]
                }
            }
            
            completion(updatedQuest)
        }
    }
    
    
    
    
    
    
    
    
    
    //        }
    
//    
//    func checkGameProgress(for quest: Quest, completion: @escaping (Quest) -> Void) {
//        // Example logic to fetch game data and update quest progress
//        //        fetchGameData { gameModuleCount in
//        //            var updatedQuest = quest
//        //            updatedQuest.currentProgress = gameModuleCount
//        //
//        //            for segment in quest.totalSegments {
//        //                if gameModuleCount >= segment {
//        //                    updatedQuest.nextSegmentGoal = segment
//        //                } else {
//        //                    break
//        //                }
//        //            }
//        //
//        //            completion(updatedQuest)
//        //        }
//    }
    
    
    private func dateString(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    func loadHabitHistory() {
        guard let user = currentUser else {
            print("No current user")
            return
        }
        let userID = user.id
        
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -30, to: endDate)!
        
        var currentDate = startDate
        while currentDate <= endDate {
            let dateString = dateString(for: currentDate)
            
            db.collection("users").document(userID).collection("habits").document(dateString).getDocument { document, error in
                if let document = document, document.exists {
                    if let data = document.data(), let habitsData = data["habits"] as? [[String: Any]] {
                        let validHabits = habitsData.compactMap { habitData -> Habit? in
                            return self.createHabit(from: habitData)
                        }
                        
                        DispatchQueue.main.async {
                            // Group habits by title
                            for habit in validHabits {
                                var existingHabits = self.habitsByName[habit.title] ?? []
                                existingHabits.append(habit)
                                self.habitsByName[habit.title] = existingHabits
                            }
                        }
                    }
                } else if let error = error {
                    print("Error fetching document for \(dateString): \(error.localizedDescription)")
                }
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
    }
    
    private func createHabit(from data: [String: Any]) -> Habit? {
        if let id = data["id"] as? String,
           let title = data["title"] as? String,
           let unit = data["unit"] as? String,
           let count = data["count"] as? Int,
           let goal = data["goal"] as? Int,
           let startColor = data["startColor"] as? String,
           let endColor = data["endColor"] as? String,
           let category = data["category"] as? String,
           let frequencyRawValue = data["frequency"] as? String,
           let frequency = Habit.FrequencyType(rawValue: frequencyRawValue),
           let routineTimeRawValue = data["routineTime"] as? String,
           let routineTime = Habit.RoutineTime(rawValue: routineTimeRawValue),
           let endDate = (data["endDate"] as? Timestamp)?.dateValue(),
           let startDate = (data["startDate"] as? Timestamp)?.dateValue(),
           let dateTaken = data["dateTaken"] as? String {
            
            let reminder = (data["reminder"] as? Timestamp)?.dateValue()
            
            let interval = data["interval"] as? Int
            let daysOfWeek = data["daysOfWeek"] as? [Int]
            
            var specificDates: [Date]? = nil
            if let specificDatesTimestamps = data["specificDates"] as? [Timestamp] {
                specificDates = specificDatesTimestamps.map { $0.dateValue() }
            } else if let specificDatesMillis = data["specificDates"] as? [Double] {
                specificDates = specificDatesMillis.map { Date(timeIntervalSince1970: $0 / 1000) }
            } else if let specificDatesStrings = data["specificDates"] as? [String] {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd" // Adjust the date format if needed
                specificDates = specificDatesStrings.compactMap { dateFormatter.date(from: $0) }
            }
            
            return Habit(id: id, title: title, unit: unit, count: count, goal: goal,
                         startColor: startColor, endColor: endColor,
                         category: category, frequency: frequency,
                         reminder: reminder, routineTime: routineTime,
                         endDate: endDate, dateTaken: dateTaken, startDate: startDate,
                         interval: interval, daysOfWeek: daysOfWeek, specificDates: specificDates)
        }
        return nil
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
