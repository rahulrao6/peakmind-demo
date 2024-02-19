//
//  peakmind_mvpApp.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 2/12/24.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      

    return true
  }
}



@main
struct peakmind_mvpApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var viewModel = AuthViewModel()
    
    
  var body: some Scene {
    WindowGroup {
      NavigationView {
          ContentView()
              .environmentObject(viewModel)
      }
    }
  }
}
