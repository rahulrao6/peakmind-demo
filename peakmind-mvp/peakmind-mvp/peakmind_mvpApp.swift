////
////  peakmind_mvpApp.swift
////  peakmind-mvp
////
////  Created by Raj Jagirdar on 2/12/24.
////
//
//import SwiftUI
//import FirebaseCore
//import GoogleSignIn
//import HealthKit
//
//
//class AppDelegate: NSObject, UIApplicationDelegate {
//  func application(_ application: UIApplication,
//                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//    FirebaseApp.configure()
//      
//
//    return true
//  }
//    @available(iOS 9.0, *)
//    func application(_ application: UIApplication, open url: URL,
//                     options: [UIApplication.OpenURLOptionsKey: Any])
//      -> Bool {
//      return GIDSignIn.sharedInstance.handle(url)
//    }
//}
//
//import HealthKit
//import Combine
//
////class HealthKitManager: ObservableObject {
////    static let shared = HealthKitManager()
////    let healthStore: HKHealthStore?
////
////    init() {
////        guard HKHealthStore.isHealthDataAvailable() else {
////            self.healthStore = nil
////            return
////        }
////        self.healthStore = HKHealthStore()
////    }
////
////    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
////        guard let healthStore = healthStore else {
////            completion(false, NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device."]))
////            return
////        }
////
////        let readTypes = Set([
////            HKObjectType.quantityType(forIdentifier: .heartRate)!,
////            HKObjectType.quantityType(forIdentifier: .stepCount)!,
////            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
////        ])
////
////        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
////            DispatchQueue.main.async {
////                completion(success, error)
////            }
////        }
////    }
////}
//
////
////class HealthKitManager: ObservableObject {
////    static let shared = HealthKitManager()
////    let healthStore: HKHealthStore?
////
////    init() {
////        guard HKHealthStore.isHealthDataAvailable() else {
////            self.healthStore = nil
////            return
////        }
////        self.healthStore = HKHealthStore()
////    }
////
////    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
////        guard let healthStore = healthStore else {
////            completion(false, NSError(domain: "HealthKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device."]))
////            return
////        }
////
////        let readTypes = Set([
////            HKObjectType.quantityType(forIdentifier: .heartRate)!,
////            HKObjectType.quantityType(forIdentifier: .stepCount)!,
////            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
////        ])
////
////        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
////            DispatchQueue.main.async {
////                completion(success, error)
////            }
////        }
////    }
////}
////
////@main
////struct peakmind_mvpApp: App {
////  // register app delegate for Firebase setup
////    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
////    @StateObject var viewModel = AuthViewModel()
////
////    @StateObject var journalDataManager = JournalDataManager() // Instantiate JournalDataManager
////    //@StateObject var healthStore = HKHealthStore() // Assuming you have proper initialization elsewhere
////    @StateObject var healthKitManager = HealthKitManager.shared
////
////    //private let healthStore: HKHealthStore
////    
////    init() {
////        //guard HKHealthStore.isHealthDataAvailable() else {  fatalError("This app requires a device that supports HealthKit") }
////        //healthStore = HKHealthStore()
////        requestHealthkitPermissions()
////    }
////    
////    private func requestHealthkitPermissions() {
////        
////        let sampleTypesToRead = Set([
////            HKObjectType.quantityType(forIdentifier: .heartRate)!,
////            HKObjectType.quantityType(forIdentifier: .stepCount)!,
////            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
////        ])
////        
////        healthKitManager.requestAuthorization { success, error in
////            print("Request Authorization -- Success: ", success, " Error: ", error ?? "nil")
////        }
////    }
////    
////    
////  var body: some Scene {
////    WindowGroup {
////      NavigationView {
////          ContentView()
////              .environmentObject(viewModel)
////              .environmentObject(journalDataManager) // Provide JournalDataManager
////              .environmentObject(healthKitManager)  // Provide HealthKitManager
////
////              //.environmentObject(healthStore)
////
////      }
////    }
////  }
////}
////
////
////extension HKHealthStore: ObservableObject{}
////
//class HealthKitManager: ObservableObject {
//    let healthStore: HKHealthStore?
//    @Published var isAuthorized = false
//    @Published var errorMessage: String?
//
//    init() {
//        self.healthStore = HKHealthStore.isHealthDataAvailable() ? HKHealthStore() : nil
//    }
//
//    func requestAuthorization() {
//        
//        guard let healthStore = healthStore else {
//            errorMessage = "HealthKit is not available on this device."
//            return
//        }
//
//        let readTypes = Set([
//            HKObjectType.workoutType(),
//            HKObjectType.quantityType(forIdentifier: .heartRate),
//            HKObjectType.quantityType(forIdentifier: .stepCount),
//            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
//        ].compactMap { $0 })
//
//        healthStore.requestAuthorization(toShare: [], read: readTypes) { [weak self] success, error in
//            DispatchQueue.main.async {
//                self?.isAuthorized = success
//                self?.errorMessage = error?.localizedDescription
//            }
//        }
//    }
//
//    func fetchHealthData() {
//        guard isAuthorized, let healthStore = healthStore else { return }
//        
//        // Fetch heart rate
//        if let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) {
//            let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: nil, options: .discreteAverage) { _, result, error in
//                guard let result = result, let averageHeartRate = result.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())) else { return }
//                print("Average heart rate: \(averageHeartRate) bpm")
//            }
//            healthStore.execute(query)
//        }
//        
//        // Similarly, you can fetch step count and sleep analysis data here
//    }
//}
//
//@main
//struct peakmind_mvpApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//    @StateObject var viewModel = AuthViewModel()
//    @StateObject var journalDataManager = JournalDataManager()
//
//    // Create HealthKitManager as a regular property
//    let healthKitManager = HealthKitManager()
//
//    init() {
//        // Request HealthKit authorization during app initialization
//        healthKitManager.requestAuthorization()
//    }
//
//    var body: some Scene {
//        WindowGroup {
//            NavigationView {
//                ContentView()
//                    .environmentObject(viewModel)
//                    .environmentObject(journalDataManager)
//                    .environmentObject(healthKitManager)  // Pass it as an environment object
//            }
//        }
//    }
//}
//
//
//extension HKHealthStore: ObservableObject {}
import SwiftUI
import FirebaseCore
import GoogleSignIn
import HealthKit

import SwiftUI
import FirebaseCore
import GoogleSignIn
import UserNotifications

//class AppDelegate: NSObject, UIApplicationDelegate {
//    func application(_ application: UIApplication,
//                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
//        print("Configuring Firebase...")
//        FirebaseApp.configure()
//        print("Firebase configured.")
//        return true
//    }
//
//    @available(iOS 9.0, *)
//    func application(_ application: UIApplication, open url: URL,
//                     options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
//        print("Handling URL: \(url)")
//        let handled = GIDSignIn.sharedInstance.handle(url)
//        print("URL handled: \(handled)")
//        return handled
//    }
//}
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        print("Configuring Firebase...")
        FirebaseApp.configure()
        print("Firebase configured.")
        
        // Request notification permission
        requestNotificationPermission()
        
        // Set the notification center delegate
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        print("Handling URL: \(url)")
        let handled = GIDSignIn.sharedInstance.handle(url)
        print("URL handled: \(handled)")
        return handled
    }
    
    // Request notification permissions from the user
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Failed to request notification permissions: \(error.localizedDescription)")
            } else if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }
    
    // Handle notifications when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound]) // Show banner and play sound even if the app is in the foreground
    }
    
    // Handle user interactions with notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification received with identifier: \(response.notification.request.identifier)")
        completionHandler()
    }
}


@main
struct peakmind_mvpApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var viewModel = AuthViewModel()
    @StateObject var CommunitiesViewModel1 = CommunitiesViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(viewModel)
                    .environmentObject(CommunitiesViewModel1)
                    .onAppear {
                        // Example of scheduling a notification
                        scheduleNotification()
                    }
            }
        }
    }
    func scheduleNotification() {
        let center = UNUserNotificationCenter.current()
        
        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "This is your notification scheduled 10 seconds ago!"
        content.sound = .default
        
        // Create a trigger to fire in 10 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        // Create the notification request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Schedule the notification
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled to fire in 10 seconds.")
            }
        }
    }

}

import SwiftUI
import HealthKit
import Combine

class HealthKitManager: ObservableObject {
    let healthStore: HKHealthStore?
    @Published var isAuthorized = false
    @Published var errorMessage: String?

    init() {
        self.healthStore = HKHealthStore.isHealthDataAvailable() ? HKHealthStore() : nil
    }

//    func requestAuthorization() {
//        guard let healthStore = healthStore else {
//            errorMessage = "HealthKit is not available on this device."
//            return
//        }
//
//        let readTypes: Set<HKObjectType> = [
//            HKObjectType.workoutType(),
//            HKObjectType.quantityType(forIdentifier: .heartRate),
//            HKObjectType.quantityType(forIdentifier: .stepCount),
//            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
//        ].map { $0 }
//
//        healthStore.requestAuthorization(toShare: nil, read: readTypes) { [weak self] success, error in
//            DispatchQueue.main.async {
//                self?.isAuthorized = success
//                if let error = error {
//                    self?.errorMessage = error.localizedDescription
//                } else {
//                    self?.errorMessage = nil
//                }
//            }
//        }
//    }

    func fetchHealthData() {
        guard isAuthorized, let healthStore = healthStore else { return }

        // Fetch heart rate
        if let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) {
            let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: nil, options: .discreteAverage) { _, result, error in
                if let error = error {
                    print("Error fetching heart rate: \(error.localizedDescription)")
                    return
                }
                guard let result = result, let averageHeartRate = result.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())) else {
                    print("No heart rate data available")
                    return
                }
                print("Average heart rate: \(averageHeartRate) bpm")
            }
            healthStore.execute(query)
        }
    }
}
