//
//  Settings.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 9/23/24.
//

import Foundation
import SwiftUI
import EventKit

struct SettingsView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject var eventKitManager: EventKitManager
    @State private var notificationPermissionGranted: Bool = false
    @State private var healthKitPermissionGranted: Bool = false
    @State private var calendarPermissionGranted: Bool = false
    @State private var reminderPermissionGranted: Bool = false

    var body: some View {
        Form {
            Section(header: Text("Permissions")) {
                // HealthKit Permission
                Toggle(isOn: $healthKitPermissionGranted) {
                    Text("HealthKit Access")
                }
                .onChange(of: healthKitPermissionGranted) { value in
                    if value {
                        healthKitManager.requestAuthorization()
                    }
                }
                
                // Notifications Permission
                Toggle(isOn: $notificationPermissionGranted) {
                    Text("Notifications Access")
                }
                .onChange(of: notificationPermissionGranted) { value in
                    if value {
                        requestNotificationPermission()
                    }
                }
                
                // Calendar Permission
                Toggle(isOn: $calendarPermissionGranted) {
                    Text("Calendar Access")
                }
                .onChange(of: calendarPermissionGranted) { value in
                    if value {
                        Task {
                            _ = await eventKitManager.requestAccess(to: .event)
                        }
                    }
                }
                
                // Reminder Permission
                Toggle(isOn: $reminderPermissionGranted) {
                    Text("Reminders Access")
                }
                .onChange(of: reminderPermissionGranted) { value in
                    Task {
                        _ = await eventKitManager.requestAccess(to: .reminder)
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            checkCurrentPermissions()
        }
    }
    
    // Check the current permissions
    func checkCurrentPermissions() {
        // Check HealthKit status
        healthKitPermissionGranted = healthKitManager.isAuthorized
        
        // Check Notification status
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationPermissionGranted = settings.authorizationStatus == .authorized
            }
        }

        // Check Calendar and Reminder permissions
        let calendarStatus = EKEventStore.authorizationStatus(for: .event)
        self.calendarPermissionGranted = calendarStatus == .authorized
        let reminderStatus = EKEventStore.authorizationStatus(for: .reminder)
        self.reminderPermissionGranted = reminderStatus == .authorized
    }

    // Request Notification permissions
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.notificationPermissionGranted = granted
            }
        }
    }
}
