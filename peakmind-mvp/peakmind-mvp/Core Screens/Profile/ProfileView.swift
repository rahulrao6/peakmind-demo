import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel : AuthViewModel
    @State private var isMessageListViewPresented = false
    @State private var isFriendListViewPresented = false
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
    @State private var isRoutineListViewPresented = false
    @State private var isFactorListViewPresented = false
    @State private var isRectangleViewPresented = false
    @State private var isRewardsListViewPresented = false
    @State private var isSettingsListViewPresented = false

    
    @State private var GAD7Present = false
    @State private var ISIPresent = false
    @State private var EnergyPresent = false

    @State private var PSSPresent = false
    @State private var NMRQPresent = false
    @State private var PHQ9Present = false
    @EnvironmentObject var eventKitManager: EventKitManager
    @EnvironmentObject var healthKitManager: HealthKitManager


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
                            FeedbackFormView().environmentObject(viewModel)
                        }
                    }
                    
//                    Section("Habit Stack") {
//                        Button("Routine List") {
//                            isRoutineListViewPresented.toggle()
//                        }
//                        .sheet(isPresented: $isRoutineListViewPresented) {
//                            RoutineBuilderView().environmentObject(viewModel)
//                        }
//                        
//                        Button("Settings") {
//                            isSettingsListViewPresented.toggle()
//                        }
//                        .sheet(isPresented: $isSettingsListViewPresented) {
//                            SettingsView().environmentObject(viewModel).environmentObject(healthKitManager).environmentObject(eventKitManager)
//                        }
//                        
//                        Button("Rewards") {
//                            isRewardsListViewPresented.toggle()
//                        }
//                        .sheet(isPresented: $isRewardsListViewPresented) {
//                            PointsAndBadgesView().environmentObject(viewModel)
//                        }
//                        
//                        Button("Factor List") {
//                            isFactorListViewPresented.toggle()
//                        }
//                        .sheet(isPresented: $isFactorListViewPresented) {
//                            FactorPage(category: .emotional).environmentObject(viewModel)
//                        }
//                        
//                        Button("Rectangle View") {
//                            isRectangleViewPresented.toggle()
//                        }
//                        .sheet(isPresented: $isRectangleViewPresented) {
//                            RectangleView().environmentObject(viewModel).environmentObject(NetworkManager())
//                        }
//                    }
                    Section("Quizzes") {
                        Button("GAD7") {
                            GAD7Present.toggle()
                        }
                        .sheet(isPresented: $GAD7Present) {
                            GAD7QuizView().environmentObject(viewModel)
                        }
                        Button("NMRQ") {
                            NMRQPresent.toggle()
                        }
                        .sheet(isPresented: $NMRQPresent) {
                            NMRQQuizView().environmentObject(viewModel)
                        }
                        Button("PSS") {
                            PSSPresent.toggle()
                        }
                        .sheet(isPresented: $PSSPresent) {
                            PSSQuizView().environmentObject(viewModel)
                        }
                        Button("PHQ9") {
                            PHQ9Present.toggle()
                        }
                        .sheet(isPresented: $PHQ9Present) {
                            PHQ9QuizView().environmentObject(viewModel)
                        }
                        Button("ISI") {
                            ISIPresent.toggle()
                        }
                        .sheet(isPresented: $ISIPresent) {
                            ISIQuizView().environmentObject(viewModel)
                        }
                        Button("Energy") {
                            EnergyPresent.toggle()
                        }
                        .sheet(isPresented: $EnergyPresent) {
                            EnergyQuizView().environmentObject(viewModel)
                        }
                    }
                }
                .environment(\.colorScheme, .light)
            }
        }
    }
}


struct SettingsPreview: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
