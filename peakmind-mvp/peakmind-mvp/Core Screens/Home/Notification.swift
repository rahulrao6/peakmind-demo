//
//  Notification.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 11/10/24.
//

import Foundation
import UserNotifications
import Firebase
// UserMeta model to handle metadata
struct UserMeta: Codable {
    let userId: String
    var lastLoginDate: Date
    var lastNotificationDate: Date?
    var notificationPreferences: NotificationPreferences
    var checkInTime: Date?  // User's preferred check-in time
    var notificationHistory: [NotificationRecord]
    var streakCount: Int
    
    struct NotificationPreferences: Codable {
        var dailyCheckInEnabled: Bool
        var inactivityAlertsEnabled: Bool
        var weeklyProgressEnabled: Bool
        var preferredCheckInHour: Int  // 24-hour format
    }
    
    struct NotificationRecord: Codable {
        let type: String
        let sentDate: Date
        let interactionStatus: String?  // opened, ignored, etc.
    }
}

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    private let db = Firestore.firestore()
    
    @Published var isPermissionGranted = false
    
    // Notification Types
    enum NotificationType: String {
        case dailyCheckIn = "daily_checkin"
        case shortInactivity = "short_inactivity"
        case mediumInactivity = "medium_inactivity"
        case longInactivity = "long_inactivity"
        case weeklyProgress = "weekly_progress"
        case streakReminder = "streak_reminder"
    }
    
    override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    // Fetch and update user meta
    func fetchUserMeta(userId: String) async throws -> UserMeta? {
        let docRef = db.collection("meta").document(userId)
        let snapshot = try await docRef.getDocument()
        
        if let data = snapshot.data() {
            // Convert Firestore data to UserMeta
            let lastLogin = (data["lastLoginDate"] as? Timestamp)?.dateValue() ?? Date()
            let preferences = UserMeta.NotificationPreferences(
                dailyCheckInEnabled: data["dailyCheckInEnabled"] as? Bool ?? true,
                inactivityAlertsEnabled: data["inactivityAlertsEnabled"] as? Bool ?? true,
                weeklyProgressEnabled: data["weeklyProgressEnabled"] as? Bool ?? true,
                preferredCheckInHour: data["preferredCheckInHour"] as? Int ?? 20
            )
            
            return UserMeta(
                userId: userId,
                lastLoginDate: lastLogin,
                lastNotificationDate: (data["lastNotificationDate"] as? Timestamp)?.dateValue(),
                notificationPreferences: preferences,
                checkInTime: (data["checkInTime"] as? Timestamp)?.dateValue(),
                notificationHistory: [],
                streakCount: data["streakCount"] as? Int ?? 0
            )
        }
        return nil
    }
    
    // Schedule all relevant notifications based on user meta
    func scheduleAllNotifications(for userMeta: UserMeta) async {
        // Clear existing notifications
        await notificationCenter.removeAllPendingNotificationRequests()
        
        // Check if notifications are allowed
        let settings = await notificationCenter.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }
        
        if userMeta.notificationPreferences.dailyCheckInEnabled {
            await scheduleDailyCheckIn(userMeta: userMeta)
        }
        
        if userMeta.notificationPreferences.inactivityAlertsEnabled {
            await scheduleInactivityReminders(userMeta: userMeta)
        }
        
        if userMeta.notificationPreferences.weeklyProgressEnabled {
            await scheduleWeeklyProgress(userMeta: userMeta)
        }
        
        // Schedule streak maintenance reminder if needed
        if userMeta.streakCount > 0 {
            await scheduleStreakReminder(userMeta: userMeta)
        }
    }
    
    // Schedule daily check-in notification
    private func scheduleDailyCheckIn(userMeta: UserMeta) async {
        let content = UNMutableNotificationContent()
        content.title = "Time for Your Daily Check-in"
        content.body = "Maintain your streak of \(userMeta.streakCount) days!"
        content.sound = .default
        
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: Date())
        dateComponents.hour = userMeta.notificationPreferences.preferredCheckInHour
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: NotificationType.dailyCheckIn.rawValue,
            content: content,
            trigger: trigger
        )
        
        try? await notificationCenter.add(request)
    }
    
    // Schedule inactivity reminders
    private func scheduleInactivityReminders(userMeta: UserMeta) async {
        let daysSinceLastLogin = Calendar.current.dateComponents(
            [.day],
            from: userMeta.lastLoginDate,
            to: Date()
        ).day ?? 0
        
        let content = UNMutableNotificationContent()
        content.sound = .default
        
        // Different notification content based on inactivity duration
        if daysSinceLastLogin >= 3 && daysSinceLastLogin < 7 {
            content.title = "We Miss You!"
            content.body = "It's been 3 days since your last check-in. Don't break your streak!"
            await scheduleInactivityNotification(content: content, type: .shortInactivity)
        }
        
        if daysSinceLastLogin >= 7 && daysSinceLastLogin < 14 {
            content.title = "Your Progress Needs You!"
            content.body = "A week without check-ins. Let's get back on track!"
            await scheduleInactivityNotification(content: content, type: .mediumInactivity)
        }
        
        if daysSinceLastLogin >= 14 {
            content.title = "Time to Restart Your Journey"
            content.body = "We're here to support you. Come back and continue your progress!"
            await scheduleInactivityNotification(content: content, type: .longInactivity)
        }
    }
    
    // Helper function for inactivity notifications
    private func scheduleInactivityNotification(content: UNNotificationContent, type: NotificationType) async {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false) // 1 hour delay
        let request = UNNotificationRequest(identifier: type.rawValue, content: content, trigger: trigger)
        try? await notificationCenter.add(request)
    }
    
    // Schedule weekly progress notification
    private func scheduleWeeklyProgress(userMeta: UserMeta) async {
        let content = UNMutableNotificationContent()
        content.title = "Weekly Progress Review"
        content.body = "Check out your achievements this week!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.weekday = 7 // Saturday
        dateComponents.hour = 18 // 6 PM
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: NotificationType.weeklyProgress.rawValue,
            content: content,
            trigger: trigger
        )
        
        try? await notificationCenter.add(request)
    }
    
    // Schedule streak maintenance reminder
    private func scheduleStreakReminder(userMeta: UserMeta) async {
        let content = UNMutableNotificationContent()
        content.title = "Protect Your Streak!"
        content.body = "Don't forget to check in today to maintain your \(userMeta.streakCount)-day streak!"
        content.sound = .default
        
        // Schedule for late afternoon if haven't checked in yet
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: Date())
        dateComponents.hour = 16 // 4 PM
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: NotificationType.streakReminder.rawValue,
            content: content,
            trigger: trigger
        )
        
        try? await notificationCenter.add(request)
    }
    
    // Record notification interaction
    func recordNotificationInteraction(userId: String, type: NotificationType, status: String) async {
        let record = [
            "type": type.rawValue,
            "sentDate": Timestamp(date: Date()),
            "interactionStatus": status
        ] as [String : Any]
        
        try? await db.collection("meta").document(userId)
            .updateData([
                "notificationHistory": FieldValue.arrayUnion([record]),
                "lastNotificationDate": Timestamp(date: Date())
            ])
    }
}


// Extension for AuthViewModel to handle meta updates
extension AuthViewModel {
    func updateUserMeta() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            if var userMeta = try await NotificationManager.shared.fetchUserMeta(userId: userId) {
                userMeta.lastLoginDate = Date()
                
                // Update meta in Firestore
                let metaData: [String: Any] = [
                    "lastLoginDate": Timestamp(date: Date()),
                    "streakCount": userMeta.streakCount,
                    "dailyCheckInEnabled": userMeta.notificationPreferences.dailyCheckInEnabled,
                    "inactivityAlertsEnabled": userMeta.notificationPreferences.inactivityAlertsEnabled,
                    "weeklyProgressEnabled": userMeta.notificationPreferences.weeklyProgressEnabled,
                    "preferredCheckInHour": userMeta.notificationPreferences.preferredCheckInHour
                ]
                
                try await Firestore.firestore()
                    .collection("meta")
                    .document(userId)
                    .setData(metaData, merge: true)
                
                // Schedule notifications based on updated meta
                await NotificationManager.shared.scheduleAllNotifications(for: userMeta)
            }
        } catch {
            print("Error updating user meta: \(error)")
        }
    }
}
