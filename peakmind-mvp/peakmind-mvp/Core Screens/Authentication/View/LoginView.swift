//
//  LoginView.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 2/17/24.
//

import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel

    
    var body: some View {
        NavigationStack {
            VStack{
                Spacer()
                Image("PM Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .shadow(color: .gray, radius: 6, x: 0, y: 4)
                Text("Welcome to PeakMind")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                    .shadow(color: .gray, radius: 10, x: 0, y: 4)
                
                // form fields
                
                VStack(spacing: 18) {
                    TextField("Email Address", text: $email)
                        .padding()
                        .background(Color(.white).opacity(0.8))
                        .cornerRadius(5.0)
                        .shadow(color: .gray, radius: 10, x: 0, y: 4)
                        .padding(.bottom, 5)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.white).opacity(0.8))
                        .cornerRadius(5.0)
                        .shadow(color: .gray, radius: 10, x: 0, y: 4)
                        .padding(.bottom, 0)


                    
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
                
                if let errorMessage = viewModel.authErrorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                //sign in button
                
                HStack(alignment: .center) {
                    Button {
                        viewModel.clearError()

                        Task {
                            try await viewModel.signInWithEmail(email:email, password:password)
                        }
                    } label: {
                        HStack {
                            Text("Sign In")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .frame(width: UIScreen.main.bounds.width - 80, height: 48)
                        .background(formIsValid ? Color.blue : Color.black)
                        .cornerRadius(10)
                        .padding(.top, 24)
                    }
                    .disabled(!formIsValid)
                    
                    
                    
                }
                
                GoogleSignInButton(action: viewModel.signInWithGoogle)
                //SignInWithAppleButtonView()
                
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
            .background(
                 Image("Login2")
                     .resizable()
                     .aspectRatio(contentMode: .fill)
                     .ignoresSafeArea()
             )
            .onAppear(){
                viewModel.clearError()
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
