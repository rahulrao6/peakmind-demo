////
////  ContentView.swift
////  peakmind-mvp
////
////  Created by Raj Jagirdar on 2/12/24.
////
//
//import SwiftUI
//import HealthKit
//import Firebase
//
//
////
////struct ContentView: View {
////    @EnvironmentObject var viewModel: AuthViewModel
////    @State private var showingSplash = true // State to control splash screen visibility
////    @State private var navigateToStoreScreen = false // State to control splash screen visibility
////    @State private var navigateToInventoryScreen = false // State to control splash screen visibility
////    @EnvironmentObject var healthStore: HKHealthStore
////    @EnvironmentObject var healthKitManager: HealthKitManager
////
////    
////    var body: some View {
////        ZStack {
////            // Main content conditionally displayed based on authentication status
////            Group {
////                if $viewModel.userSession != nil && viewModel.currentUser  != nil {
////
////                    if (viewModel.currentUser?.hasSetInitialAvatar == false) {
////                        AvatarMenuView()
////                            .environmentObject(viewModel)
////                    } else {
////    
////                        TabViewMain()
////                            .environmentObject(viewModel)
////                    }
////                
////                    
////                } else {
////                    VStack {
////                        NewLoginView()
////                        SignInWithAppleButtonView()
////                    }
////                }
////            }
////            .zIndex(0) // Ensure main content is behind the splash screen in the ZStack
////            .environment(\.colorScheme, .light) // Force light mode for the entire app
////
////
////            // Splash screen displayed on top when showingSplash is true
////            if showingSplash {
////                SplashScreen()
////                    .transition(.opacity) // Optional: add a transition effect when splash screen disappears
////                    .zIndex(1) // Ensure splash screen is on top in the ZStack
////            }
////        }
////        
////        .onAppear {
////            readTotalStepCount()
////            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Adjust delay time as needed
////                withAnimation {
////                    showingSplash = false // Hide splash screen after delay
////                }
////            }
////        }
////
////    }
////    
////    func readTotalStepCount() {
////        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
////            fatalError("*** Unable to get the step count type ***")
////        }
////        
////        let endDate = Date()
////        let startDate = Calendar.current.date(byAdding: .day, value: -14, to: endDate)!
////        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate])
////
////        var interval = DateComponents()
////        interval.day = 1
////
////        let query = HKStatisticsCollectionQuery(quantityType: stepCountType,
////                                                quantitySamplePredicate: nil,
////                                                options: [.cumulativeSum],
////                                                anchorDate: startDate,
////                                                intervalComponents: interval)
////        
////        query.initialResultsHandler = { query, results, error in
////            if let error = error {
////                print("Error fetching step counts: \(error.localizedDescription)")
////                return
////            }
////            guard let results = results else {
////                print("No results returned from HealthKit")
////                return
////            }
////            
////            var dayData = [String: Double]()
////            let formatter = DateFormatter()
////            formatter.dateFormat = "yyyy-MM-dd"
////            
////            results.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
////                let dateKey = formatter.string(from: statistics.startDate)
////                if let quantity = statistics.sumQuantity() {
////                    let steps = quantity.doubleValue(for: HKUnit.count())
////                    dayData[dateKey] = steps
////                }
////            }
////
////            self.saveStepsToFirestore(dayData: dayData)
////        }
////        
////        healthKitManager.healthStore?.execute(query)
////    }
////    
////    
////    private func saveStepsToFirestore(dayData: [String: Double]) {
////        guard let userID = Auth.auth().currentUser?.uid else {
////            print("User not logged in")
////            return
////        }
////        
////        let stepsDocument = Firestore.firestore().collection("steps").document(userID)
////        stepsDocument.setData(dayData, merge: true) { error in
////            if let error = error {
////                print("Error writing steps to Firestore: \(error)")
////            } else {
////                print("Successfully updated steps data for the last two weeks.")
////            }
////        }
////    }
////}
//
//struct ContentView: View {
//    @EnvironmentObject var viewModel: AuthViewModel
//    @State private var showingSplash = true
//    @State private var navigateToStoreScreen = false
//    @State private var navigateToInventoryScreen = false
//    @EnvironmentObject var healthKitManager: HealthKitManager
//
//    var body: some View {
//        ZStack {
//            Group {
//                if $viewModel.userSession != nil && viewModel.currentUser  != nil {
//                    if viewModel.currentUser?.hasSetInitialAvatar == false {
//                        AvatarMenuView()
//                            .environmentObject(viewModel)
//                    } else {
//                        TabViewMain()
//                            .environmentObject(viewModel)
//                    }
//                } else {
//                    VStack {
//                        NewLoginView()
//                        SignInWithAppleButtonView()
//                    }
//                }
//            }
//            .zIndex(0)
//            .environment(\.colorScheme, .light)
//
//            if showingSplash {
//                SplashScreen()
//                    .transition(.opacity)
//                    .zIndex(1)
//            }
//        }
//        .onAppear {
//            readTotalStepCount()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                withAnimation {
//                    showingSplash = false
//                }
//            }
//        }
//    }
//
//    func readTotalStepCount() {
//        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
//            fatalError("*** Unable to get the step count type ***")
//        }
//
//        let endDate = Date()
//        let startDate = Calendar.current.date(byAdding: .day, value: -14, to: endDate)!
//        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate])
//
//        var interval = DateComponents()
//        interval.day = 1
//
//        let query = HKStatisticsCollectionQuery(quantityType: stepCountType,
//                                                quantitySamplePredicate: nil,
//                                                options: [.cumulativeSum],
//                                                anchorDate: startDate,
//                                                intervalComponents: interval)
//
//        query.initialResultsHandler = { query, results, error in
//            if let error = error {
//                print("Error fetching step counts: \(error.localizedDescription)")
//                return
//            }
//            guard let results = results else {
//                print("No results returned from HealthKit")
//                return
//            }
//
//            var dayData = [String: Double]()
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM-dd"
//
//            results.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
//                let dateKey = formatter.string(from: statistics.startDate)
//                if let quantity = statistics.sumQuantity() {
//                    let steps = quantity.doubleValue(for: HKUnit.count())
//                    dayData[dateKey] = steps
//                }
//            }
//
//            self.saveStepsToFirestore(dayData: dayData)
//        }
//
//        healthKitManager.healthStore?.execute(query)
//    }
//
//    private func saveStepsToFirestore(dayData: [String: Double]) {
//        guard let userID = Auth.auth().currentUser?.uid else {
//            print("User not logged in")
//            return
//        }
//
//        let stepsDocument = Firestore.firestore().collection("steps").document(userID)
//        stepsDocument.setData(dayData, merge: true) { error in
//            if let error = error {
//                print("Error writing steps to Firestore: \(error)")
//            } else {
//                print("Successfully updated steps data for the last two weeks.")
//            }
//        }
//    }
//}

import SwiftUI
import HealthKit
import Firebase

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showingSplash = true
    @State private var navigateToStoreScreen = false
    @State private var navigateToInventoryScreen = false
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject var CommunitiesViewModel : CommunitiesViewModel


    var body: some View {
        ZStack {
            Group {
                if $viewModel.userSession != nil && viewModel.currentUser  != nil {
 
                        TabViewMain()
                            .environmentObject(viewModel)
                            .environmentObject(CommunitiesViewModel)
                            .environmentObject(healthKitManager)

                            
                } else {
                    VStack {
                        LoginView()
                        
                    }
                }
            }
            .zIndex(0)
            .environment(\.colorScheme, .light)

            if showingSplash {
                SplashScreen()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            //readTotalStepCount()
                healthKitManager.requestAuthorization()
                healthKitManager.startLiveStepCountUpdates()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showingSplash = false
                }
            }
        }
    }

    func readTotalStepCount() {
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            fatalError("*** Unable to get the step count type ***")
        }

        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -14, to: endDate)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate])

        var interval = DateComponents()
        interval.day = 1

        let query = HKStatisticsCollectionQuery(quantityType: stepCountType,
                                                quantitySamplePredicate: predicate,
                                                options: [.cumulativeSum],
                                                anchorDate: startDate,
                                                intervalComponents: interval)

        query.initialResultsHandler = { query, results, error in
            if let error = error {
                print("Error fetching step counts: \(error.localizedDescription)")
                return
            }
            guard let results = results else {
                print("No results returned from HealthKit")
                return
            }

            var dayData = [String: Double]()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"

            results.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                let dateKey = formatter.string(from: statistics.startDate)
                if let quantity = statistics.sumQuantity() {
                    let steps = quantity.doubleValue(for: HKUnit.count())
                    dayData[dateKey] = steps
                }
            }

            self.saveStepsToFirestore(dayData: dayData)
        }

        //healthKitManager.healthStore?.execute(query)
    }

    private func saveStepsToFirestore(dayData: [String: Double]) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        let stepsDocument = Firestore.firestore().collection("steps").document(userID)
        stepsDocument.setData(dayData, merge: true) { error in
            if let error = error {
                print("Error writing steps to Firestore: \(error)")
            } else {
                print("Successfully updated steps data for the last two weeks.")
            }
        }
    }
}
