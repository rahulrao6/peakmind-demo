import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel : AuthViewModel
    @State private var isModule1Active = false
    @State private var isModule2Active = false
    @State private var isModule3Active = false
    @State private var isTentPurchaseActive = false
    @State private var isStoreViewActive = false
    @State private var isAnxietyQuizActive = false
    @State private var isSetHabitsActive = false
    @State private var isAvatarScreenActive = false
    @State private var isNightfallFlavorActive = false
    @State private var isDangersOfNightfallActive = false
    @State private var isSherpaFullMoonIDActive = false
    @State private var isBreathingExerciseViewActive = false
    @State private var isFeedbackFormPresented = false

    var body: some View {
        NavigationView {
            if let user = viewModel.currentUser {
                List {
                    Section {
                        HStack {
                            Text(user.initials)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 72, height: 72)
                                .background(Color.blue)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.username)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.top, 4)
                                
                                Text(user.email)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Section("General") {
                        HStack {
                            SettingsRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
                            
                            Spacer()
                            
                            Text("1.0.0")
                        }
                    }
                    
                    Section("Account") {
                        Button {
                            viewModel.signOut()
                        } label: {
                            SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
                        }
                        
                        Button {
                            Task {
                               try await viewModel.deleteAccount()
                            }
                        } label: {
                            SettingsRowView(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: .red)
                        }
                    }
                    
                    Section("Feedback Form") {
                        Button("Provide Feedback") {
                            isFeedbackFormPresented.toggle()
                        }
                        .sheet(isPresented: $isFeedbackFormPresented) {
                            FeedbackFormView()
                        }
                    }
                }
                .environment(\.colorScheme, .light)
            }
        }
    }
}

struct FeedbackFormView: View {
    @State private var feedbackText = ""
    
    var body: some View {
        VStack {
            Text("Enter your feedback below!")
                .font(.headline)
                .padding()
            
            TextEditor(text: $feedbackText)
                .frame(height: 200)
                .border(Color.gray, width: 1)
                .padding()
            
            Button("Submit") {
                // Implement the submit action here
                print("Feedback submitted")
            }
            .padding()
        }
        .padding()
    }
}
