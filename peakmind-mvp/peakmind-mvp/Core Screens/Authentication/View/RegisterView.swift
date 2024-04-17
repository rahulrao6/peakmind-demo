//import SwiftUI
//
//struct Registration2View: View {
//    @State private var email = ""
//    @State private var username = ""
//    @State private var password = ""
//    @State private var confirm_password = ""
//    @EnvironmentObject var viewModel: AuthViewModel
//    
//    var body: some View {
//        VStack {
//            Text("Sign Up For PeakMind")
//                .font(.title)
//                .bold()
//                .padding()
//            
//            ScrollView {
//                VStack(spacing: 24) {
//                    TextField("Email Address", text: $email)
//                        .autocapitalization(.none)
//                    
//                    TextField("Username", text: $username)
//                    
//                    SecureField("Password", text: $password)
//                    
//                    SecureField("Confirm Password", text: $confirm_password)
//                }
//                .padding(.horizontal)
//                .padding(.top, 12)
//            }
//            
//            Button {
//                Task {
//                    try await viewModel.createUser(withEmail: email, password: password, username: username, selectedAvatar: "", selectedBackground: "", hasCompletedInitialQuiz: false, hasSetInitialAvatar: false, LevelOneCompleted: false, LevelTwoCompleted: false)
//                } label: {
//                    Text("Register")
//                        .fontWeight(.semibold)
//                        .foregroundColor(.white)
//                        .frame(width: UIScreen.main.bounds.width - 32, height: 48)
//                        .background(formIsValid ? Color.blue : Color.gray)
//                        .cornerRadius(10)
//                        .padding(.top, 24)
//                }
//                .disabled(!formIsValid)
//            }
//                Spacer()
//                
//                Button {
//                    // Navigation logic to sign in view
//                } label: {
//                    Text("Already have an account? Sign In")
//                        .fontWeight(.bold)
//                }
//                .font(.system(size: 16))
//            
//                
//            
//        }
//    }
//}
//
//extension Registration2View: AuthenticationFormProtocol {
//    var formIsValid: Bool {
//        !email.isEmpty && email.contains("@") && !password.isEmpty && password.count >= 6 && password == confirm_password && !username.isEmpty
//    }
//}
