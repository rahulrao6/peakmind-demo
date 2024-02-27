//
//  ProfileViewTest.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 2/27/24.
//

import SwiftUI

struct ProfileViewTest: View {
    // Hardcoded user data for UI design purposes
    let user = DemoUser(
        initials: "JD",
        fullname: "John Doe",
        location: "San Francisco, CA",
        email: "johndoe@example.com",
        color: "007AFF", // Example hex color
        firstPeak: "Mindfulness"
    )

    var body: some View {
        List {
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
                        Text(user.fullname)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.top, 4)
                        Text(user.location)
                            .font(.footnote)
                            .foregroundColor(.black)
                        
                        Text(user.email)
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Section("Peaks") {
                HStack {
                    SettingsRowView(imageName: "person.fill.questionmark", title: user.firstPeak, tintColor: Color(.systemGray))
                    
                    Spacer()
                    
                    Text("11%")
                }
            }
            
            Section("General") {
                HStack {
                    SettingsRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
                    
                    Spacer()
                    
                    Text("1.0.0")
                }
                // Assuming IglooScreen is a placeholder for another view
                NavigationLink(destination: Text("Igloo Screen Placeholder")) {
                    SettingsRowView(imageName: "bubble.left.and.text.bubble.right.fill", title: "Chat with Sherpa", tintColor: Color(.systemGray))
                }
            }
            
            Section("Account") {
                Button("Sign Out") {
                    // Action for sign out
                }
                .foregroundColor(.red)
                
                Button("Delete Account") {
                    // Action for delete account
                }
                .foregroundColor(.red)
            }
        }
    }
}

// Define a simple User struct for the hardcoded data
struct DemoUser {
    var initials: String
    var fullname: String
    var location: String
    var email: String
    var color: String
    var firstPeak: String
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileViewTest()
    }
}

