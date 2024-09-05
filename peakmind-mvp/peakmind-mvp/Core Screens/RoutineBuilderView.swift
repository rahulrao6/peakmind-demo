import SwiftUI

struct GradientProgressViewStyleWithLabel: ProgressViewStyle {
    var gradient: LinearGradient
    var title: String
    var currentValue: Int
    var totalValue: Int
    var unit: String

    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background bar
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 60)

                // Progress bar
                RoundedRectangle(cornerRadius: 10)
                    .fill(gradient)
                    .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * geometry.size.width, height: 60)

                // Text inside the progress bar
                HStack {
                    Text(title) // Title on the left side of the bar
                        .font(.custom("SFProText-Heavy", size: 16))
                        .foregroundColor(.white)
                        .padding(.leading, 10)

                    Spacer()

                    Text("\(currentValue)/\(totalValue) \(unit)") // Count on the right side of the bar
                        .font(.custom("SFProText-Heavy", size: 16))
                        .foregroundColor(.white)
                        .padding(.trailing, 10)
                }
                .frame(width: geometry.size.width)
            }
        }
        .frame(height: 60)
    }
}

struct RoutineBuilderView: View {
    @State private var selectedRoutines: Set<String> = ["All"]

    // Updated progress counts and habit details
    @State private var waterCount = 5
    @State private var readCount = 4
    @State private var runCount = 1
    @State private var mealsCount = 2
    @State private var gymCount = 1
    @State private var meditateCount = 0
    
    @State private var progressWater: CGFloat = 0.5
    @State private var progressRun: CGFloat = 0.5
    @State private var progressRead: CGFloat = 0.27
    @State private var progressMeals: CGFloat = 0.66
    @State private var progressGym: CGFloat = 1.0
    @State private var progressMeditate: CGFloat = 0.0

    @State private var showingIncrementPopup: Bool = false
    @State private var selectedTracker: String = ""

    var body: some View {
        ZStack {
            // Background Image that doesn't affect other elements
            GeometryReader { geometry in
                Image("RoutineBG")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    // Title on the top left (increased font size)
                    Text("Your Routines")
                        .font(.custom("SFProText-Heavy", size: 28)) // Increased font size
                        .foregroundColor(.white)
                        .padding(.leading, 20)

                    Spacer()

                    // Dropdown Filter on the top right (smaller size and color change to #6b58db)
                    Menu {
                        Button("All") { selectedRoutines = ["All"] }
                        Button("Morning Routine") { selectedRoutines = ["Morning Routine"] }
                        Button("Afternoon Routine") { selectedRoutines = ["Afternoon Routine"] }
                        Button("Evening Routine") { selectedRoutines = ["Evening Routine"] }
                    } label: {
                        Text(selectedRoutines.first ?? "All")
                            .font(.custom("SFProText-Heavy", size: 14))
                            .frame(width: 50, height: 5)
                            .padding()
                            .background(Color(hex: "6b58db")) // Changed to #6b58db
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.trailing, 20)
                    }
                }
                .padding(.top, 40)

                // Scrollable Calendar View with Progress for Today's Date
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(0..<30, id: \.self) { index in
                            let date = Calendar.current.date(byAdding: .day, value: index, to: Date()) ?? Date()
                            VStack {
                                ZStack(alignment: .bottom) {
                                    // Background rectangle
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Calendar.current.isDateInToday(date) ? Color.black.opacity(0.4) : Color.gray.opacity(0.0))
                                        .frame(width: 50, height: 80)

                                    // Only show progress bar for today's date
                                    if Calendar.current.isDateInToday(date) {
                                        let totalProgress = (progressWater + progressRun + progressRead + progressMeals + progressGym + progressMeditate) / 6
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(hex: "6b58db")!) // Changed fill color for today's progress bar
                                            .frame(width: 50, height: 80 * totalProgress)
                                    }

                                    VStack {
                                        // Updated font and color for the day and date
                                        Text(getDayAbbreviation(for: date))
                                            .font(.custom("SFProText-Bold", size: 12))
                                            .foregroundColor(.white)
                                        Text("\(getDateNumber(for: date))")
                                            .font(.custom("SFProText-Heavy", size: 16))
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, -5)

                // Scrollable Progress Bars
                ScrollView {
                    VStack(spacing: 20) {
                        // Morning Routine
                        if selectedRoutines.contains("All") || selectedRoutines.contains("Morning Routine") {
                            ProgressView(value: progressWater)
                                .progressViewStyle(GradientProgressViewStyleWithLabel(
                                    gradient: LinearGradient(gradient: Gradient(colors: [Color(hex: "20a4cc")!, Color(hex: "6945b9")!]), startPoint: .leading, endPoint: .trailing),
                                    title: "Drink 10 cups of water",
                                    currentValue: waterCount,
                                    totalValue: 10,
                                    unit: "cups"
                                ))
                                .onTapGesture {
                                    selectedTracker = "Water"
                                    showingIncrementPopup.toggle()
                                }
                                .gesture(DragGesture(minimumDistance: 10)
                                    .onEnded { value in
                                        if value.translation.width < 0 {
                                            if waterCount > 0 {
                                                waterCount -= 1
                                                progressWater = CGFloat(waterCount) / 10
                                            }
                                        } else if value.translation.width > 0 {
                                            if waterCount < 10 {
                                                waterCount += 1
                                                progressWater = CGFloat(waterCount) / 10
                                            }
                                        }
                                    }
                                )
                                .padding(.horizontal)
                        }
                        
                        // Afternoon Routine
                        if selectedRoutines.contains("All") || selectedRoutines.contains("Afternoon Routine") {
                            ProgressView(value: progressRead)
                                .progressViewStyle(GradientProgressViewStyleWithLabel(
                                    gradient: LinearGradient(gradient: Gradient(colors: [Color(hex: "12d6df")!, Color(hex: "f70fff")!]), startPoint: .leading, endPoint: .trailing),
                                    title: "Read 15 pages of book",
                                    currentValue: readCount,
                                    totalValue: 15,
                                    unit: "pages"
                                ))
                                .onTapGesture {
                                    selectedTracker = "Read"
                                    showingIncrementPopup.toggle()
                                }
                                .gesture(DragGesture(minimumDistance: 10)
                                    .onEnded { value in
                                        if value.translation.width < 0 {
                                            if readCount > 0 {
                                                readCount -= 1
                                                progressRead = CGFloat(readCount) / 15
                                            }
                                        } else if value.translation.width > 0 {
                                            if readCount < 15 {
                                                readCount += 1
                                                progressRead = CGFloat(readCount) / 15
                                            }
                                        }
                                    }
                                )
                                .padding(.horizontal)

                            ProgressView(value: progressRun)
                                .progressViewStyle(GradientProgressViewStyleWithLabel(
                                    gradient: LinearGradient(gradient: Gradient(colors: [Color(hex: "b3b6eb")!, Color(hex: "e98a98")!]), startPoint: .leading, endPoint: .trailing),
                                    title: "Go for 2 runs",
                                    currentValue: runCount,
                                    totalValue: 2,
                                    unit: "runs"
                                ))
                                .onTapGesture {
                                    selectedTracker = "Run"
                                    showingIncrementPopup.toggle()
                                }
                                .gesture(DragGesture(minimumDistance: 10)
                                    .onEnded { value in
                                        if value.translation.width < 0 {
                                            if runCount > 0 {
                                                runCount -= 1
                                                progressRun = CGFloat(runCount) / 2
                                            }
                                        } else if value.translation.width > 0 {
                                            if runCount < 2 {
                                                runCount += 1
                                                progressRun = CGFloat(runCount) / 2
                                            }
                                        }
                                    }
                                )
                                .padding(.horizontal)
                        }

                        // Evening Routine
                        if selectedRoutines.contains("All") || selectedRoutines.contains("Evening Routine") {
                            ProgressView(value: progressMeals)
                                .progressViewStyle(GradientProgressViewStyleWithLabel(
                                    gradient: LinearGradient(gradient: Gradient(colors: [Color(hex: "f2f047")!, Color(hex: "1ed94f")!]), startPoint: .leading, endPoint: .trailing),
                                    title: "Eat 3 meals",
                                    currentValue: mealsCount,
                                    totalValue: 3,
                                    unit: "meals"
                                ))
                                .onTapGesture {
                                    selectedTracker = "Meals"
                                    showingIncrementPopup.toggle()
                                }
                                .gesture(DragGesture(minimumDistance: 10)
                                    .onEnded { value in
                                        if value.translation.width < 0 {
                                            if mealsCount > 0 {
                                                mealsCount -= 1
                                                progressMeals = CGFloat(mealsCount) / 3
                                            }
                                        } else if value.translation.width > 0 {
                                            if mealsCount < 3 {
                                                mealsCount += 1
                                                progressMeals = CGFloat(mealsCount) / 3
                                            }
                                        }
                                    }
                                )
                                .padding(.horizontal)

                            ProgressView(value: progressGym)
                                .progressViewStyle(GradientProgressViewStyleWithLabel(
                                    gradient: LinearGradient(gradient: Gradient(colors: [Color(hex: "b6359c")!, Color(hex: "ef0a6a")!]), startPoint: .leading, endPoint: .trailing),
                                    title: "Go to the gym",
                                    currentValue: gymCount,
                                    totalValue: 1,
                                    unit: ""
                                ))
                                .onTapGesture {
                                    selectedTracker = "Gym"
                                    showingIncrementPopup.toggle()
                                }
                                .gesture(DragGesture(minimumDistance: 10)
                                    .onEnded { value in
                                        if gymCount > 0 {
                                            gymCount -= 1
                                            progressGym = CGFloat(gymCount) / 1
                                        }
                                    }
                                )
                                .padding(.horizontal)

                            ProgressView(value: progressMeditate)
                                .progressViewStyle(GradientProgressViewStyleWithLabel(
                                    gradient: LinearGradient(gradient: Gradient(colors: [Color(hex: "fedc45")!, Color(hex: "fb7099")!]), startPoint: .leading, endPoint: .trailing),
                                    title: "Meditate",
                                    currentValue: meditateCount,
                                    totalValue: 1,
                                    unit: ""
                                ))
                                .onTapGesture {
                                    selectedTracker = "Meditate"
                                    showingIncrementPopup.toggle()
                                }
                                .gesture(DragGesture(minimumDistance: 10)
                                    .onEnded { value in
                                        if meditateCount > 0 {
                                            meditateCount -= 1
                                            progressMeditate = CGFloat(meditateCount) / 1
                                        }
                                    }
                                )
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, -500) // Add padding at the bottom to ensure scrolling extends below the floating button


                Spacer()

                // Floating Add Habit Button (adjusted to float over the progress bars)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            // Add functionality for adding habits
                        }) {
                            HStack {
                                Text("Add Habit +")
                                    .font(.custom("SFProText-Bold", size: 16))
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                            .padding()
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .sheet(isPresented: $showingIncrementPopup) {
                IncrementView(
                    tracker: selectedTracker,
                    waterCount: $waterCount,
                    runCount: $runCount,
                    readCount: $readCount,
                    mealsCount: $mealsCount,
                    gymCount: $gymCount,
                    meditateCount: $meditateCount,
                    progressWater: $progressWater,
                    progressRun: $progressRun,
                    progressRead: $progressRead,
                    progressMeals: $progressMeals,
                    progressGym: $progressGym,
                    progressMeditate: $progressMeditate
                )
            }
        }
    }

    // Helper functions for calendar view
    func getDayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    func getDateNumber(for date: Date) -> Int {
        return Calendar.current.component(.day, from: date)
    }
}

struct IncrementView: View {
    var tracker: String
    @Binding var waterCount: Int
    @Binding var runCount: Int
    @Binding var readCount: Int
    @Binding var mealsCount: Int
    @Binding var gymCount: Int
    @Binding var meditateCount: Int
    @Binding var progressWater: CGFloat
    @Binding var progressRun: CGFloat
    @Binding var progressRead: CGFloat
    @Binding var progressMeals: CGFloat
    @Binding var progressGym: CGFloat
    @Binding var progressMeditate: CGFloat

    var body: some View {
        VStack {
            Text("Increment \(tracker)")
                .font(.largeTitle)
                .padding()

            Button(action: {
                switch tracker {
                case "Water":
                    if waterCount < 10 {
                        waterCount += 1
                        progressWater = CGFloat(waterCount) / 10
                    }
                case "Run":
                    if runCount < 2 {
                        runCount += 1
                        progressRun = CGFloat(runCount) / 2
                    }
                case "Read":
                    if readCount < 15 {
                        readCount += 1
                        progressRead = CGFloat(readCount) / 15
                    }
                case "Meals":
                    if mealsCount < 3 {
                        mealsCount += 1
                        progressMeals = CGFloat(mealsCount) / 3
                    }
                case "Gym":
                    if gymCount < 1 {
                        gymCount += 1
                        progressGym = CGFloat(gymCount) / 1
                    }
                case "Meditate":
                    if meditateCount < 1 {
                        meditateCount += 1
                        progressMeditate = CGFloat(meditateCount) / 1
                    }
                default:
                    break
                }
            }) {
                Text("Increment")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
    }
}

struct RoutineBuilderView_Previews: PreviewProvider {
    static var previews: some View {
        RoutineBuilderView()
    }
}
