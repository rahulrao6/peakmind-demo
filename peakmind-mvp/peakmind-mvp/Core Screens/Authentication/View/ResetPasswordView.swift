//
//  ResetPasswordView.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 2/18/24.
//

import SwiftUI

struct ResetPasswordView: View {
    
    @State private var email = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    
    var body: some View {
        
        
        VStack{
            //title
            HStack {
                Text("Reset Your Password")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .bold()
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    .padding()
                
                Image(systemName: "brain.head.profile")
                    .imageScale(.large)
                    .font(.title)
                    .padding()
                    
                
                
            }
            
            //form fields
            VStack(spacing: 24) {
                InputView(text: $email, title: "Email Address", placeholder: "Enter your email", isSecureField: false)
                    .autocapitalization(.none)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            Button {
                print("Send Reset Link")
                Task {
                    viewModel.resetPassword(email: email)
                    dismiss()
                }
                
            } label: {
                HStack {
                    Text("Send Reset Link")
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
            
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                HStack(spacing: 2) {
                    Text("Remember your password?")
                    Text("Sign In")
                        .fontWeight(.bold)
                }
                .font(.system(size: 16))
                
            }
            
            
            
        }
    }
}


extension ResetPasswordView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@")
    }
    
    
}


#Preview {
    ResetPasswordView()
}
