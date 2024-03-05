//
//  SplashScreen.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 2/29/24.
//

import SwiftUI

struct SplashScreen: View {
    @State private var scale: CGFloat = 1 // Initial scale for the logo

    var body: some View {
        ZStack {
            // Background Image
            Image("Login2") // Replace "BackgroundImage" with your actual background image name
                .resizable()
                .edgesIgnoringSafeArea(.all) // Make the background fill the entire screen

            // Logo Image
            Image("PM Logo") // Replace "LogoImage" with your actual logo image name
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100) // Initial size of the logo
                .scaleEffect(scale) // Apply scaling
                .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 2)
                .onAppear {
                    withAnimation(.easeIn(duration: 2)) {
                        self.scale = 4.5 // End scale for the logo, adjust as needed
                    }
                }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}

