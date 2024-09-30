import SwiftUI

struct HomeDashboard: View {
    @State var isCheckedIn: Bool = false
    @State private var showResourcesSheet = false // State variable to control sheet presentation
    @State private var showDailyCheckInSheet = false // State variable for DailyCheckInView sheet
    @State private var showAvatarMenuSheet = false // State variable for AvatarMenuView sheet
    @State private var showIglooMenuSheet = false // State variable for IglooMenuView sheet
    @Binding var selectedTab: Int
    @EnvironmentObject var viewModel: AuthViewModel // Added viewModel as an environment object

    init(selectedTab: Binding<Int>? = nil) {
        _selectedTab = selectedTab ?? .constant(2) // Default to tab index 2 if no binding is provided
        setupNavigationBarAppearance() // Call the function to set navigation bar appearance
    }

    var body: some View {
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
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .padding(.trailing, 20)
                            }
                            .foregroundColor(.navyBlue)
                        }
                    }
                    .padding(.top, -55) // Move the gear icon higher on the screen
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
                                .sheet(isPresented: $showDailyCheckInSheet) {
                                    DailyCheckInView() // Present DailyCheckInView as a sheet
                                }

                                Spacer() // Pushes the dots to the bottom

                                // Dummy HStack for dots as placeholders
                                HStack(spacing: 5) {
                                    ForEach(0..<7, id: \.self) { index in
                                        Circle()
                                            .fill(index % 2 == 0 ? Color("Ice Blue") : Color.gray)
                                            .frame(width: 25, height: 25)
                                            .overlay(
                                                Text(abbreviationForDay(index: index))
                                                    .font(.system(size: 12)) // Smaller font size
                                                    .fontWeight(.bold) // Make the font bold
                                                    .foregroundColor(.black)
                                            )
                                    }
                                }
                                .padding(.bottom, 35)
                                .padding(.leading, 25) // Align the days of the week with the CheckInText
                            }
                            .frame(maxWidth: .infinity, alignment: .leading) // Ensures alignment
                        }

                        NavigationLink(destination: OnboardingView()) {
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
        }
    }
}

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
