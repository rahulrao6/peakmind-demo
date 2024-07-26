//
//  CustomButton.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 2/26/24.
//

import SwiftUI

// MARK: Reusable Custom Button
struct CustomButton: View {
    var title: String
    var onClick: () -> ()
    
    var body: some View {
        Button(action: onClick) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .foregroundColor(.white)
                .background(Color("Medium Blue"))
                .cornerRadius(10)
        }
        .padding(.horizontal, 15)
    }
}

struct CustomButton2: View {
    var title: String
    var onClick: () -> ()
    
    var body: some View {
        Button(action: onClick) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .foregroundColor(.darkBlue)  // Make sure the foreground color contrasts well with the gradient
                .background(LinearGradient(gradient: Gradient(colors: [.white, Color("Ice Blue")]), startPoint: .top, endPoint: .bottom))
                .cornerRadius(10)
        }
        .padding(.horizontal, 15)
    }
}

struct CustomButton3: View {
    var title: String
    var onClick: () -> ()

    var body: some View {
        Button(action: onClick) {
            Text(title)
                .font(.body) // Smaller font size for the button text
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10) // Padding for the button's vertical size
                .foregroundColor(.black) // Text color set to white for contrast
                .background(Color("Ice Blue")) // Background color set to "Dark Blue"
                .cornerRadius(8) // Corner radius for the button
        }
        .padding(.horizontal, 10) // Horizontal padding around the button
    }
}
