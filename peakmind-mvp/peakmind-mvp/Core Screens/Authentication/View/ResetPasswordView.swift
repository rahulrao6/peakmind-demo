//
//  ResetPasswordView.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 2/18/24.
//

//import SwiftUI
//
//struct ResetPasswordView: View {
//    
//    @State private var email = ""
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var viewModel: AuthViewModel
//    
//    
//    var body: some View {
//        
//        
//        VStack{
//            //title
//            HStack {
//                Text("Reset Your Password")
//                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
//                    .bold()
//                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
//                    .padding()
//                
//                Image(systemName: "brain.head.profile")
//                    .imageScale(.large)
//                    .font(.title)
//                    .padding()
//                    
//                
//                
//            }
//            
//            //form fields
//            VStack(spacing: 24) {
//                InputView(text: $email, title: "Email Address", placeholder: "Enter your email", isSecureField: false)
//                    .autocapitalization(.none)
//            }
//            .padding(.horizontal)
//            .padding(.top, 12)
//            
//            Button {
//                print("Send Reset Link")
//                Task {
//                    viewModel.resetPassword(email: email)
//                    dismiss()
//                }
//                
//            } label: {
//                HStack {
//                    Text("Send Reset Link")
//                        .fontWeight(.semibold)
//                    Image(systemName: "arrow.right")
//                }
//                .foregroundColor(.white)
//                .frame(width: UIScreen.main.bounds.width - 32, height: 48)
//                .background(Color.black)
//                .disabled(!formIsValid)
//                .opacity(formIsValid ? 1 : 0.5)
//                .cornerRadius(10)
//                .padding(.top, 24)
//            }
//            
//            
//            Spacer()
//            
//            Button {
//                dismiss()
//            } label: {
//                HStack(spacing: 2) {
//                    Text("Remember your password?")
//                    Text("Sign In")
//                        .fontWeight(.bold)
//                }
//                .font(.system(size: 16))
//                
//            }
//            
//            
//            
//        }
//    }
//}
//
//
//extension ResetPasswordView: AuthenticationFormProtocol {
//    var formIsValid: Bool {
//        return !email.isEmpty && email.contains("@")
//    }
//    
//    
//}
//
//
//#Preview {
//    ResetPasswordView()
//}


//-------------------------------------------------Redesign by Zak--------------------------------------------------------------

import SwiftUI

struct ResetPasswordView: View {
    
    @State private var email = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image("PM Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .shadow(color: .gray, radius: 6, x: 0, y: 4)
                
                Text("Reset Your Password")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .shadow(color: .black, radius: 0.1)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .bottom)
                    .padding(.horizontal, 16)
                
                // Form Fields
                VStack(spacing: 16) {
                    ZStack(alignment: .leading) {
                        if email.isEmpty {
                            Text("     Email Address")
                                .foregroundColor(.gray)
                                .padding(.leading, 5)
                        }
                        TextField("", text: $email)
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.mediumBlue, lineWidth: 1))
                            .autocapitalization(.none)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                Button {
                    Task {
                        await viewModel.resetPassword(email: email)
                        dismiss()
                    }
                } label: {
                    HStack {
                        Text("Send Reset Link")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 48, height: 48)
                    .background(formIsValid ? Color.mediumBlue : Color.iceBlue)
                    .cornerRadius(10)
                }
                .padding(.top, 30)
                .disabled(!formIsValid)
                
                Spacer()
                
                // Sign-in button
                HStack(spacing: 2) {
                    Text("Remember your password?")
                        .foregroundColor(Color.gray)
                    Button {
                        dismiss()
                    } label: {
                        Text("Sign In")
                            .fontWeight(.bold)
                            .foregroundColor(Color.mediumBlue)
                    }
                }
                .font(.system(size: 16))
                .padding(.bottom, 20)
            }
            .background(
                Image("Login2")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            )
            .alert(isPresented: .constant(viewModel.authErrorMessage != nil)) {
                Alert(title: Text("Error"), message: Text(viewModel.authErrorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
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
    ResetPasswordView().environmentObject(AuthViewModel())
}



