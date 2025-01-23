import SwiftUI

struct OnboardingStartView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Background with Linear Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "112864")!, Color(hex: "23429a")!]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                VStack(spacing: 10) {
                    Text("Welcome to PeakMind!")
                        .font(.custom("SFProText-Heavy", size: 40))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)


                    Text("Your journey to mental clarity, balance, and self-discovery starts here. Let’s personalize your experience.")
                        .font(.custom("SFProText-Bold", size: 26))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()

                    NavigationLink(destination: GoalSelectionView()) {
                        Text("Get Started")
                            .font(.custom("SFProText-Bold", size: 24))
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "b0e8ff")!)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
    }
}

struct GoalSelectionView: View {
    var body: some View {
        ZStack {
            // Background with Linear Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "112864")!, Color(hex: "23429a")!]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("What is your primary goal with PeakMind?")
                    .font(.custom("SFProText-Heavy", size: 30))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)


                ForEach(["Improve Productivity", "Improve Mental Wellness"], id: \ .self) { goal in
                    NavigationLink(destination: nextView(for: goal)) {
                        Text(goal)
                            .font(.custom("SFProText-Bold", size: 24))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "0b1953")!)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
    }

    func nextView(for goal: String) -> some View {
        switch goal {
        case "Improve Productivity": return AnyView(ProductivityPathView())
        case "Improve Mental Wellness": return AnyView(MentalWellnessPathView())
        default: return AnyView(EmptyView())
        }
    }
}

struct ProductivityPathView: View {
    var body: some View {
        ZStack {
            // Background with Linear Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "112864")!, Color(hex: "23429a")!]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("What’s your focus?")
                    .font(.custom("SFProText-Heavy", size: 32))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)


                ForEach(["Focus Better", "Build Better Habits"], id: \ .self) { option in
                    NavigationLink(destination: nextView(for: option)) {
                        Text(option)
                            .font(.custom("SFProText-Bold", size: 24))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "0b1953")!)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
    }

    func nextView(for option: String) -> some View {
        switch option {
        case "Focus Better": return AnyView(FlowStateModuleView())
        case "Build Better Habits": return AnyView(HabitModuleView())
        default: return AnyView(EmptyView())
        }
    }
}

struct MentalWellnessPathView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "112864")!, Color(hex: "23429a")!]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack {
                Text("Profiles Onboarding")
                    .font(.custom("SFProText-Heavy", size: 40))
                    .foregroundColor(.white)
                    .padding()
                    .multilineTextAlignment(.center)

                Text("Placeholder for personalized action module.")
                    .font(.custom("SFProText-Bold", size: 24))
                    .foregroundColor(.white)
                    .padding()
                    .multilineTextAlignment(.center)

                NavigationLink(destination: SelectToolsView()) {
                    Text("Next")
                        .font(.custom("SFProText-Bold", size: 24))
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "b0e8ff")!)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}

struct SelectToolsView: View {
    @State private var selectedTools: Set<String> = [] // Track selected tools

    let tools = ["Sherpa", "Journal", "Flow Mode"] // List of tools

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "112864")!, Color(hex: "23429a")!]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Select Tools to Unlock")
                    .font(.custom("SFProText-Heavy", size: 40))
                    .foregroundColor(.white)
                    .padding()
                    .multilineTextAlignment(.center)

                // List of tools with checkboxes
                ForEach(tools, id: \.self) { tool in
                    HStack {
                        // Checkbox
                        Image(systemName: selectedTools.contains(tool) ? "checkmark.square.fill" : "square")
                            .foregroundColor(selectedTools.contains(tool) ? Color(hex: "b0e8ff")! : .white)
                            .font(.system(size: 24))
                            .onTapGesture {
                                toggleSelection(for: tool)
                            }

                        // Tool name
                        Text(tool)
                            .font(.custom("SFProText-Bold", size: 24))
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedTools.contains(tool) ? Color(hex: "b0e8ff")! : Color(hex: "0b1953")!)
                            )
                            .onTapGesture {
                                toggleSelection(for: tool)
                            }
                    }
                    .padding(.horizontal)
                }

                Spacer()

                // Finish button
                NavigationLink(destination: DashboardWalkthroughView()) {
                    Text("Finish")
                        .font(.custom("SFProText-Bold", size: 24))
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "b0e8ff")!)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 50)
            }
            .padding()
        }
    }

    // Toggle tool selection
    private func toggleSelection(for tool: String) {
        if selectedTools.contains(tool) {
            selectedTools.remove(tool)
        } else {
            selectedTools.insert(tool)
        }
    }
}

struct DashboardWalkthroughView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "112864")!, Color(hex: "23429a")!]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 40) {
                Text("Your PeakMind journey begins now!")
                    .font(.custom("SFProText-Heavy", size: 40))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)


                Button(action: {
                    // Navigate to Home Dashboard
                }) {
                    Text("Go to Dashboard")
                        .font(.custom("SFProText-Bold", size: 24))
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "b0e8ff")!)
                        .cornerRadius(12)
                        .multilineTextAlignment(.center)

                }
            }
            .padding()
        }
    }
}

struct PeakMindOnboarding_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingStartView()
            GoalSelectionView()
            ProductivityPathView()
            MentalWellnessPathView()
            SelectToolsView()
            DashboardWalkthroughView()
        }
    }
}
