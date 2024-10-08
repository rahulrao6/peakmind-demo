import SwiftUI
import Firebase

struct HomeDashboard: View {
    @State var isCheckedIn: Bool = false
    @State private var showResourcesSheet = false // State variable to control sheet presentation
    @State private var showDailyCheckInSheet = false // State variable for DailyCheckInView sheet
    @State private var showAvatarMenuSheet = false // State variable for AvatarMenuView sheet
    @State private var showIglooMenuSheet = false // State variable for IglooMenuView sheet
    @State private var currentStreak: Int = 0 // New state variable for tracking streak

    @Binding var selectedTab: Int
    @EnvironmentObject var viewModel: AuthViewModel // Added viewModel as an environment object
    @EnvironmentObject var EventKitManager1: EventKitManager
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject  var nm : NetworkManager

    init(selectedTab: Binding<Int>? = nil) {
        _selectedTab = selectedTab ?? .constant(2) // Default to tab index 2 if no binding is provided
        setupNavigationBarAppearance() // Call the function to set navigation bar appearance
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background image
                Image("HomeBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    ZStack {
                        // Logo centered
                        HStack {
                            Spacer() // Ensure the logo is centered by adding spacers
                            
                            Image("PM3D")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 300, height: 60)
                                .padding(.top, 5)
                                .padding(.bottom, -13)
                            
                            Spacer() // Ensure the logo is centered
                        }
                        
                        // Gear icon positioned at the top-right corner
                        VStack {
                            HStack {
                                Spacer() // Push the gear to the right
                                NavigationLink(destination: SettingsView().environmentObject(viewModel).environmentObject(healthKitManager).environmentObject(EventKitManager1).environmentObject(nm)) {
                                    Image(systemName: "gearshape.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .padding(.trailing, 15)
                                }
                                .foregroundColor(.navyBlue)
                            }
                        }
                        .padding(.top, -25) // Move the gear icon higher on the screen
                    }
                    
                    ScrollView {
                        // Scrollable VStack for the buttons
                        VStack(spacing: 17) {
                            ZStack(alignment: .bottomLeading) {
                                    
                                Image("CheckInBG")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                
                                
                                VStack(alignment: .leading) {
                                    Button(action: {
                                        if (!isCheckedIn) {
                                            self.showDailyCheckInSheet.toggle() // Show Daily Check-In sheet when button pressed
                                        }
                                    }) {
                                        Image(isCheckedIn ? "Thanks" : "CheckInText")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 225, height: 60)
                                    }
                                    .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle to remove default button styling
                                    .padding(.top)
                                    .padding(.leading, 25) // Adjust the left padding as necessary
                                    .sheet(isPresented: $showDailyCheckInSheet, onDismiss: {
                                        fetchCheckInStatus() // Refresh check-in status after dismissal
                                    }) {
                                        DailyCheckInView() // Present DailyCheckInView as a sheet
                                            .environmentObject(viewModel) // Ensure AuthViewModel is passed
                                    }
                                    
                                    Spacer() // Pushes the dots to the bottom
                                    
                                    HStack(spacing: 5) {
                                        // Ensure that the viewModel is provided to this view, and currentUser is non-nil
                                        ForEach(0..<7, id: \.self) { index in
                                            if viewModel.currentUser?.weeklyStatus[index] == 1 { // Checked-in
                                                Circle()
                                                    .fill(Color("Ice Blue")) // Highlighted color for check-in
                                                    .frame(width: 25, height: 25)
                                                    .overlay(
                                                        Text(abbreviationForDay(index: index))
                                                            .font(.system(size: 12))
                                                            .fontWeight(.bold)
                                                            .foregroundColor(.white) // Changed for better contrast
                                                    )
                                            } else {
                                                Circle()
                                                    .fill(Color.gray) // Default color for no check-in
                                                    .frame(width: 25, height: 25)
                                                    .overlay(
                                                        Text(abbreviationForDay(index: index))
                                                            .font(.system(size: 12))
                                                            .fontWeight(.bold)
                                                            .foregroundColor(.black)
                                                    )
                                                
                                            }
                                        }
                                    }
                                    .padding(.bottom, 35)
                                    .padding(.leading, 25) // Align the days of the week with the CheckInText
                                }
                                .frame(maxWidth: .infinity, alignment: .leading) // Ensures alignment
                            }
                            
                            NavigationLink(destination: OnboardingView(authViewModel: viewModel)) {
                                Image("FlowButton")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            
                            NavigationLink(destination: ChatView().environmentObject(viewModel)) { // viewModel passed here
                                Image("SherpaButton")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            
                            // HStack for side-by-side buttons
                            HStack(spacing: 20) {
                                NavigationLink(destination: JournalView()) {
                                    Image("JournalButton")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                                
                                Button(action: {
                                    showResourcesSheet.toggle()
                                }) {
                                    Image("ResourcesButton2")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                                .sheet(isPresented: $showResourcesSheet) {
                                    ResourcesToUtilize()
                                }
                            }
                        }
                        .padding()
                    }
                }
                .onAppear {
                    viewModel.fetchUserData(userId: viewModel.currentUser?.id ?? "")
                    fetchCheckInStatus() // Fetch check-in status when the view appears
                }
            }
        }
    }
    
    // Set up the navigation bar appearance with SF Pro Bold and white color for back button
    func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
    
        // Set background to clear or any other custom color
        appearance.configureWithTransparentBackground()
    
        // Customize the back button appearance
        appearance.backButtonAppearance.normal.titleTextAttributes = [
            .font: UIFont(name: "SFPro-Bold", size: 17) ?? UIFont.boldSystemFont(ofSize: 17),
            .foregroundColor: UIColor.white
        ]
    
        // Apply the appearance globally
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    // Fetch the user's check-in status and current streak from Firestore
    func fetchCheckInStatus() {
        guard let userId = viewModel.currentUser?.id else {
            print("User ID not found.")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        
        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                // Fetch last check-in date
                let lastCheckInTimestamp = document.get("lastCheckInDate") as? Timestamp
                let lastCheckInDate = lastCheckInTimestamp?.dateValue() ?? Date.distantPast
                
                // Determine if the user has checked in today
                DispatchQueue.main.async {
                    self.isCheckedIn = Calendar.current.isDateInToday(lastCheckInDate)
                    
                    // Fetch current streak
                    self.currentStreak = document.get("currentStreak") as? Int ?? 0
                }
            } else {
                print("User document does not exist.")
            }
        }
    }
    
    // Helper function to get day abbreviations
    func abbreviationForDay(index: Int) -> String {
        switch index {
        case 0: return "M"
        case 1: return "T"
        case 2: return "W"
        case 3: return "TH"
        case 4: return "F"
        case 5: return "S"
        case 6: return "SU"
        default: return ""
        }
    }
    
    // Preview provider with mock AuthViewModel
    struct HomeDashboard_Previews: PreviewProvider {
        static var previews: some View {
            let viewModel = AuthViewModel() // Create a mock AuthViewModel
            NavigationView {
                HomeDashboard(selectedTab: .constant(2))
                    .environmentObject(viewModel) // Inject the mock AuthViewModel into the view
            }
        }
    }
}
