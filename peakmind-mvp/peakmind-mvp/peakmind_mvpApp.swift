
import SwiftUI
import FirebaseCore
import GoogleSignIn
import HealthKit

import SwiftUI
import FirebaseCore
import GoogleSignIn
import UserNotifications
import EventKit
import Pendo


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    let eventStore = EKEventStore()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
//        PendoManager.shared().setup("eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhY2VudGVyIjoidXMiLCJrZXkiOiJmN2M1NzVmODNkNDhkOTQ1M2JlMjM4ZjBjNjUwYTQxNzBlMTI2NGYyZmE0NmMxMTg0NzRjY2E4NTlhNzFiN2ZhMzI3NzNkOTc0NDg1NzljNjVmMjBiZTZkZWJjMjA4Mjc1NDgwMmY4MTZlZmFjNGFjN2NjNDUyNDUwMmIxYzMxMTZiZmE4ODFlYTUzM2ViZWRjZjBlZjJkMjI5N2Q1NjIyOGY5MmRkNDdkMzRlYzNjNDMyMzAyYTYzYjE4N2I2NmIwNWVkMDk0MmQzNzQ5ODU4NTczYTMyZTJlOTA0YzQwZGMyZTdlNDFmZWEzNjIxZDU1Zjc3MzNiYTE1NWM5OGEyNmI2MTVmNjJlN2UzYjcxMzBiMzM4ZTNmYTIxMjMzN2YuODlhOTBjMmI4OWVmZmExNGU4M2RjNzEwMzk2YjY1YTAuYzAwNDQxNTQxMDRiZmRjYmFmZDcxMjU4ZThlYzMzOTdhNjA5MGQ5M2FhZTkyYjM5ZGY0ZWZkYzE4MWNjNWFkNCJ9.GvEo5mEc8ota3tSD_S96vjIGztJH9EjcnZHAXcufAiKJz88iRLLJHJMjMceD0yZKylVk5EA6b-Ie81cidZ8poXKhZzU8utlHycnq1eaBFEpXsLJd4MQV5CBZp_wuBPnkk5GeRPDtOgxEf8J5HEqqbATSv_krbZmszN8sW4oOm4o")

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
        if url.scheme?.range(of: "pendo") != nil {
            PendoManager.shared().initWith(url)
            return true
        }
        print("Handling URL: \(url)")
        let handled = GIDSignIn.sharedInstance.handle(url)
        print("URL handled: \(handled)")
        if handled {
            // Store the last login time
            UserDefaults.standard.set(Date(), forKey: "LastLoginTime")
            print("Last login time updated.")
        }

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
        completionHandler([.banner, .sound])
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
    
    @StateObject var HealthKitManager1 = HealthKitManager()
    @StateObject var EventKitManager1 = EventKitManager()


    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(viewModel)
                    .environmentObject(HealthKitManager1)
                    .environmentObject(EventKitManager1)

                    .onAppear {
                        // Example of scheduling a notification
                        //scheduleNotificationsBasedOnLastLogin()
                    }
                
            }
            //       .pendoEnableSwiftUI()
            .onOpenURL(perform: handleURL)
        }

    }
    
    func handleURL(_ url: URL) {
        _ = delegate.application(UIApplication.shared, open: url, options: [:])

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
    
    
    func getLastLoginDate() -> Date? {

        guard let user = Auth.auth().currentUser else { return nil } // Check if a user is signed in

        return user.metadata.lastSignInDate

    }
    
    // Function to calculate time intervals and schedule notifications
    func scheduleNotificationsBasedOnLastLogin() {
        guard let lastLogin = getLastLoginDate() else {
            print("No last login time found.")
            return
        }
        
        let now = Date()
        let timeSinceLastLogin = now.timeIntervalSince(lastLogin) // in seconds
        print(lastLogin);
        print(timeSinceLastLogin)
        // Schedule notifications based on the time since the last login
        if timeSinceLastLogin <= 12 * 3600 {
            // Schedule notification for "Last Use <12 Hours"
            scheduleNotification(forSegment: "Last Use <12 Hours", withMessage: "Check in with PeakMind", timeInterval: 1 * 24 * 3600)
        } else if timeSinceLastLogin <= 1.5 * 24 * 3600 {
            // Schedule notification for "Last Use <1.5 Days"
            scheduleNotification(forSegment: "Last Use <1.5 Days", withMessage: "Your mental health matters!", timeInterval: 6 * 3600)
        } else if timeSinceLastLogin <= 3 * 24 * 3600 {
            // Schedule notification for "Last Use <3 Days"
            scheduleNotification(forSegment: "Last Use <3 Days", withMessage: "Don't forget your self-care routine!", timeInterval: 6 * 3600)
        } else if timeSinceLastLogin <= 7 * 24 * 3600 {
            // Schedule notification for "Last Use <7 Days"
            scheduleNotification(forSegment: "Last Use <7 Days", withMessage: "Did you forget about self care?", timeInterval: 24 * 3600)
        } else if timeSinceLastLogin <= 21 * 24 * 3600 {
            // Schedule notification for "Last Use <21 Days"
            scheduleNotification(forSegment: "Last Use <21 Days", withMessage: "Come back, your mental health needs you!", timeInterval: 24 * 3600)
        } else if timeSinceLastLogin <= 60 * 24 * 3600 {
            // Schedule notification for "Last Use <60 Days"
            scheduleNotification(forSegment: "Last Use <60 Days", withMessage: "Refresh yourself with PeakMind!", timeInterval: 72 * 3600)
        }
    }
    
    // General function to schedule a notification
    func scheduleNotification(forSegment segment: String, withMessage message: String, timeInterval: TimeInterval) {
        let center = UNUserNotificationCenter.current()

        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = message
        content.sound = .default

        // Create a trigger based on the time interval
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)

        // Create the notification request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // Schedule the notification
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for segment \(segment).")
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
        guard let healthStore = healthStore else { return }
        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        healthStore.authorizationStatus(for: stepType) == .sharingAuthorized ? (self.isAuthorized = true) : (self.isAuthorized = false)
        //checkAuthorization()
    }
    
    
    func checkAuthorization() {
        
    }

    func requestAuthorization() {
        let healthDataToRead = Set([
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)! // Active Minutes
        ])

        healthStore?.requestAuthorization(toShare: nil, read: healthDataToRead) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("Authorization error: \(error.localizedDescription)")
                } else {
                    self.isAuthorized = success
                    if success {
                        print("HealthKit authorization granted.")
                        // Start fetching data after authorization
                        //self.fetchHealthData(for: userId, numberOfDays: 7) // Replace 'userId' appropriately
                        self.startStepCountObserverQuery()
                    } else {
                        print("HealthKit authorization denied.")
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
                    self?.liveStepCount = stepCount
                    print("Live step count: \(stepCount)")
                }
            }
        }

        healthStore?.execute(query)
    }

    func fetchHealthData(for userId: String, numberOfDays: Int) {
           guard isAuthorized, let healthStore = healthStore else { return }

           let now = Date()
           let startOfDay = Calendar.current.startOfDay(for: now)
           guard let startDate = Calendar.current.date(byAdding: .day, value: -numberOfDays + 1, to: startOfDay) else { return }
           let endDate = now // Include up to the current time

           fetchStepCount(for: userId, startDate: startDate, endDate: endDate)
            print("getting the sleep now")
           fetchSleepAnalysis(for: userId, startDate: startDate, endDate: endDate)
        print("got the sleep now")

           fetchActiveCalories(for: userId, startDate: startDate, endDate: endDate) // Fetch Active Minutes
       }

        func fetchStepCount(for userId: String, startDate: Date, endDate: Date) {
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


    func fetchSleepAnalysis(for userId: String, startDate: Date, endDate: Date) {
        guard let healthStore = healthStore else {
            print("Health store is not available.")
            return
        }

        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        print("doing sleep analysis")
        
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
            
            print("we have fetched these jaunts")

            for sample in samples {
                let date = Calendar.current.startOfDay(for: sample.startDate)
                let sleepDuration = sample.endDate.timeIntervalSince(sample.startDate)
                print("Sleep Duration for sample \(sample): \(sleepDuration)")
                
                if sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                   sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue {
                    dailySleepData[date, default: 0] += sleepDuration
                }
            }

            for (date, sleepDuration) in dailySleepData {
                let sleepDurationInHours = sleepDuration / 3600
                print("Saving sleep data for \(date): \(sleepDurationInHours) hours")
                self?.saveHealthDataToFirestore(userId: userId, type: "sleepDuration", date: date, data: ["sleepDuration": sleepDurationInHours])
            }
        }
        
        // Execute the query
        healthStore.execute(query)
        print("Query executed.")
    }


        func fetchActiveCalories(for userId: String, startDate: Date, endDate: Date) {
            guard let healthStore = healthStore else { return }

               // Use activeEnergyBurned instead of appleExerciseTime
               guard let activeEnergyBurnedType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
                   print("Active Energy Burned Type is unavailable.")
                   return
               }

               let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
               let query = HKStatisticsCollectionQuery(quantityType: activeEnergyBurnedType, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: startDate, intervalComponents: DateComponents(day: 1))

               query.initialResultsHandler = { [weak self] _, result, error in
                   if let error = error {
                       print("Error fetching active energy burned: \(error.localizedDescription)")
                       return
                   }

                   result?.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                       if let sum = statistics.sumQuantity() {
                           let activeEnergy = sum.doubleValue(for: HKUnit.kilocalorie()) // Active energy is measured in kilocalories
                           let date = statistics.startDate
                           //print("Active energy burned for \(date): \(activeEnergy) kcal")
                           self?.saveHealthDataToFirestore(userId: userId, type: "activeEnergyBurned", date: date, data: ["activeEnergy": activeEnergy])
                       }
                   }
               }
               
               healthStore.execute(query)
       }

       private func saveHealthDataToFirestore(userId: String, type: String, date: Date, data: [String: Any]) {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd"
           let formattedDate = dateFormatter.string(from: date)
//           print("we are firebaseing now")
//           print(userId)
//           print(type)
//           print(date)
           let healthDataRef = db.collection("users").document(userId)
               .collection("healthKitData").document(type)
               .collection("days").document(formattedDate)

           healthDataRef.getDocument { [weak self] document, error in
               if let error = error {
                   print("Error checking for existing health data: \(error.localizedDescription)")
                   return
               }

               if document?.exists == true {
                   print("Data for \(formattedDate) already exists in \(type), skipping save.")
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
import FirebaseAuth

class EventKitManager: ObservableObject {
    let eventStore = EKEventStore()
    static let shared = EventKitManager()
    @Published var isCalendarAuthorized = false
    @Published var isRemindersAuthorized = false
    // Method to request calendar access
    
    
    init() {
        checkAuthorization()
    }

    func checkAuthorization() {
        let calendarStatus = EKEventStore.authorizationStatus(for: .event)
        self.isCalendarAuthorized = (calendarStatus == .authorized)
        
        let reminderStatus = EKEventStore.authorizationStatus(for: .reminder)
        self.isRemindersAuthorized = (reminderStatus == .authorized)
    }

    
    func requestAccess(to entityType: EKEntityType) async -> Bool {
           if #available(iOS 17.0, *) {
               do {
                   switch entityType {
                   case .event:
                       return try await eventStore.requestFullAccessToEvents()
                   case .reminder:
                       return try await eventStore.requestFullAccessToReminders()
                   @unknown default:
                       return false
                   }
               } catch {
                   print("Failed to request \(entityType) access: \(error.localizedDescription)")
                   return false
               }
           } else {
               return await withCheckedContinuation { continuation in
                   eventStore.requestAccess(to: entityType) { granted, error in
                       if let error = error {
                           print("Failed to request \(entityType) access: \(error.localizedDescription)")
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
        let granted = await requestAccess(to: .event)
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
        let granted = await requestAccess(to: .event)
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
    
    func scheduleReminder(title: String, notes: String? = nil, dueDate: Date?, recurrenceRule: EKRecurrenceRule?) async -> String? {
        let granted = await requestAccess(to: .reminder)
        guard granted else {
            print("Reminder access denied")
            return nil
        }
        
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.notes = notes
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        
        if let dueDate = dueDate {
            reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
            let alarm = EKAlarm(absoluteDate: dueDate)
            reminder.addAlarm(alarm)
        }
        
        if let recurrenceRule = recurrenceRule {
            reminder.recurrenceRules = [recurrenceRule]
        }
        
        do {
            try eventStore.save(reminder, commit: true)
            print("Reminder saved successfully")
            return reminder.calendarItemIdentifier
        } catch {
            print("Failed to save reminder: \(error.localizedDescription)")
            return nil
        }
    }
    func createRecurrenceRule(frequency: EKRecurrenceFrequency, interval: Int = 1, endDate: Date? = nil) -> EKRecurrenceRule {
        let recurrenceEnd = endDate != nil ? EKRecurrenceEnd(end: endDate!) : nil
        return EKRecurrenceRule(
            recurrenceWith: frequency,
            interval: interval,
            daysOfTheWeek: nil,
            daysOfTheMonth: nil,
            monthsOfTheYear: nil,
            weeksOfTheYear: nil,
            daysOfTheYear: nil,
            setPositions: nil,
            end: recurrenceEnd
        )
    }
    
    func createRecurrenceRuleForEveryNDays(interval: Int, endDate: Date?) -> EKRecurrenceRule {
        let recurrenceEnd = endDate != nil ? EKRecurrenceEnd(end: endDate!) : nil
        return EKRecurrenceRule(
            recurrenceWith: .daily,
            interval: interval,
            end: recurrenceEnd
        )
    }
    
    func createRecurrenceRuleForSpecificDaysOfWeek(daysOfWeek: [Int], endDate: Date?) -> EKRecurrenceRule {
        let recurrenceEnd = endDate != nil ? EKRecurrenceEnd(end: endDate!) : nil
        let days = daysOfWeek.map { EKRecurrenceDayOfWeek(EKWeekday(rawValue: $0)!) }
        return EKRecurrenceRule(
            recurrenceWith: .weekly,
            interval: 1,
            daysOfTheWeek: days,
            daysOfTheMonth: nil,
            monthsOfTheYear: nil,
            weeksOfTheYear: nil,
            daysOfTheYear: nil,
            setPositions: nil,
            end: recurrenceEnd
        )
    }
}

