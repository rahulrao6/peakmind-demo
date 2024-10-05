//
//  LoginView.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 2/17/24.
//

//import SwiftUI
//import GoogleSignInSwift
//
//struct LoginView: View {
//    @State private var email = ""
//    @State private var password = ""
//    @EnvironmentObject var viewModel: AuthViewModel
//
//    
//    var body: some View {
//        NavigationStack {
//            VStack{
//                Spacer()
//                Image("PM Logo")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 200, height: 200)
//                    .shadow(color: .gray, radius: 6, x: 0, y: 4)
//                Text("Welcome to PeakMind")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .padding(.bottom, 20)
//                    .shadow(color: .gray, radius: 10, x: 0, y: 4)
//                
//                // form fields
//                
//                VStack(spacing: 18) {
//                    TextField("Email Address", text: $email)
//                        .padding()
//                        .background(Color(.white).opacity(0.8))
//                        .cornerRadius(5.0)
//                        .shadow(color: .gray, radius: 10, x: 0, y: 4)
//                        .padding(.bottom, 5)
//
//                    SecureField("Password", text: $password)
//                        .padding()
//                        .background(Color(.white).opacity(0.8))
//                        .cornerRadius(5.0)
//                        .shadow(color: .gray, radius: 10, x: 0, y: 4)
//                        .padding(.bottom, 0)
//
//
//                    
//                    NavigationLink {
//                        ResetPasswordView()
//                            .navigationBarBackButtonHidden(true)
//                        
//                    } label: {
//                        Text("Forgot your password?")
//                            .font(.footnote)
//                            .foregroundColor(Color.black)
//                        //.padding(.top, -20)
//                            .frame(maxWidth: .infinity, alignment: .trailing)
//                        
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.top, 12)
//                
//                if let errorMessage = viewModel.authErrorMessage {
//                    Text(errorMessage)
//                        .foregroundColor(.red)
//                        .multilineTextAlignment(.center)
//                        .padding()
//                }
//                
//                //sign in button
//                
//                HStack(alignment: .center) {
//                    Button {
//                        viewModel.clearError()
//
//                        Task {
//                            try await viewModel.signInWithEmail(email:email, password:password)
//                        }
//                    } label: {
//                        HStack {
//                            Text("Sign In")
//                                .fontWeight(.semibold)
//                            Image(systemName: "arrow.right")
//                        }
//                        .foregroundColor(.white)
//                        .frame(width: UIScreen.main.bounds.width - 80, height: 48)
//                        .background(formIsValid ? Color.blue : Color.black)
//                        .cornerRadius(10)
//                        .padding(.top, 24)
//                    }
//                    .disabled(!formIsValid)
//                    
//                    
//                    
//                }
//                
//                GoogleSignInButton(action: viewModel.signInWithGoogle)
//                //SignInWithAppleButtonView()
//                
//                Spacer()
//                
//                //sign up button
//                
//                NavigationLink {
//                    RegistrationView()
//                        .navigationBarBackButtonHidden(true)
//                } label: {
//                    HStack(spacing: 2) {
//                        Text("Don't have an account?")
//                        Text("Sign Up")
//                            .fontWeight(.bold)
//                    }
//                    .font(.system(size: 16))
//                }
//            }
//            .background(
//                 Image("Login2")
//                     .resizable()
//                     .aspectRatio(contentMode: .fill)
//                     .ignoresSafeArea()
//             )
//            .onAppear(){
//                viewModel.clearError()
//            }
//        }
//    }
//}
//
//extension LoginView: AuthenticationFormProtocol {
//    var formIsValid: Bool {
//        return !email.isEmpty && email.contains("@") && !password.isEmpty && password.count > 5
//    }
//    
//    
//}
//
//#Preview {
//    LoginView()
//}

//--------------------------------------------------------------------------------------------------------------------

//Fixed the simulator that wasn't working. -Zak


//import SwiftUI
//import GoogleSignInSwift
//
//struct LoginView: View {
//    @State private var email = ""
//    @State private var password = ""
//    @EnvironmentObject var viewModel: AuthViewModel
//
//    var body: some View {
//        NavigationStack {
//            VStack {
//                Spacer()
//                Image("PM Logo")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 200, height: 200)
//                    .shadow(color: .gray, radius: 6, x: 0, y: 4)
//                Text("Welcome to PeakMind")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .padding(.bottom, 20)
//                    .shadow(color: .gray, radius: 10, x: 0, y: 4)
//                
//                // Form fields
//                VStack(spacing: 18) {
//                    TextField("Email Address", text: $email)
//                        .padding()
//                        .background(Color(.white).opacity(0.8))
//                        .cornerRadius(5.0)
//                        .shadow(color: .gray, radius: 10, x: 0, y: 4)
//                        .padding(.bottom, 5)
//
//                    SecureField("Password", text: $password)
//                        .padding()
//                        .background(Color(.white).opacity(0.8))
//                        .cornerRadius(5.0)
//                        .shadow(color: .gray, radius: 10, x: 0, y: 4)
//                        .padding(.bottom, 0)
//
//                    NavigationLink {
//                        ResetPasswordView()
//                            .navigationBarBackButtonHidden(true)
//                    } label: {
//                        Text("Forgot your password?")
//                            .font(.footnote)
//                            .foregroundColor(Color.black)
//                            .frame(maxWidth: .infinity, alignment: .trailing)
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.top, 12)
//                
//                if let errorMessage = viewModel.authErrorMessage {
//                    Text(errorMessage)
//                        .foregroundColor(.red)
//                        .multilineTextAlignment(.center)
//                        .padding()
//                }
//
//                // Sign-in button
//                HStack(alignment: .center) {
//                    Button {
//                        viewModel.clearError()
//
//                        Task {
//                            try await viewModel.signInWithEmail(email: email, password: password)
//                        }
//                    } label: {
//                        HStack {
//                            Text("Sign In")
//                                .fontWeight(.semibold)
//                            Image(systemName: "arrow.right")
//                        }
//                        .foregroundColor(.white)
//                        .frame(width: UIScreen.main.bounds.width - 80, height: 48)
//                        .background(formIsValid ? Color.blue : Color.black)
//                        .cornerRadius(10)
//                        .padding(.top, 24)
//                    }
//                    .disabled(!formIsValid)
//                }
//
//                GoogleSignInButton(action: viewModel.signInWithGoogle)
//
//                Spacer()
//
//                // Sign-up button
//                NavigationLink {
//                    RegistrationView()
//                        .navigationBarBackButtonHidden(true)
//                } label: {
//                    HStack(spacing: 2) {
//                        Text("Don't have an account?")
//                        Text("Sign Up")
//                            .fontWeight(.bold)
//                    }
//                    .font(.system(size: 16))
//                }
//            }
//            .background(
//                Image("Login2")
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .ignoresSafeArea()
//            )
//            .onAppear {
//                viewModel.clearError()
//            }
//        }
//    }
//}
//
//extension LoginView: AuthenticationFormProtocol {
//    var formIsValid: Bool {
//        return !email.isEmpty && email.contains("@") && !password.isEmpty && password.count > 5
//    }
//}
//
//#Preview {
//    LoginView().environmentObject(AuthViewModel())
//}


//-------------------------------------------------Redesign by Zak--------------------------------------------------------------

import SwiftUI

struct OnboardingSlide: Identifiable {
    let id = UUID()
    let image: String      // Image asset name
    let title: String
    let description: String
}

import SwiftUI

struct OnboardingViewLogin: View {
    @Binding var isPresented: Bool
    @State private var currentSlide = 0

    // Define your slides here
    let slides = [
        OnboardingSlide(image: "Onboarding1", title: "Welcome to PeakMind", description: "Improve your mental health with our app."),
        OnboardingSlide(image: "Onboarding2", title: "Track Your Progress", description: "Monitor your well-being and growth."),
        OnboardingSlide(image: "Onboarding3", title: "Achieve Your Goals", description: "Reach your full potential with PeakMind.")
    ]

    var body: some View {
        VStack {
            TabView(selection: $currentSlide) {
                ForEach(0..<slides.count, id: \.self) { index in
                    VStack(spacing: 20) {
                        Image(slides[index].image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .shadow(radius: 10)
                            .padding()

                        Text(slides[index].title)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Text(slides[index].description)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .animation(.easeInOut, value: currentSlide)
            .padding()

            Button(action: {
                if currentSlide < slides.count - 1 {
                    withAnimation {
                        currentSlide += 1
                    }
                } else {
                    // Dismiss the onboarding
                    isPresented = false
                }
            }) {
                Text(currentSlide < slides.count - 1 ? "Next" : "Get Started")
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .background(
            Image("onboardingBackground") // Optional: Background image for onboarding
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
}

import SwiftUI
import GoogleSignInSwift
import AuthenticationServices

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showOnboarding = true // State to control onboarding presentation

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image("PM Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .shadow(color: .gray, radius: 6, x: 0, y: 4)
                
                Text("Welcome to PeakMind!")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .shadow(color: .black, radius: 0.1)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .bottom)
                    .padding(.horizontal, 16)
                
                Text("Log in to Unleash Adventure!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity, alignment: .bottom)
                    .padding(.horizontal, 16)

                // Form fields
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

                    ZStack(alignment: .leading) {
                        if password.isEmpty {
                            Text("     Password")
                                .foregroundColor(.gray)
                                .padding(.leading, 5)
                        }
                        SecureField("", text: $password)
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.mediumBlue, lineWidth: 1))
                            .autocapitalization(.none)
                            .padding(.horizontal, 16)
                    }

                    NavigationLink {
                        ResetPasswordView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        Text("Forgot Password?")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(Color.mediumBlue)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal, 16)
                            .padding(.top, -10)
                    }
                }
                
                if let errorMessage = viewModel.authErrorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                
                Button {
                    viewModel.clearError()
                    Task {
                        try await viewModel.signInWithEmail(email: email, password: password)
                    }
                } label: {
                    Text("Log In")
                        .foregroundColor(.white)
                        .frame(width: UIScreen.main.bounds.width - 48, height: 48)
                        .background(formIsValid ? Color.mediumBlue : Color.iceBlue)
                        .cornerRadius(10)
                }
                .padding(.top, 16)
                .disabled(!formIsValid)
                
                Text("or continue with")
                    .foregroundColor(.gray)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                HStack(spacing: 16) {
                    Button(action: {
                        viewModel.signInWithGoogle()
                    }) {
                        HStack {
                            Image("google")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.black)
                                .font(.system(size: 16))
                        }
                        .frame(width: 160, height: 48)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    }

                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in
                            viewModel.handleSignInWithAppleRequest(request)
                        },
                        onCompletion: { result in
                            viewModel.handleSignInWithAppleCompletion(result)
                        }
                    )
                    .signInWithAppleButtonStyle(.white)
                    .frame(width: 160, height: 48)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
                .padding(.top, 8)

                Spacer()

                // Sign-up button
                HStack(spacing: 2) {
                    Text("Don't have an account?")
                        .foregroundColor(Color.gray)
                    NavigationLink {
                        RegistrationView()
                            .navigationBarBackButtonHidden(true)
                        } label: {
                            Text("Sign up")
                                .font(.callout)
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
            .onAppear {
                viewModel.clearError()
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingViewLogin(isPresented: $showOnboarding)
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
    LoginView().environmentObject(AuthViewModel())
}

