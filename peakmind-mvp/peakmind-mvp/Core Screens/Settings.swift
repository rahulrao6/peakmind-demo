
import SwiftUI
import HealthKit
import EventKit
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject var eventKitManager: EventKitManager
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var notificationSettings: UNNotificationSettings?
    @State private var showHealthSettingsAlert = false
    @State private var showDeleteConfirmation = false
    @State private var deleteConfirmationText = ""
    @State private var showScreen = false  // State to trigger fullScreenCover

    
    var body: some View {
        Form {
            Section {
                Button(action: {
                    showScreen = true  // Trigger the fullScreenCover
                }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.blue)
                        Text("Play Tutorial")
                            .foregroundColor(.blue)
                    }
                }
            }
            .fullScreenCover(isPresented: $showScreen) {
                TutorialScene(isShowingTutorial: $showScreen).environmentObject(viewModel)  // Presenting the full-screen cover
            }
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
            
            Section(header: Text("HealthKit Permissions")) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Step Count")
                        .font(.headline)
                    HStack {
                        Text(healthKitManager.isAuthorized ? "Authorized" : "Not Authorized")
                            .foregroundColor(healthKitManager.isAuthorized ? .green : .red)
                        Spacer()
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
            
            Section(header: Text("EventKit Permissions")) {
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
            
            Section(header: Text("Account")) {
                Button {
                    nm.reset()
                    viewModel.signOut()
                } label: {
                    SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
                        .foregroundColor(.black)
                }
                
                Button {
                    showDeleteConfirmation = true
                } label: {
                    SettingsRowView(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: .red)
                        .foregroundColor(.black)
                }
            }
            
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
            setNavigationBarColor()
        }
        .alert(isPresented: $showHealthSettingsAlert) {
            Alert(
                title: Text("Cannot Open Health Settings"),
                message: Text("Please navigate to the Health app manually to manage your HealthKit permissions."),
                dismissButton: .default(Text("OK"))
            )
        }
        .overlay(
            Group {
                if showDeleteConfirmation {
                    DeleteConfirmationModal(
                        isPresented: $showDeleteConfirmation,
                        confirmationText: $deleteConfirmationText,
                        onDelete: {
                            Task {
                                try await viewModel.deleteAccount()
                                try await deleteAllData()
                            }
                        }
                    )
                }
            }
        )
        .preferredColorScheme(.light) // Disable dark mode by enforcing light mode
    }
    func setNavigationBarColor() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        UINavigationBar.appearance().tintColor = .black
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    func fetchNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationSettings = settings
            }
        }
    }
    
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
    
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func openHealthSettings() {
        if let healthSettingsURL = URL(string: "x-apple-health://") {
            if UIApplication.shared.canOpenURL(healthSettingsURL) {
                UIApplication.shared.open(healthSettingsURL)
            } else {
                showHealthSettingsAlert = true
            }
        }
    }
    
    func deleteAllData() async throws {
        // Implement the deletion logic here
        print("All data deleted")
    }
}



import SwiftUI

struct DeleteConfirmationModal: View {
    @Binding var isPresented: Bool
    @Binding var confirmationText: String
    var onDelete: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Confirm Deletion")
                .font(.headline)
                .padding(.top)

            Text("Type DELETE to confirm you want to delete all data.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            TextField("Type DELETE to confirm", text: $confirmationText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            HStack {
                Button(action: {
                    if confirmationText.uppercased() == "DELETE" {
                        onDelete()
                        isPresented = false
                    }
                }) {
                    Text("Delete")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .disabled(confirmationText.uppercased() != "DELETE")

                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding(.horizontal, 40)
        .frame(maxWidth: 400, maxHeight: 300)
    }
}
