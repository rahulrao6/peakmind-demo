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
    @State private var password = ""
    @State private var confirm_password = ""
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        
    
        VStack{
            //title
            Text("Register your account")
                .bold()
                .frame(width: .infinity, height: 100)
                .cornerRadius(15)
                .padding()
                .background(.black)
                .foregroundColor(.white)
                .cornerRadius(15)
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            
            //form fields
            VStack(spacing: 24) {
                InputView(text: $email, title: "Email Address", placeholder: "Enter your email", isSecureField: false)
                    .autocapitalization(.none)
                
                InputView(text: $full_name, title: "Full Name", placeholder: "Enter your name", isSecureField: false)
                
                InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                
                InputView(text: $confirm_password, title: "Comfirm Password", placeholder: "Confirm your password", isSecureField: true)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            Button {
                print("Sign User Up")
                
            } label: {
                HStack {
                    Text("Sign Up")
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
            
            Button {
                dismiss()
            } label: {
                HStack(spacing: 2) {
                    Text("Already have an account?")
                    Text("Sign In")
                        .fontWeight(.bold)
                }
                .font(.system(size: 16))
                
            }
            
            
            
        }
    }
}

#Preview {
    RegistrationView()
}
