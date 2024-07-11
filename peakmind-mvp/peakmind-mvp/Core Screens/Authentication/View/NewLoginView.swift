import SwiftUI
import GoogleSignInSwift
import AuthenticationServices

struct NewLoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isSignUpMode = false

    var body: some View {
        VStack {
            if isSignUpMode {
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            if isSignUpMode {
                Button(action: {
                    authViewModel.signUpWithEmail(email: email, password: password, username: username)
                }) {
                    Text("Sign Up")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            } else {
                Button(action: {
                    authViewModel.signInWithEmail(email: email, password: password)
                }) {
                    Text("Sign In")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            Button(action: {
                isSignUpMode.toggle()
            }) {
                Text(isSignUpMode ? "Switch to Sign In" : "Switch to Sign Up")
                    .padding()
            }
            GoogleSignInButton(action: authViewModel.signInWithGoogle)
                .padding()
        }
        .padding()
    }
}


struct SignInWithAppleButtonView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: authViewModel.handleSignInWithAppleRequest,
            onCompletion: authViewModel.handleSignInWithAppleCompletion
        )
        .frame(width: 280, height: 45)
        .signInWithAppleButtonStyle(.black)
    }
}
