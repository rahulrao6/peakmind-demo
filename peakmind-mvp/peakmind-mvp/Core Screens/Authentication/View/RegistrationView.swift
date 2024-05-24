import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var full_name = ""
    @State private var location = ""
    @State private var username = ""
    @State private var color_raw = Color.blue
    @State private var firstPeak = ""
    @State private var hasCompletedInitialQuiz = false
    @State private var hasSetInitialAvatar = false
    @State private var LevelOneCompleted = false
    @State private var navigateToAvatarView = false
    @State private var password = ""
    @State private var confirm_password = ""
    @State private var showAvatarSelection: Bool = false
    @State private var errorMessage: String? = nil // For displaying validation errors
    @State private var  showAlert = false  // For displaying validation errors

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel

    let avatarOptions = ["Asian", "Indian", "White"]
    let backgroundOptions = ["Pink Igloo", "Orange Igloo", "Blue Igloo", "Navy Igloo"]
    @State private var selectedAvatar = "Asian"
    @State private var selectedBackground = "Blue Igloo"
    
    var color_hex: String {
        let hexColor = color_raw.toHex()
        return hexColor ?? "#FFF"
    }

    var body: some View {
        VStack {
            // Title
            HStack {
                Text("Sign Up For PeakMind")
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                Image("PM Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                    .padding(8)
            }
            ScrollView {
                // Form Fields
                VStack(spacing: 24) {
                    InputView(text: $email, title: "Email Address", placeholder: "Enter your email", isSecureField: false)
                        .autocapitalization(.none)
                        .onChange(of: email) { _ in validateForm() }
                    
                    InputView(text: $username, title: "Username", placeholder: "Enter your username", isSecureField: false)
                        .onChange(of: username) { _ in validateForm() }
                    
                    InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                        .onChange(of: password) { _ in validateForm() }
                    
                    ZStack(alignment: .bottomTrailing) {
                        InputView(text: $confirm_password, title: "Confirm Password", placeholder: "Confirm your password", isSecureField: true)
                            .onChange(of: confirm_password) { _ in validateForm() }
                        
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
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            VStack {
                Button {
                    Task {
                        await registerUser()
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
        .background(
            NavigationLink(
                destination: AvatarMenuView().environmentObject(viewModel),
                isActive: $navigateToAvatarView
            ) {
                EmptyView()
            }
        )
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            viewModel.clearError()
        }
    }

    private func validateForm() {
        if email.isEmpty || !email.contains("@") {
            errorMessage = "Please enter a valid email address."
        } else if username.isEmpty {
            errorMessage = "Username cannot be empty."
        } else if password.isEmpty || password.count < 6 {
            errorMessage = "Password must be at least 6 characters long."
        } else if password != confirm_password {
            errorMessage = "Passwords do not match."
        } else {
            errorMessage = nil
        }
    }

    private func registerUser() async {
        Task{
           do {
                viewModel.clearError()
                try await viewModel.createUser(
                    withEmail: email,
                    password: password,
                    username: username,
                    selectedAvatar: "",
                    selectedBackground: "",
                    hasCompletedInitialQuiz: false,
                    hasSetInitialAvatar: false,
                    LevelOneCompleted: false,
                    LevelTwoCompleted: false
                )
               navigateToAvatarView = true
            } catch {
                errorMessage = "Failed to create user: \(error.localizedDescription)"
                showAlert = true
                
            }
        }
    }
}

extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return errorMessage == nil
    }
}

#Preview {
    RegistrationView()
}
