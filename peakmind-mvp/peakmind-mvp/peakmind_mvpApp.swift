
import SwiftUI
import FirebaseCore
import GoogleSignIn
import HealthKit

import SwiftUI
import FirebaseCore
import GoogleSignIn
import UserNotifications
import EventKit


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    let eventStore = EKEventStore()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        print("Configuring Firebase...")
        FirebaseApp.configure()
        print("Firebase configured.")
        
        // Request notification permission
        requestNotificationPermission()
        
        // Set the notification center delegate
        UNUserNotificationCenter.current().delegate = self
        
        //requestCalendarAccess()

        
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
    @StateObject var HealthKitManager1 = HealthKitManager()
    @StateObject var EventKitManager1 = EventKitManager()


    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(viewModel)
                    .environmentObject(CommunitiesViewModel1)
                    .environmentObject(HealthKitManager1)
                    .environmentObject(EventKitManager1)

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
import FirebaseFirestore

import SwiftUI
import HealthKit
import Combine
import FirebaseFirestore

class HealthKitManager: ObservableObject {
    let healthStore: HKHealthStore?
    @Published var isAuthorized = false
    @Published var errorMessage: String?
    private let db = Firestore.firestore()
    private var stepCountObserverQuery: HKObserverQuery?
    @Published var liveStepCount: Double = 0.0
    private var queryAnchor: HKQueryAnchor?

    init() {
        self.healthStore = HKHealthStore.isHealthDataAvailable() ? HKHealthStore() : nil
    }

    func requestAuthorization() {
        let healthDataToRead = Set([
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ])

        healthStore?.requestAuthorization(toShare: nil, read: healthDataToRead) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.isAuthorized = success
                    if success {
                        self.startStepCountObserverQuery()
                    }
                }
            }
        }
    }


    func startLiveStepCountUpdates() {
        guard let healthStore = healthStore else { return }
        
        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date(), options: .strictStartDate)
        
        // Anchored Object Query for initial data and incremental updates
        let query = HKAnchoredObjectQuery(type: stepType, predicate: predicate, anchor: queryAnchor, limit: HKObjectQueryNoLimit) { query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil in
            
            guard let samples = samplesOrNil as? [HKQuantitySample] else {
                print("Error fetching step count samples: \(String(describing: errorOrNil))")
                return
            }
            
            // Sum up the steps for the current day
            let totalSteps = samples.reduce(0.0) { (sum, sample) -> Double in
                return sum + sample.quantity.doubleValue(for: HKUnit.count())
            }
            
            DispatchQueue.main.async {
                self.liveStepCount = totalSteps
            }
            
            self.queryAnchor = newAnchor
        }
        
        query.updateHandler = { query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil in
            guard let samples = samplesOrNil as? [HKQuantitySample] else {
                print("Error fetching step count samples: \(String(describing: errorOrNil))")
                return
            }
            
            // Sum up the steps for the current day
            let newSteps = samples.reduce(0.0) { (sum, sample) -> Double in
                return sum + sample.quantity.doubleValue(for: HKUnit.count())
            }
            
            DispatchQueue.main.async {
                self.liveStepCount += newSteps
            }
            
            self.queryAnchor = newAnchor
        }
        
        healthStore.execute(query)
    }
    
    func startStepCountObserverQuery() {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }

        stepCountObserverQuery = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, completionHandler, error in
            if let error = error {
                print("Observer query error: \(error.localizedDescription)")
                return
            }

            self?.fetchLiveStepCount()
            completionHandler()
        }

        if let stepCountObserverQuery = stepCountObserverQuery {
            healthStore?.execute(stepCountObserverQuery)
        }
    }

    func fetchLiveStepCount() {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            if let error = error {
                print("Error fetching live step count: \(error.localizedDescription)")
                return
            }

            if let sum = result?.sumQuantity() {
                let stepCount = sum.doubleValue(for: HKUnit.count())
                DispatchQueue.main.async {
                    // Update your UI with the stepCount
                    print("Live step count: \(stepCount)")
                }
            }
        }

        healthStore?.execute(query)
    }

    func fetchHealthData(for userId: String, numberOfDays: Int) {
        guard isAuthorized, let healthStore = healthStore else { return }

        let now = Date()
        guard let startDate = Calendar.current.date(byAdding: .day, value: -numberOfDays, to: Calendar.current.startOfDay(for: now)) else { return }
        let endDate = Calendar.current.startOfDay(for: now)

        fetchStepCount(for: userId, startDate: startDate, endDate: endDate)
        fetchSleepAnalysis(for: userId, startDate: startDate, endDate: endDate)
    }

    private func fetchStepCount(for userId: String, startDate: Date, endDate: Date) {
        guard let healthStore = healthStore else { return }

        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsCollectionQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: startDate, intervalComponents: DateComponents(day: 1))

        query.initialResultsHandler = { [weak self] _, result, error in
            if let error = error {
                print("Error fetching step count: \(error.localizedDescription)")
                return
            }

            result?.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                if let sum = statistics.sumQuantity() {
                    let stepCount = sum.doubleValue(for: HKUnit.count())
                    let date = statistics.startDate
                    self?.saveHealthDataToFirestore(userId: userId, type: "stepCount", date: date, data: ["steps": stepCount])
                }
            }
        }
        healthStore.execute(query)
    }

    private func fetchSleepAnalysis(for userId: String, startDate: Date, endDate: Date) {
        guard let healthStore = healthStore else { return }

        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, samples, error in
            if let error = error {
                print("Error fetching sleep analysis: \(error.localizedDescription)")
                return
            }

            guard let samples = samples as? [HKCategorySample] else {
                print("No sleep data available")
                return
            }

            var dailySleepData = [Date: TimeInterval]()

            for sample in samples {
                let date = Calendar.current.startOfDay(for: sample.startDate)
                let sleepDuration = sample.endDate.timeIntervalSince(sample.startDate)

                if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                    dailySleepData[date, default: 0] += sleepDuration
                }
            }

            for (date, sleepDuration) in dailySleepData {
                let sleepDurationInHours = sleepDuration / 3600
                self?.saveHealthDataToFirestore(userId: userId, type: "sleepDuration", date: date, data: ["sleepDuration": sleepDurationInHours])
            }
        }
        healthStore.execute(query)
    }

    private func saveHealthDataToFirestore(userId: String, type: String, date: Date, data: [String: Any]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: date)

        let healthDataRef = db.collection("users").document(userId)
            .collection("healthKitData").document(type)
            .collection("days").document(formattedDate)

        healthDataRef.getDocument { [weak self] document, error in
            if let error = error {
                print("Error checking for existing health data: \(error.localizedDescription)")
                return
            }

            if document?.exists == true {
                print("Data for \(formattedDate) already exists, skipping save.")
            } else {
                self?.performSave(healthDataRef: healthDataRef, data: data, formattedDate: formattedDate)
            }
        }
    }

    private func performSave(healthDataRef: DocumentReference, data: [String: Any], formattedDate: String) {
        healthDataRef.setData(data) { error in
            if let error = error {
                print("Error saving health data: \(error.localizedDescription)")
            } else {
                print("Health data saved successfully for \(formattedDate).")
            }
        }
    }
}
import EventKit

class EventKitManager: ObservableObject {
    let eventStore = EKEventStore()

    // Method to request calendar access
    func requestCalendarAccess() async -> Bool {
        if #available(iOS 17.0, *) {
            do {
                return try await eventStore.requestFullAccessToEvents()
            } catch {
                print("Failed to request calendar access: \(error.localizedDescription)")
                return false
            }
        } else {
            return await withCheckedContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, error in
                    if let error = error {
                        print("Failed to request calendar access: \(error.localizedDescription)")
                        continuation.resume(returning: false)
                    } else {
                        continuation.resume(returning: granted)
                    }
                }
            }
        }
    }
    
    // Method to schedule an event
    func scheduleEvent(title: String, startDate: Date, endDate: Date, notes: String? = nil) async {
        let granted = await requestCalendarAccess()
        guard granted else {
            print("Calendar access denied")
            return
        }

        let event = EKEvent(eventStore: self.eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.notes = notes
        event.calendar = self.eventStore.defaultCalendarForNewEvents

        do {
            try self.eventStore.save(event, span: .thisEvent)
            print("Event saved successfully")
        } catch let error as NSError {
            print("Failed to save event with error: \(error)")
        }
    }
    
    // Method to schedule a recurring event
    func scheduleRecurringEvent(title: String, startDate: Date, frequency: EKRecurrenceFrequency) async -> String? {
        let granted = await requestCalendarAccess()
        guard granted else {
            print("Calendar access denied")
            return nil
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = startDate.addingTimeInterval(3600) // 1 hour duration
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        let recurrenceRule = EKRecurrenceRule(
            recurrenceWith: frequency,
            interval: 1,
            end: nil
        )
        event.recurrenceRules = [recurrenceRule]
        
        do {
            try eventStore.save(event, span: .futureEvents)
            print("Recurring event saved successfully")
            return event.eventIdentifier
        } catch {
            print("Failed to schedule recurring event: \(error)")
            return nil
        }
    }
    
    // Method to remove an event
    func removeEvent(withIdentifier identifier: String) async {
        let event = eventStore.event(withIdentifier: identifier)
        
        guard let event = event else {
            print("Event not found")
            return
        }
        
        do {
            try eventStore.remove(event, span: .futureEvents)
            print("Event removed successfully")
        } catch {
            print("Failed to remove event: \(error)")
        }
    }
}

