//
//  ContentView.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 2/12/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        Group {
            if viewModel.userSession != nil && viewModel.currentUser != nil {
                MainScreenView()
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
}
