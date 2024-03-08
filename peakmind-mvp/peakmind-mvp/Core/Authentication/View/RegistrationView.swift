//
//  RegistrationView.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 2/17/24.
//

import SwiftUI

struct RegistrationView: View {
    
    @State private var email = ""
    @State private var full_name = ""
    @State private var location = ""
    @State private var username = ""
    @State private var color_raw = Color.blue
    @State private var firstPeak = ""
    @State private var hasCompletedInitialQuiz = false

    let avatarOptions = ["Asian", "Indian", "White"]
    let backgroundOptions = ["Pink Igloo", "Orange Igloo", "Blue Igloo", "Navy Igloo"]
    @State private var selectedAvatar = "Asian"
    @State private var selectedBackground = "Blue Igloo"
    
    var color_hex: String {
        let hexColor = color_raw.toHex()
        return hexColor ?? "#FFF"
    }
    @State private var password = ""
    @State private var confirm_password = ""
    @State private var showAvatarSelection: Bool = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    
    var body: some View {
        
    
        VStack{
            //title
            HStack {
                Text("Register Your Account")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .bold()
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    .padding()
                
                Image(systemName: "brain.head.profile")
                    .imageScale(.large)
                    .font(.title)
                    .padding()
                    
                
                
            }
            ScrollView {
                //form fields
                VStack(spacing: 24) {
                    InputView(text: $email, title: "Email Address", placeholder: "Enter your email", isSecureField: false)
                        .autocapitalization(.none)
                    
                    InputView(text: $username, title: "Username", placeholder: "Enter your username", isSecureField: false)
                    
                    InputView(text: $full_name, title: "Full Name", placeholder: "Enter your name", isSecureField: false)
                    
                    InputView(text: $location, title: "City", placeholder: "Enter your city", isSecureField: false)
                    
                    InputView(text: $firstPeak, title: "First Peak To Tackle?", placeholder: "", isSecureField: false, isPickerField: true, pickerOptions: ["Anxiety", "Depression", "Anger Issues", "Self Help", "Eating Disorders"])
                    
//                    ColorPicker("Choose a background color:", selection: $color_raw)
//                        .foregroundColor(Color(.black))
//                        .fontWeight(.semibold)
//                        .font(.system(size: 18))
                    

                    InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                    
                    ZStack(alignment: .bottomTrailing) {
                        InputView(text: $confirm_password, title: "Confirm Password", placeholder: "Confirm your password", isSecureField: true)
                        
                        if !password.isEmpty && !confirm_password.isEmpty {
                            if password == confirm_password {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.systemGreen))
                                    .padding(.bottom, 4)
                                    .padding(.trailing, 4)
                            } else {
                                Image(systemName: "xmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.systemRed))
                                    .padding(.bottom, 4)
                                    .padding(.trailing, 4)


                            }
                        }
                    }

                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
            
            
            
            VStack {
                Button {
                    print("Sign User Up")
                    showAvatarSelection = true;
                    Task {
                        try await viewModel.createUser(withEmail: email, password: password, fullname: full_name, location: location, color: color_hex, firstPeak: firstPeak, username: username, selectedAvatar: selectedAvatar, selectedBackground: selectedBackground, hasCompletedInitialQuiz: hasCompletedInitialQuiz)
                    }
                    
                } label: {
                    HStack {
                        Text("Next")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                    .background(Color.black)
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1 : 0.5)
                    .cornerRadius(10)
                    .padding(.top, 24)
            }
            }
            .sheet(isPresented: $showAvatarSelection) {
                AvatarSettingsView()
            }
            
            //Spacer()
            
            Button {
                dismiss()
            } label: {
                HStack(spacing: 2) {
                    Text("Already have an account?")
                    Text("Sign In")
                        .fontWeight(.bold)
                }
                .font(.system(size: 16))
                .padding(.top)
                
                
            }
        }
    }
}

extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@") && !password.isEmpty && password.count > 5 && password == confirm_password && !full_name.isEmpty
    }
    
    
}

#Preview {
    RegistrationView()
}
