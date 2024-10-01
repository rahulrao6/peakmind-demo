import SwiftUI
import Foundation
import AVKit
import AVFoundation

// MARK: - Data Models

struct FocusSession: Identifiable {
    let id = UUID()
    let date: Date
    let duration: TimeInterval
    let title: String
}

struct Mountain: Identifiable {
    let id = UUID()
    let name: String
    let elevation: Double
    let stages: [Stage]
    var currentStage: Int = 0
}

struct Stage {
    let name: String
    let duration: TimeInterval
    let sceneryColor: Color
}

// MARK: - ViewModel

class FlowModeViewModel: ObservableObject {
    @Published var focusSessions: [FocusSession] = []
    @Published var mountain: Mountain?
    @Published var focusGoal: String = ""
    @Published var selectedDuration: TimeInterval = 1800 // Default to 30 minutes (25 min work, 5 min break)
    @Published var isFlowActive: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var progress: Double = 0.0
    @Published var motivationalText = "Let's keep going!"
    
    private var timer: Timer?
    
    let motivationalPhrases = [
        "You're doing great!",
        "Stay focused!",
        "The summit is near!",
        "One step at a time!",
        "Keep pushing!",
        "Almost there!"
    ]
    
    // Mountains with original Pomodoro-style: 25 minutes work, 5 minutes break
    let mountains: [Mountain] = [
        Mountain(name: "Mount Everest", elevation: 29032, stages: [
            Stage(name: "First Stage", duration: 1500, sceneryColor: .green), // 25 min focus
            Stage(name: "Break", duration: 300, sceneryColor: .blue),         // 5 min break
            Stage(name: "Second Stage", duration: 1500, sceneryColor: .yellow),
            Stage(name: "Break", duration: 300, sceneryColor: .blue),
            Stage(name: "Final Stage", duration: 1500, sceneryColor: .gray),
            Stage(name: "Summit", duration: 300, sceneryColor: .white)
        ])
    ]
    
    func startNewFocusSession() {
        mountain = mountains.randomElement() // Randomize mountain
        focusSessions.append(FocusSession(date: Date(), duration: selectedDuration, title: focusGoal))
        isFlowActive = true
        elapsedTime = 0
        startClimb()
    }
    
    func startClimb() {
        guard let mountain = mountain else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.updateProgress()
        }
    }
    
    func stopClimb() {
        timer?.invalidate()
        timer = nil
    }
    
    func updateProgress() {
        guard let mountain = mountain else { return }
        guard mountain.currentStage < mountain.stages.count else { return }
        
        elapsedTime += 1
        let stage = mountain.stages[mountain.currentStage]
        progress = elapsedTime / stage.duration
        
        if progress >= 1.0 {
            advanceToNextStage()
        }
        
        if Int(elapsedTime) % 60 == 0 {
            motivationalText = motivationalPhrases.randomElement() ?? "Keep going!"
        }
    }
    
    func advanceToNextStage() {
        elapsedTime = 0
        progress = 0.0
        mountain?.currentStage += 1
        
        if mountain?.currentStage ?? 0 >= mountain?.stages.count ?? 0 {
            stopClimb()
            // End of focus session
        }
    }
    
    func resetFlow() {
        isFlowActive = false
        focusGoal = ""
        selectedDuration = 1800
        elapsedTime = 0
        progress = 0.0
    }
}

// MARK: - Views

struct OnboardingView: View {
    @StateObject private var viewModel = FlowModeViewModel()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // MtnGraphic at the top, centered
                Image("MtnGraphic")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 200)
                    .padding(.top, 60)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                // Texts
                Text("Welcome to Flow Mode")
                    .font(.custom("SFProText-Heavy", size: 50))
                    .foregroundColor(.white)
                    .padding(.leading, 24) // Increased padding
                    .padding(.trailing, 24) // Increased padding
                
                Text("Let's get focused today!")
                    .font(.custom("SFProText-Bold", size: 22))
                    .foregroundColor(.white)
                    .padding(.leading, 24) // Increased padding
                    .padding(.trailing, 24) // Increased padding
                    .padding(.bottom, 20)
                
                // Start Focus Session button
                NavigationLink(destination: FocusGoalView(viewModel: viewModel)
                                .navigationBarBackButtonHidden(true)
                ) {
                    Text("Start Focus Session")
                        .font(.custom("SFProText-Bold", size: 20))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "081b3f")!)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30) // Added more horizontal padding to button
                .padding(.bottom, 20)
                
                // View Previous Sessions text (clickable)
                NavigationLink(destination: PreviousSessionsView()) {
                    Text("View Previous Sessions")
                        .font(.custom("SFProText-Bold", size: 18))
                        .foregroundColor(.white)
                        .padding(.leading, 24) // Increased padding for clickable text
                        .underline()
                }
                
                Spacer() // Push content to the top
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "183464")!, Color(hex: "86bbf2")!]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}



// A placeholder view for the "View Previous Sessions" screen.
struct PreviousSessionsView: View {
    var body: some View {
        Text("Previous Sessions Screen")
            .font(.title)
            .foregroundColor(.white)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}




struct FocusGoalView: View {
    @ObservedObject var viewModel: FlowModeViewModel
    @State private var focusGoal: String = "" // Live update for the entered text

    var body: some View {
        VStack(alignment: .leading) {
            Text("What’s your focus goal?")
                .font(.custom("SFProText-Heavy", size: 40))
                .foregroundColor(.white)
                .padding(.leading, 30) // Increased horizontal padding
                .padding(.top, 240)
            
            // This text will be replaced with live-updating text as the user types
            ZStack(alignment: .leading) {
                if focusGoal.isEmpty {
                    // Placeholder text with flickering cursor
                    Text("Start typing here...")
                        .font(.custom("SFProText-Bold", size: 22))
                        .foregroundColor(.white)
                        .opacity(0.5) // Faded effect for placeholder
                }

                // TextField for live-updating input with a transparent background
                TextField("", text: $focusGoal)
                    .font(.custom("SFProText-Bold", size: 22))
                    .foregroundColor(.white)
                    .background(Color.clear) // Ensure there's no background color
                    .accentColor(.white) // White flickering cursor
                    .disableAutocorrection(true) // Disable autocorrection if needed
            }
            .padding(.horizontal, 30) // Increased horizontal padding
            .padding(.top, 10)
            
            NavigationLink(destination: FocusDurationView(viewModel: viewModel)
                            .navigationBarBackButtonHidden(true)) {
                Text("Continue")
                    .font(.custom("SFProText-Bold", size: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "081b3f")!)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 30) // Increased horizontal padding
            .padding(.top, 20)
            
            Spacer()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "183464")!, Color(hex: "86bbf2")!]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
        )
    }
}







// Inside FocusDurationView, update the button structure to fix the navigation and text display

struct FocusDurationView: View {
    @ObservedObject var viewModel: FlowModeViewModel
    @State private var selectedDuration: TimeInterval = 1800 // Default to 30 minutes

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()

            Text("Set Duration")
                .font(.custom("SFProText-Heavy", size: 40))
                .foregroundColor(.white)
                .padding(.horizontal, 30) // Increased horizontal padding
                .padding(.top, 20)
            
            Text("Choose how long you want to focus for.")
                .font(.custom("SFProText-Bold", size: 18))
                .foregroundColor(.white)
                .padding(.horizontal, 30) // Increased horizontal padding
                .padding(.top, -20)
            
            Picker("Select duration", selection: $selectedDuration) {
                Text("30 minutes").tag(TimeInterval(1800))
                Text("60 minutes").tag(TimeInterval(3600))
                Text("1.5 hours").tag(TimeInterval(5400))
                Text("2 hours").tag(TimeInterval(7200))
                Text("2.5 hours").tag(TimeInterval(9000))
                Text("3 hours").tag(TimeInterval(10800))
            }
            .pickerStyle(WheelPickerStyle())
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .padding(.horizontal, 30) // Increased horizontal padding
            
            NavigationLink(destination: FocusTimerView(viewModel: viewModel)
                            .onAppear {
                                viewModel.selectedDuration = selectedDuration
                                viewModel.startNewFocusSession()
                            }
                            .navigationBarBackButtonHidden(true)) {
                Text("Start Timer")
                    .font(.custom("SFProText-Bold", size: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "081b3f")!)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 30) // Increased horizontal padding
            .padding(.top, 20)
            
            Spacer()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "183464")!, Color(hex: "86bbf2")!]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
        )
    }
}



struct VideoPlayerView: UIViewControllerRepresentable {
    var player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false // Hide playback controls
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // No need to update the player on every view update
    }
}


struct FocusTimerView: View {
    @ObservedObject var viewModel: FlowModeViewModel
    @State private var isPaused: Bool = false
    @State private var showGiveUpConfirmation: Bool = false
    @Environment(\.presentationMode) var presentationMode // To navigate back after giving up

    // Public initializer to allow external initialization
    init(viewModel: FlowModeViewModel) {
        self.viewModel = viewModel
    }

    // AVPlayer instance for video playback
    private var player: AVPlayer = {
        let url = Bundle.main.url(forResource: "mountainLoop", withExtension: "mp4")!
        let player = AVPlayer(url: url)
        player.isMuted = true // Optionally mute the video
        player.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: .zero)
            player.play() // Loop the video automatically
        }
        return player
    }()

    var body: some View {
        ZStack {
            // Video Player as the full background
            GeometryReader { geometry in
                VideoPlayerView(player: player)
                    .ignoresSafeArea(.all) // Extend video to fill the entire screen, ignoring safe area
                    .frame(width: geometry.size.width, height: geometry.size.height) // Set to full screen
                    .aspectRatio(contentMode: .fill) // Fill both width and height, cropping sides if needed
                    .scaleEffect(3.8) // Manually zoom in (adjust this value for more or less zoom)
                    .offset(x: 0, y: -70) // Adjust the position (y: -50 moves it upwards; adjust as needed)
                    .onAppear {
                        player.play() // Start video playback when view appears
                    }
            }

            // Foreground content (Text, Progress, Buttons, etc.)
            VStack {
                if let mountain = viewModel.mountain {
                    // Move climbing text up
                    Text("Climbing: \(mountain.name)")
                        .font(.custom("SFProText-Heavy", size: 35))
                        .foregroundColor(.black)
                        .padding(.top, 20) // Moved higher
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)

                    // Move progress bar up
                    ProgressBar(progress: viewModel.progress)
                        .frame(height: 20)
                        .padding(.horizontal, 20)
                        .padding(.top, 5) // Reduced padding to bring it closer to the climbing text

                    if mountain.currentStage < mountain.stages.count {
                        let currentStage = mountain.stages[mountain.currentStage]

                        // Move elevation climbed text up
                        Text("\(Int(calculateElevationClimbed())) feet climbed")
                            .font(.custom("SFProText-Bold", size: 18))
                            .foregroundColor(.black)
                            .padding(.top, 5) // Moved closer to the progress bar
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)

                        // Move total time left text up
                        Text(formatTotalTimeLeft())
                            .font(.custom("SFProText-Heavy", size: 70))
                            .foregroundColor(.black)
                            .padding(.top, 0) // Moved higher

                        Spacer() // Create more space between upper and lower sections

                        // Move motivational text down
                        Text(getMotivationalText(for: viewModel.selectedDuration - viewModel.elapsedTime))
                            .font(.custom("SFProText-Heavy", size: 24))
                            .foregroundColor(.black)
                            .padding(.top, 80) // Move closer to the buttons

                            .padding(.bottom, 0) // Move closer to the buttons
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)

                        // Move minutes until next break down
                        Text("\(minutesUntilNextBreak()) minutes until next break")
                            .font(.custom("SFProText-Bold", size: 18))
                            .foregroundColor(.black)
                            .padding(.bottom, 0) // Move closer to the buttons
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)

                        //Spacer()

                        // Pause and Give Up buttons at the bottom
                        HStack {
                            Button(action: {
                                if isPaused {
                                    viewModel.startClimb()
                                    player.play() // Resume video if paused
                                } else {
                                    viewModel.stopClimb()
                                    player.pause() // Pause video when timer is paused
                                }
                                isPaused.toggle()
                            }) {
                                Text(isPaused ? "Resume" : "Pause")
                                    .font(.custom("SFProText-Bold", size: 16)) // Made text smaller
                                    .foregroundColor(.white)
                                    .frame(width: 120, height: 45) // Reduced the button size
                                    .background(Color(hex: "1c4450")) // Updated to use #1c4450
                                    .cornerRadius(8) // Smaller corner radius for a more compact look
                            }
                            
                            Button(action: {
                                showGiveUpConfirmation.toggle()
                            }) {
                                Text("Give Up")
                                    .font(.custom("SFProText-Bold", size: 16)) // Made text smaller
                                    .foregroundColor(.white)
                                    .frame(width: 120, height: 45) // Reduced the button size
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white, lineWidth: 2) // White border around the button
                                    )
                            }
                            .alert(isPresented: $showGiveUpConfirmation) {
                                Alert(
                                    title: Text("Are you sure you want to give up?"),
                                    message: Text("This will end your current focus session."),
                                    primaryButton: .destructive(Text("Confirm")) {
                                        viewModel.resetFlow()
                                        presentationMode.wrappedValue.dismiss() // Navigate back
                                        player.pause() // Stop the video
                                    },
                                    secondaryButton: .cancel(Text("Return"))
                                )
                            }
                        }
                        .padding(.horizontal, 20) // Centered horizontally
                        .padding(.vertical, 10) // Added vertical padding to move the buttons upwards

                    } else {
                        Text("Congratulations! You've reached the summit!")
                            .font(.custom("SFProText-Heavy", size: 28))
                            .foregroundColor(.black)
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                }
                Spacer()
            }
            .padding(.top, 0) // Adjust padding as needed to keep content visible over the video
        }
        .onAppear {
            viewModel.startClimb()
        }
        .onDisappear {
            viewModel.stopClimb()
        }
    }

    // Updated formatTotalTimeLeft to display HOUR:MINUTE when above an hour
    func formatTotalTimeLeft() -> String {
        let totalTimeElapsed = viewModel.elapsedTime
        let totalDuration = viewModel.selectedDuration
        let timeLeft = totalDuration - totalTimeElapsed
        let hours = Int(timeLeft) / 3600
        let minutes = (Int(timeLeft) % 3600) / 60
        let seconds = Int(timeLeft) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    // Calculates the elevation climbed based on the total progress
    func calculateElevationClimbed() -> Double {
        guard let mountain = viewModel.mountain else { return 0 }
        let totalElevation = mountain.elevation
        let totalDuration = viewModel.selectedDuration
        let totalProgress = viewModel.elapsedTime / totalDuration
        return totalElevation * totalProgress
    }

    // Returns motivational text based on time left
    func getMotivationalText(for timeRemaining: TimeInterval) -> String {
        switch timeRemaining {
        case let t where t > 1200:
            return "The journey has just begun, stay focused!"
        case let t where t > 600:
            return "You're doing great, keep pushing!"
        case let t where t > 300:
            return "Almost there, don't lose focus!"
        case let t where t > 60:
            return "Final stretch, stay strong!"
        default:
            return "Almost at the summit, keep pushing!"
        }
    }

    func minutesUntilNextBreak() -> Int {
        guard let mountain = viewModel.mountain else { return 0 }
        let currentStage = mountain.stages[mountain.currentStage]
        let timeLeftInStage = currentStage.duration - viewModel.elapsedTime
        return Int(timeLeftInStage / 60)
    }
}



struct PulsatingCircle: View {
    var color: Color
    @State private var animate = false
    
    var body: some View {
        Circle()
            .fill(color)
            .scaleEffect(animate ? 1.2 : 0.95)
            .opacity(animate ? 0.7 : 1.0)
            .animation(
                Animation.easeInOut(duration: 1)
                    .repeatForever(autoreverses: true),
                value: animate
            )
            .onAppear {
                self.animate = true
            }
    }
}


// MARK: - Progress Bar

// MARK: - Progress Bar

struct ProgressBar: View {
    var progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // White background behind the blue progress bar
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .foregroundColor(.white) // White background with full opacity
                
                // Blue progress bar with the progress value
                Rectangle()
                    .frame(width: min(CGFloat(self.progress) * geometry.size.width, geometry.size.width),
                           height: geometry.size.height)
                    .foregroundColor(Color(hex: "1c4450")) // Updated color to #1c4450
                    .animation(.linear, value: progress) // Animate progress changes
            }
            .cornerRadius(10) // Rounded corners for the progress bar
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black.opacity(0.7), lineWidth: 1) // Border around the progress bar for visibility
            )
        }
    }
}


// MARK: - Helpers

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

// MARK: - Preview

//struct OnboardingView_Previews: PreviewProvider {
//    static var previews: some View {
//        OnboardingView()
//    }
//}

// MARK: - Preview for FocusTimerView with one-hour timer

struct FocusTimerView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = FlowModeViewModel()
        
        // Set up a sample mountain and one-hour duration for testing purposes
        viewModel.mountain = Mountain(name: "Test Mountain", elevation: 10000, stages: [
            Stage(name: "First Stage", duration: 1500, sceneryColor: .green),
            Stage(name: "Break", duration: 300, sceneryColor: .blue),
            Stage(name: "Second Stage", duration: 1500, sceneryColor: .yellow),
            Stage(name: "Break", duration: 300, sceneryColor: .blue),
            Stage(name: "Final Stage", duration: 1500, sceneryColor: .gray),
            Stage(name: "Summit", duration: 300, sceneryColor: .white)
        ])
        
        viewModel.selectedDuration = 3600 // One hour duration
        viewModel.startNewFocusSession()  // Start the focus session

        return FocusTimerView(viewModel: viewModel)
    }
}
