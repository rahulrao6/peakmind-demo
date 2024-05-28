import SwiftUI

struct HomeDashboard: View {
    @State var isCheckedIn: Bool = false
    @State var weekCheckIns: [Int] = [1, 0, 1, 0, 0, 1, 0] // 0 for not checked in, 1 for checked in
    @EnvironmentObject var viewModel: AuthViewModel
    @Binding var selectedTab: Int
    @State private var showResourcesSheet = false // State variable to control sheet presentation


    init(selectedTab: Binding<Int>? = nil) {
        _selectedTab = selectedTab ?? .constant(2) // Default to tab index 2 if no binding is provided
    }
    
    var body: some View {
        if let user = viewModel.currentUser {
            ZStack {
                // Background image
                Image("HomeBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Non-scrollable logo at the top
                    Image("PM3D")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 60)
                        .padding(.top, 10)
                    
                    ScrollView {
                        // Scrollable VStack for the buttons
                        VStack(spacing: 20) {
                            ZStack(alignment: .bottomLeading) {
                                Image("CheckInBG")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                
                                VStack(alignment: .leading) {
                                    
                                    Button(action: {
                                        if (!isCheckedIn) {
                                            self.selectedTab = 1
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
                                    
                                    Spacer() // Pushes the dots to the bottom
                                    
                                    HStack(spacing: 5) {
                                        ForEach(0..<user.weeklyStatus.count, id: \.self) { index in
                                            Circle()
                                                .fill(user.weeklyStatus[index] == 1 ? Color("Ice Blue") : Color.gray)
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
                                
                                Text(String(user.dailyCheckInStreak))
                                    .font(.largeTitle) // Customize the font size as needed
                                    .fontWeight(.bold)
                                    .foregroundColor(.black) // Ensure the text color contrasts with the background
                                    .padding(.top, 65) // Top padding
                                    .padding(.trailing, 55) // Right padding
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            }
                            
                            //NavigationLink(destination: LevelOneMapView().environmentObject(viewModel)) {
                                ZStack{
                                    Image("DailyQuest")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .overlay(
                                            Image(user.selectedAvatar)
                                                .resizable()
                                                .scaleEffect(0.9)
                                                .aspectRatio(contentMode: .fit)
                                                .offset(x: -110, y: 50) // Adjust the X and Y position as needed
                                        )
                                        .clipShape(Rectangle()) // Ensures the overlay image is clipped exactly to the parent image
                                    
                                    Text(user.completedLevels.count >= 3 ? "Quest\nComplete" : "Finish 3\nLevels")
                                        .font(.system(size: 24)) // Custom font size
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.top, 85)
                                        .padding(.trailing, 80)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                    
                                }.onTapGesture {
                                    self.selectedTab = 0 // Switch to the LevelOneMapView tab
                                }
                            //}
                            
                            NavigationLink(destination: ChatView().environmentObject(viewModel)) {
                                Image("ChatSherpa")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            
                            /*NavigationLink(destination:
                                            JournalEntriesView()
                                                .environmentObject(viewModel)
                                                .environmentObject(JournalDataManager())){
                                Image("Journal")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }*/
                            
                            Button(action: {
                                showResourcesSheet.toggle()
                            }) {
                                Image("ResourcesButton")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            .sheet(isPresented: $showResourcesSheet) {
                                ResourcesToUtilize()
                            }
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                checkTodayCheckIn()
            }
        }
    }
    private func checkTodayCheckIn() {
        if let lastCheckDate = viewModel.currentUser?.lastCheck,
           Calendar.current.isDateInToday(lastCheckDate) {
            isCheckedIn = true
        } else {
            isCheckedIn = false
        }
    }
}


struct DailyQuestView: View {
    var body: some View {
        Text("DailyQuest Screen")
    }
}

struct ChatSherpaView: View {
    var body: some View {
        Text("ChatSherpa Screen")
    }
}

struct JournalView2: View {
    var body: some View {
        Text("Journal Screen")
    }
}

struct ResourcesButtonView: View {
    var body: some View {
        Text("Resources Screen")
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
//
//
//struct HomeDashboard_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            HomeDashboard( selectedTab: 2)
//        }
//    }
//}
