//
//  peakmind_mvpApp.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 2/12/24.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      

    return true
  }
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])
      -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}



@main
struct peakmind_mvpApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var viewModel = AuthViewModel()
    @StateObject var router = Router()
    @StateObject var journalDataManager = JournalDataManager() // Instantiate JournalDataManager

    
    
  var body: some Scene {
    WindowGroup {
      NavigationView {
          ContentView()
              .environmentObject(viewModel)
              .environmentObject(journalDataManager) // Provide JournalDataManager
                        

      }
    }
  }
}
