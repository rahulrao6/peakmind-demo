import SwiftUI
import HealthKit
import Firebase
struct ContentView: View {
  @EnvironmentObject var viewModel: AuthViewModel
  @State private var showingSplash = true
  @State private var navigateToStoreScreen = false
  @State private var navigateToInventoryScreen = false
  @EnvironmentObject var healthKitManager: HealthKitManager
  @EnvironmentObject var EventKitManager1: EventKitManager
  var body: some View {
    ZStack {
      Group {
        if $viewModel.userSession != nil && viewModel.currentUser != nil {
            TabViewMain()
              .environmentObject(viewModel)
              .environmentObject(healthKitManager)
              .environmentObject(EventKitManager1)
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
      let now = Date()
//      let startOfDay = Calendar.current.startOfDay(for: now)
//      guard let startDate = Calendar.current.date(byAdding: .day, value: -7, to: startOfDay) else { return }
//      let endDate = now // Include up to the current time
//      let userId = viewModel.currentUser?.id ?? "";
//      healthKitManager.fetchStepCount(for: userId, startDate: startDate, endDate: endDate)
//      healthKitManager.fetchSleepAnalysis(for: userId, startDate: startDate, endDate: endDate)
//      healthKitManager.fetchActiveMinutes(for: userId, startDate: startDate, endDate: endDate)
        //healthKitManager.fetchHealthData(for: viewModel.currentUser?.id ?? "", numberOfDays: 7)
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
