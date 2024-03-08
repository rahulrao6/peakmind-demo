//
//  ProfileView.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 2/17/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel : AuthViewModel
    var body: some View {
        if let user = viewModel.currentUser {
            List {
                Section {
                    HStack {
                        Text(user.initials)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color.init(hex: user.color))
                        //.background(Color(.systemGray3))
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        
                        VStack (alignment: .leading, spacing: 4) {
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
                        
                        Text("100%")
                    }
                    
                    
                    
                }
                
                Section("General") {
                    HStack {
                        SettingsRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
                        
                        Spacer()
                        
                        Text("1.0.0")
                    }
                    
                }
                
                Section("Account") {
                    
                    Button {
                        viewModel.signOut()
                    } label: {
                        SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
                    }
                    
                    Button {
                        viewModel.deleteAccount()
                    } label: {
                        SettingsRowView(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: .red)
                    }
                    
                }
                
            }
        }
    }
}
