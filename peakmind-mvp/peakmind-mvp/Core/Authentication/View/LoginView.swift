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
    @EnvironmentObject var viewModel: AuthViewModel

    
    var body: some View {
        NavigationStack {
            VStack{
                //image
                HStack {
                    Text("PeakMinds")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    Image("PM Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 135, height: 135)
                    
                    
                }
                
                
                // form fields
                
                VStack(spacing: 24) {
                    InputView(text: $email, title: "Email Address", placeholder: "Enter Your Email", isSecureField: false)
                        .autocapitalization(.none)
                    
                    InputView(text: $password, title: "Password", placeholder: "Enter Your Password", isSecureField: true)
                    
                    NavigationLink {
                        ResetPasswordView()
                            .navigationBarBackButtonHidden(true)
                        
                    } label: {
                        Text("Forgot your password?")
                            .font(.footnote)
                            .foregroundColor(Color.black)
                        //.padding(.top, -20)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                
                //sign in button
                
                HStack(alignment: .center) {
                    Button {
                        Task {
                            try await viewModel.signIn(withEmail: email, password: password)
                        }
                    } label: {
                        HStack {
                            Text("Sign In")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .frame(width: UIScreen.main.bounds.width - 80, height: 48)
                        .background(Color.black)
                        .disabled(!formIsValid)
                        .opacity(formIsValid ? 1.0 : 0.5)
                        .cornerRadius(10)
                        .padding(.top, 24)
                    }
                    
                    
                    
                    Button {
                        Task {
                            do {
                                //let googleAuth = GoogleAuthenticationStruct()
                                try await viewModel.signinWithGoogle()
                            } catch let e {
                                print(e.localizedDescription)
                            }
                        }
                    } label: {
                        HStack {
                            Image("google")
                                .resizable()
                                .frame(width: 40, height: 40)
                            //Text("Sign in with Google")
                        }
                        .padding(8)
                        .frame(width: 40, height: 40)
                        .padding(.top, 24)

                        
                    }
                    
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

extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@") && !password.isEmpty && password.count > 5
    }
    
    
}

#Preview {
    LoginView()
}
