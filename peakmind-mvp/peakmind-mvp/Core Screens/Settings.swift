////
////  Settings.swift
////  peakmind-mvp
////
////  Created by Raj Jagirdar on 9/23/24.
////
//
//import Foundation
//import SwiftUI
//import EventKit
//
//struct SettingsView: View {
//    @EnvironmentObject var healthKitManager: HealthKitManager
//    @EnvironmentObject var eventKitManager: EventKitManager
//    @State private var notificationPermissionGranted: Bool = false
//    @State private var healthKitPermissionGranted: Bool = false
//    @State private var calendarPermissionGranted: Bool = false
//    @State private var reminderPermissionGranted: Bool = false
//
//    var body: some View {
//        Form {
//            Section(header: Text("Permissions")) {
//                // HealthKit Permission
//                Toggle(isOn: $healthKitPermissionGranted) {
//                    Text("HealthKit Access")
//                }
//                .onChange(of: healthKitPermissionGranted) { value in
//                    if value {
//                        healthKitManager.requestAuthorization()
//                    }
//                }
//                
//                // Notifications Permission
//                Toggle(isOn: $notificationPermissionGranted) {
//                    Text("Notifications Access")
//                }
//                .onChange(of: notificationPermissionGranted) { value in
//                    if value {
//                        requestNotificationPermission()
//                    }
//                }
//                
//                // Calendar Permission
//                Toggle(isOn: $calendarPermissionGranted) {
//                    Text("Calendar Access")
//                }
//                .onChange(of: calendarPermissionGranted) { value in
//                    if value {
//                        Task {
//                            _ = await eventKitManager.requestAccess(to: .event)
//                        }
//                    }
//                }
//                
//                // Reminder Permission
//                Toggle(isOn: $reminderPermissionGranted) {
//                    Text("Reminders Access")
//                }
//                .onChange(of: reminderPermissionGranted) { value in
//                    Task {
//                        _ = await eventKitManager.requestAccess(to: .reminder)
//                    }
//                }
//            }
//        }
//        .navigationTitle("Settings")
//        .onAppear {
//            checkCurrentPermissions()
//        }
//    }
//    
//    // Check the current permissions
//    func checkCurrentPermissions() {
//        // Check HealthKit status
//        healthKitPermissionGranted = healthKitManager.isAuthorized
//        
//        // Check Notification status
//        UNUserNotificationCenter.current().getNotificationSettings { settings in
//            DispatchQueue.main.async {
//                self.notificationPermissionGranted = settings.authorizationStatus == .authorized
//            }
//        }
//
//        // Check Calendar and Reminder permissions
//        let calendarStatus = EKEventStore.authorizationStatus(for: .event)
//        self.calendarPermissionGranted = calendarStatus == .authorized
//        let reminderStatus = EKEventStore.authorizationStatus(for: .reminder)
//        self.reminderPermissionGranted = reminderStatus == .authorized
//    }
//
//    // Request Notification permissions
//    func requestNotificationPermission() {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            DispatchQueue.main.async {
//                self.notificationPermissionGranted = granted
//            }
//        }
//    }
//}

import SwiftUI
import HealthKit
import EventKit
import UserNotifications

struct SettingsView: View {
    // Inject HealthKitManager, EventKitManager, and AuthViewModel from the environment
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject var eventKitManager: EventKitManager
    @EnvironmentObject var viewModel: AuthViewModel
    
    // State to hold the current notification settings
    @State private var notificationSettings: UNNotificationSettings?
    
    // State to control the display of the alert
    @State private var showHealthSettingsAlert = false
    
    var body: some View {
            Form {
                // User Profile Section
                if let user = viewModel.currentUser {
                    Section {
                        HStack {
                            Text(user.initials)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 72, height: 72)
                                .background(Color.blue)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.username)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.top, 4)
                                
                                Text(user.email)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                // HealthKit Permissions Section
                Section(header: Text("HealthKit Permissions")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Step Count")
                            .font(.headline)
                        HStack {
                            // Display current authorization status
                            Text(healthKitManager.isAuthorized ? "Authorized" : "Not Authorized")
                                .foregroundColor(healthKitManager.isAuthorized ? .green : .red)
                            Spacer()
                            // Button to request HealthKit authorization
                            Button(action: {
                                healthKitManager.requestAuthorization()
                            }) {
                                Text(healthKitManager.isAuthorized ? "Reauthorize" : "Authorize")
                                    .foregroundColor(healthKitManager.isAuthorized ? .green : .red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        Text("Allows the app to read your step count data.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // Button to open Health Settings
                    Button(action: {
                        openHealthSettings()
                    }) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.blue)
                            Text("Open Health Settings")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // EventKit Permissions Section
                Section(header: Text("EventKit Permissions")) {
                    // Calendars Permissions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Calendars")
                            .font(.headline)
                        HStack {
                            Text(eventKitManager.isCalendarAuthorized ? "Authorized" : "Not Authorized")
                                .foregroundColor(eventKitManager.isCalendarAuthorized ? .green : .red)
                            Spacer()
                            Button(action: {
                                Task {
                                    await eventKitManager.requestAccess(to: .event)
                                    fetchNotificationSettings()
                                }
                            }) {
                                Text(eventKitManager.isCalendarAuthorized ? "Reauthorize" : "Authorize")
                                    .foregroundColor(eventKitManager.isCalendarAuthorized ? .green : .red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        Text("Allows the app to access your calendars.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // Reminders Permissions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Reminders")
                            .font(.headline)
                        HStack {
                            Text(eventKitManager.isRemindersAuthorized ? "Authorized" : "Not Authorized")
                                .foregroundColor(eventKitManager.isRemindersAuthorized ? .green : .red)
                            Spacer()
                            Button(action: {
                                Task {
                                    await eventKitManager.requestAccess(to: .reminder)
                                    fetchNotificationSettings()
                                }
                            }) {
                                Text(eventKitManager.isRemindersAuthorized ? "Reauthorize" : "Authorize")
                                    .foregroundColor(eventKitManager.isRemindersAuthorized ? .green : .red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        Text("Allows the app to access your reminders.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                // Notifications Permissions Section
                Section(header: Text("Notifications Permissions")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Notifications")
                            .font(.headline)
                        HStack {
                            Text(notificationSettings?.authorizationStatus == .authorized ? "Authorized" : "Not Authorized")
                                .foregroundColor(notificationSettings?.authorizationStatus == .authorized ? .green : .red)
                            Spacer()
                            Button(action: {
                                requestNotificationPermissions()
                                fetchNotificationSettings()
                            }) {
                                Text(notificationSettings?.authorizationStatus == .authorized ? "Reauthorize" : "Authorize")
                                    .foregroundColor(notificationSettings?.authorizationStatus == .authorized ? .green : .red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        Text("Allows the app to send you notifications.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                // Account Section
                Section(header: Text("Account")) {
                    Button {
                        viewModel.signOut()
                    } label: {
                        SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
                            .foregroundColor(.black)
                    }
                    
                    Button {
                        Task {
                            try await viewModel.deleteAccount()
                        }
                    } label: {
                        SettingsRowView(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: .red)
                            .foregroundColor(.black)
                    }
                }
                
                // General Settings Section
                Section(header: Text("General")) {
                    Button(action: {
                        openAppSettings()
                    }) {
                        HStack {
                            Image(systemName: "gearshape")
                                .foregroundColor(.black)
                            Text("Open System Settings")
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                fetchNotificationSettings()
                healthKitManager.checkAuthorization()
                eventKitManager.checkAuthorization()
            }
            .alert(isPresented: $showHealthSettingsAlert) {
                Alert(
                    title: Text("Cannot Open Health Settings"),
                    message: Text("Please navigate to the Health app manually to manage your HealthKit permissions."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        
        // MARK: - Helper Methods
        
        /// Fetches the current notification settings.
        func fetchNotificationSettings() {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    self.notificationSettings = settings
                }
            }
        }
        
        /// Requests notification permissions from the user.
        func requestNotificationPermissions() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                DispatchQueue.main.async {
                    fetchNotificationSettings()
                    if let error = error {
                        print("Failed to request notification permissions: \(error.localizedDescription)")
                    } else if granted {
                        print("Notification permission granted.")
                    } else {
                        print("Notification permission denied.")
                    }
                }
            }
        }
        
        /// Opens the app's settings in the system Settings app.
        func openAppSettings() {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        
        /// Attempts to open the Health app's settings.
        func openHealthSettings() {
            if let healthSettingsURL = URL(string: "x-apple-health://") {
                if UIApplication.shared.canOpenURL(healthSettingsURL) {
                    UIApplication.shared.open(healthSettingsURL)
                } else {
                    // Show alert to inform user
                    showHealthSettingsAlert = true
                }
            }
        }
    }

