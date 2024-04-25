import SwiftUI

struct HomeDashboard: View {
    @State var isCheckedIn: Bool = false
    @State var weekCheckIns: [Int] = [1, 0, 1, 0, 0, 1, 0] // 0 for not checked in, 1 for checked in
    
    var body: some View {
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
                                    self.isCheckedIn.toggle()
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
                                    ForEach(0..<weekCheckIns.count, id: \.self) { index in
                                        Circle()
                                            .fill(weekCheckIns[index] == 1 ? Color("Ice Blue") : Color.gray)
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
                    
                        Text("3")
                            .font(.largeTitle) // Customize the font size as needed
                            .fontWeight(.bold)
                            .foregroundColor(.black) // Ensure the text color contrasts with the background
                            .padding(.top, 65) // Top padding
                            .padding(.trailing, 55) // Right padding
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    }

                        NavigationLink(destination: LevelOneMapView()) {
                            ZStack{
                                Image("DailyQuest")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .overlay(
                                        Image("Mikey")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .offset(x: -110, y: 60) // Adjust the X and Y position as needed
                                    )
                                    .clipShape(Rectangle()) // Ensures the overlay image is clipped exactly to the parent image
                                Text("Finish 3\nLevels")
                                    .font(.system(size: 24)) // Custom font size
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.top, 85)
                                    .padding(.trailing, 80)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

                            }
                        }

                         NavigationLink(destination: ChatSherpaView()) {
                             Image("ChatSherpa")
                                 .resizable()
                                 .aspectRatio(contentMode: .fit)
                         }

                         NavigationLink(destination: JournalView2()) {
                             Image("Journal")
                                 .resizable()
                                 .aspectRatio(contentMode: .fit)
                         }

                         NavigationLink(destination: ResourcesButtonView()) {
                             Image("ResourcesButton")
                                 .resizable()
                                 .aspectRatio(contentMode: .fit)
                         }
                     }
                    .padding()
                }
            }
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


struct HomeDashboard_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeDashboard()
        }
    }
}
