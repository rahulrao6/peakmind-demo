//
//  LoginView.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 2/17/24.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""

    
    var body: some View {
        NavigationStack {
            VStack{
                //image
                Text("Welcome to PeakMinds!")
                    .bold()
                    .frame(width: .infinity, height: 100)
                    .cornerRadius(15)
                    .padding()
                    .background(.black)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                
                // form fields
                
                VStack(spacing: 24) {
                    InputView(text: $email, title: "Email Address", placeholder: "Enter Your Email", isSecureField: false)
                        .autocapitalization(.none)
                    
                    InputView(text: $password, title: "Password", placeholder: "Enter Your Password", isSecureField: true)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                
                //sign in button
                
                Button {
                    print("Log User In")
                    
                } label: {
                    HStack {
                        Text("Sign In")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                    .background(Color.black)
                    .cornerRadius(10)
                    .padding(.top, 24)
                }


                
                Spacer()
                
                //sign up button
                
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 2) {
                        Text("Don't have an account?")
                        Text("Sign Up")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 16))
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
