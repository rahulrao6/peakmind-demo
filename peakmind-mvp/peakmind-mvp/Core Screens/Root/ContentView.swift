//
//  ContentView.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 2/12/24.
//

import SwiftUI
import HealthKit
import Firebase



struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showingSplash = true // State to control splash screen visibility
    @State private var navigateToStoreScreen = false // State to control splash screen visibility
    @State private var navigateToInventoryScreen = false // State to control splash screen visibility
    @EnvironmentObject var healthStore: HKHealthStore
    @EnvironmentObject var healthKitManager: HealthKitManager

    
    var body: some View {
        ZStack {
            // Main content conditionally displayed based on authentication status
            Group {
                if $viewModel.userSession != nil && viewModel.currentUser  != nil {
                    //logged in
                    //                    if (viewModel.currentUser?.hasCompletedInitialQuiz == true) {
                    //                        TabViewMain()
                    //                            .environmentObject(viewModel)
                    //
                    //                    } else {
                    //                        if (viewModel.currentUser?.hasSetInitialAvatar == false) {
                    //                            AvatarMenuView()
                    //                                .environmentObject(viewModel)
                    //                        } else {
                    //                            TabViewMain()
                    //                                .environmentObject(viewModel)
                    //                        }
                    //                        TabViewMain()
                    //                            .environmentObject(viewModel)
                    //                    }
                    
                    if (viewModel.currentUser?.hasSetInitialAvatar == false) {
                        AvatarMenuView()
                            .environmentObject(viewModel)
                    } else {
    
                        TabViewMain()
                            .environmentObject(viewModel)
                    }
                
                    
                } else {
                    LoginView()
                }
            }
            .zIndex(0) // Ensure main content is behind the splash screen in the ZStack
            .environment(\.colorScheme, .light) // Force light mode for the entire app


            // Splash screen displayed on top when showingSplash is true
            if showingSplash {
                SplashScreen()
                    .transition(.opacity) // Optional: add a transition effect when splash screen disappears
                    .zIndex(1) // Ensure splash screen is on top in the ZStack
                
                
            }



                  // Button to display current balance - Show only when the user is logged in
//            if viewModel.userSession != nil && viewModel.currentUser != nil {
//                VStack {
//                    HStack {
//                        Spacer()
//
//                        Button(action: {
//                            navigateToInventoryScreen = true
//                        }) {
//                            if let currentBalance = viewModel.currentUser?.currencyBalance {
//                                Text("$\(currentBalance)")
//                                    .font(.headline)
//                                    .foregroundColor(.white)
//                                    .padding(8)
//                                    .background(Color.blue)
//                                    .cornerRadius(8)
//                            }
//                        }
//
//                        .sheet(isPresented: $navigateToInventoryScreen) {
//                            InventoryView()
//                        }
//                         // Place button at the top of the screen
//                         // Adjust padding
//
//                        Button(action: {
//                            navigateToStoreScreen = true
//                        }) {
//                            Image(systemName: "cart.fill") // Marketplace icon
//                                .resizable()
//                                .frame(width: 24, height: 24) // Smaller size
//                                .padding(8) // Add padding
//                                .background(Color.darkBlue) // Dark blue background
//                                .foregroundColor(.white)
//                                .clipShape(Circle())
//                        }
//                        // Adjust padding
//                        .shadow(radius: 5)
//                        .background(
//                            NavigationLink(destination: StoreView(), isActive: $navigateToStoreScreen) {
//                                EmptyView()
//                            }
//                        )
//
//
//                    }
//                    Spacer()
//                }
//                .padding()
//            }
            

            
        }
        
        
        .onAppear {
            readTotalStepCount()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Adjust delay time as needed
                withAnimation {
                    showingSplash = false // Hide splash screen after delay
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
                                                quantitySamplePredicate: nil,
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
        
        healthStore.execute(query)
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



    
