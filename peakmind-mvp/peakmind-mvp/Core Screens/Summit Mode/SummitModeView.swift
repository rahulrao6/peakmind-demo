import SwiftUI
import Foundation


struct Mountain: Identifiable {
    let id = UUID()
    let name: String
    let stages: [Stage]
    var currentStage: Int = 0
}

struct Stage {
    let name: String
    let duration: TimeInterval
    let sceneryColor: Color
}

// MARK: - ViewModel

class SummitModeViewModel: ObservableObject {
    @Published var mountain: Mountain
    @Published var elapsedTime: TimeInterval = 0
    @Published var isClimbing: Bool = false
    @Published var progress: Double = 0.0
    
    private var timer: Timer?
    
    init(mountain: Mountain) {
        self.mountain = mountain
    }
    
    func startClimb() {
        isClimbing = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.updateProgress()
        }
    }
    
    func stopClimb() {
        isClimbing = false
        timer?.invalidate()
        timer = nil
    }
    
    func updateProgress() {
        guard isClimbing, mountain.currentStage < mountain.stages.count else { return }
        
        elapsedTime += 1
        let stageDuration = mountain.stages[mountain.currentStage].duration
        progress = elapsedTime / stageDuration
        
        if progress >= 1.0 {
            advanceToNextStage()
        }
    }
    
    func advanceToNextStage() {
        elapsedTime = 0
        progress = 0.0
        mountain.currentStage += 1
        
        if mountain.currentStage >= mountain.stages.count {
            stopClimb()
            // Trigger summit reached logic here
        }
    }
}

// MARK: - Views

struct SummitModeView: View {
    @StateObject private var viewModel: SummitModeViewModel
    
    init(mountain: Mountain) {
        _viewModel = StateObject(wrappedValue: SummitModeViewModel(mountain: mountain))
    }
    
    var body: some View {
        VStack {
            Text("Climbing: \(viewModel.mountain.name)")
                .font(.largeTitle)
                .padding()
            
            if viewModel.mountain.currentStage < viewModel.mountain.stages.count {
                let currentStage = viewModel.mountain.stages[viewModel.mountain.currentStage]
                
                currentStage.sceneryColor
                    .frame(height: 200)
                    .cornerRadius(10)
                    .padding()
                
                Text("Stage: \(currentStage.name)")
                    .font(.headline)
                    .padding()
                
                ProgressBar(progress: viewModel.progress)
                    .frame(height: 20)
                    .padding()
                
                Button(viewModel.isClimbing ? "Pause Climb" : "Start Climb") {
                    viewModel.isClimbing ? viewModel.stopClimb() : viewModel.startClimb()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            } else {
                Text("Congratulations! You've reached the summit!")
                    .font(.headline)
                    .padding()
            }
        }
        .padding()
    }
}

struct ProgressBar: View {
    var progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(.gray)
                
                Rectangle()
                    .frame(width: min(CGFloat(self.progress) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(.blue)
                    .animation(.linear, value: progress)
            }
            .cornerRadius(10)
        }
    }
}

// MARK: - Preview

struct SummitModeView_Previews: PreviewProvider {
    static var previews: some View {
        SummitModeView(mountain: Mountain(
            name: "Mount Everest",
            stages: [
                Stage(name: "Basecamp", duration: 10, sceneryColor: .green),
                Stage(name: "Alpine Meadows", duration: 20, sceneryColor: .yellow),
                Stage(name: "Glacier", duration: 30, sceneryColor: .gray),
                Stage(name: "Summit", duration: 40, sceneryColor: .white)
            ]
        ))
    }
}

// MARK: - App Entry Point

struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            SummitModeView(mountain: Mountain(
                name: "Mount Everest",
                stages: [
                    Stage(name: "Basecamp", duration: 10, sceneryColor: .green),
                    Stage(name: "Alpine Meadows", duration: 20, sceneryColor: .yellow),
                    Stage(name: "Glacier", duration: 30, sceneryColor: .gray),
                    Stage(name: "Summit", duration: 40, sceneryColor: .white)
                ]
            ))
        }
    }
}
