import SwiftUI

//struct SelfCareNew: View {
//    @State private var showingAddWidget = false
//    @State private var editingWidget: CustomWidget? = nil
//    @State private var isEditMode = false
//    @State private var selectedWidget: CustomWidget?
//    @State private var showingQuestionsSheet = false
//    @State private var showingPPSheet = false
//
//    
//    @EnvironmentObject var viewModel: AuthViewModel
//
//    @State private var widgets: [CustomWidget] = [
//        CustomWidget(name: "Steps", frequency: .daily, unit: .count, specificUnit: "steps", value: 1000, description: "Daily steps count", percentageChange: 5),
//        CustomWidget(name: "Water", frequency: .multipleTimesDaily, unit: .volume, specificUnit: "liters", value: 2, description: "Daily water intake", percentageChange: -3),
//        CustomWidget(name: "Reading", frequency: .daily, unit: .time, specificUnit: "minutes", value: 30, description: "Daily reading time", percentageChange: 8),
//        CustomWidget(name: "Exercise", frequency: .daily, unit: .time, specificUnit: "minutes", value: 60, description: "Daily exercise time", percentageChange: 10),
//        CustomWidget(name: "Meditation", frequency: .daily, unit: .time, specificUnit: "minutes", value: 15, description: "Daily meditation time", percentageChange: 2),
//        CustomWidget(name: "Sleep", frequency: .daily, unit: .time, specificUnit: "hours", value: 8, description: "Daily sleep duration", percentageChange: 1)
//    ]
//    
//    let cardWidth: CGFloat = 200
//    let cardHeight: CGFloat = 250
//    let cardSpacing: CGFloat = -70
//    let defaultUsername: String = "User" // Default username for preview
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 0) {
//                // Top Section
//                ZStack {
//                    Image("Header")
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(height: 100)
//                        .edgesIgnoringSafeArea(.top)
//                    
//                    HStack {
//                        VStack(alignment: .leading) {
//                            Text("Welcome, \(defaultUsername)!")
//                                .fontWeight(.bold)
//                                .foregroundColor(.black)
//                                .font(.title)
//                            
//                            Text("Check out your analytics below.")
//                                .fontWeight(.semibold)
//                                .foregroundColor(.black)
//                                .font(.body)
//                        }
//                        .padding()
//                        
//                        Spacer()
//                        
//                        Image("Sherpa")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 80, height: 80)
//                            .padding()
//                    }
//                    .padding(.top, 50) // Adjust top padding to position the text and image
//                }
//                .frame(height: 70)
//
//                CustomButton2(title: "Daily Check In", onClick: {
//                    Task{
//                    }
//                })
//                .padding(.top, 60)
//                .padding(.bottom, -41)
//                
//                // Widgets Section
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: cardSpacing) {
//                        ForEach(widgets.indices, id: \.self) { index in
//                            WidgetView2(widget: $widgets[index], isEditMode: $isEditMode)
//                                .frame(width: cardWidth, height: cardHeight)
//                                .onTapGesture {
//                                    if isEditMode {
//                                        editingWidget = widgets[index]
//                                    }
//                                }
//                        }
//                        AddWidgetButton {
//                            showingAddWidget = true
//                        }
//                        .frame(width: cardWidth, height: cardHeight)
//                    }
//                    .padding(.horizontal)
//                }
//                .padding(.top)
//                .padding(.leading, -48)
//
//                // Edit Widgets Button
//                CustomButton3(title: isEditMode ? "Done" : "Edit Widgets", onClick: {
//                    isEditMode.toggle()
//                })
//                .frame(width: 390) // Smaller width for the button
//                .padding(.top, -30)
//                // Swipeable Graph Interface
//                GeometryReader { geometry in
//                    TabView {
//                        ForEach(0..<((widgets.count + 1) / 2), id: \.self) { index in
//                            HStack(spacing: -1) { // Set the spacing to 0 or any value you prefer
//                                ForEach(0..<2) { subIndex in
//                                    if index * 2 + subIndex < widgets.count {
//                                        GraphCardView(widget: widgets[index * 2 + subIndex])
//                                            .frame(width: geometry.size.width / 2)
//                                            .onTapGesture {
//                                                selectedWidget = widgets[index * 2 + subIndex]
//                                            }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Remove page indicators
//                }
//                .frame(height: 120) // Set height for the graph cards
//                .padding(.bottom)
//                CustomButton2(title: "Detailed Analytics", onClick: {
//                    Task{
//                    }
//                })
//                .padding(.top, -14)
//                .padding(.bottom, -41)
//                if (viewModel.currentUser?.hasCompletedInitialQuiz) {
//                    CustomButton2(title: "View Personalized Plan", onClick: {
//                        showingPPSheet = true
//                    })
//                    .padding(.top, -14)
//                    .padding(.bottom, -41)
//                }
//                Spacer()
//            }
//            .onAppear {
//                if !viewModel.currentUser?.hasCompletedInitialQuiz {
//                    showingQuestionsSheet = true
//                }
//            }
//            .background(Color.sentMessage.edgesIgnoringSafeArea(.all))
//            .navigationBarHidden(true)
//            .sheet(isPresented: $showingAddWidget) {
//                AddWidgetView(widgets: $widgets)
//            }
//            .sheet(item: $editingWidget) { widget in
//                AddWidgetView(widgets: $widgets, widgetToEdit: widget)
//            }
//            .sheet(item: $selectedWidget) { widget in
//                WidgetDetailView(widget: widget)
//            }
//            .sheet(isPresented: $showingQuestionsSheet, onDismiss: {
//                Task{
//                    try await viewModel.fetchUser()
//                }
//                
//            }) {  // Sheet is presented based on the state
//                PPContentView()
//                    .environmentObject(viewModel)  // Ensure the view model is passed if needed
//            }
//            
//            .sheet(isPresented: $showingPPSheet, onDismiss: {
//                showingPPSheet = false
//                
//            }) {  // Sheet is presented based on the state
//                PPOverView()
//                    .environmentObject(viewModel)  // Ensure the view model is passed if needed
//            }
//        }
//    }
//}
//struct SelfCareNew: View {
//    @State private var showingAddWidget = false
//    @State private var editingWidget: CustomWidget? = nil
//    @State private var isEditMode = false
//    @State private var selectedWidget: CustomWidget?
//    @State private var showingQuestionsSheet = false
//    @State private var showingPPSheet = false
//
//    @EnvironmentObject var viewModel: AuthViewModel
//
//    @State private var widgets: [CustomWidget] = [
//        CustomWidget(name: "Steps", frequency: .daily, unit: .count, specificUnit: "steps", value: 1000, description: "Daily steps count", percentageChange: 5),
//        CustomWidget(name: "Water", frequency: .multipleTimesDaily, unit: .volume, specificUnit: "liters", value: 2, description: "Daily water intake", percentageChange: -3),
//        CustomWidget(name: "Reading", frequency: .daily, unit: .time, specificUnit: "minutes", value: 30, description: "Daily reading time", percentageChange: 8),
//        CustomWidget(name: "Exercise", frequency: .daily, unit: .time, specificUnit: "minutes", value: 60, description: "Daily exercise time", percentageChange: 10),
//        CustomWidget(name: "Meditation", frequency: .daily, unit: .time, specificUnit: "minutes", value: 15, description: "Daily meditation time", percentageChange: 2),
//        CustomWidget(name: "Sleep", frequency: .daily, unit: .time, specificUnit: "hours", value: 8, description: "Daily sleep duration", percentageChange: 1)
//    ]
//    
//    let cardWidth: CGFloat = 200
//    let cardHeight: CGFloat = 250
//    let cardSpacing: CGFloat = -70
//    let defaultUsername: String = "User" // Default username for preview
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 0) {
//                // Top Section
//                topSection
//
//                CustomButton2(title: "Daily Check In", onClick: {
//                    // Handle Daily Check In
//                })
//                .padding(.top, 60)
//                .padding(.bottom, -41)
//                
//                // Widgets Section
//                ScrollView(.horizontal, showsIndicators: false) {
//                    widgetsSection
//                }
//                .padding(.top)
//                .padding(.leading, -48)
//
//                // Edit Widgets Button
//                CustomButton3(title: isEditMode ? "Done" : "Edit Widgets", onClick: {
//                    isEditMode.toggle()
//                })
//                .frame(width: 390) // Smaller width for the button
//                .padding(.top, -30)
//                
//                // Swipeable Graph Interface
//                swipeableGraphInterface
//                
//                CustomButton2(title: "Detailed Analytics", onClick: {
//                    // Handle Detailed Analytics
//                })
//                .padding(.top, -14)
//                .padding(.bottom, -41)
//                Spacer()
//                if viewModel.currentUser?.hasCompletedInitialQuiz ?? false {
//                    CustomButton2(title: "View Personalized Plan", onClick: {
//                        showingPPSheet = true
//                    })
//                }
//                
//            }
//            .onAppear {
//                if !(viewModel.currentUser?.hasCompletedInitialQuiz ?? false) {
//                    showingQuestionsSheet = true
//                }
//            }
//            .background(Color.sentMessage.edgesIgnoringSafeArea(.all))
//            .navigationBarHidden(true)
//            .sheet(isPresented: $showingAddWidget) {
//                AddWidgetView(widgets: $widgets)
//            }
//            .sheet(item: $editingWidget) { widget in
//                AddWidgetView(widgets: $widgets, widgetToEdit: widget)
//            }
//            .sheet(item: $selectedWidget) { widget in
//                WidgetDetailView(widget: widget)
//            }
//            .sheet(isPresented: $showingQuestionsSheet, onDismiss: {
//                Task {
//                    try await viewModel.fetchUser()
//                }
//            }) {
//                PPContentView().environmentObject(viewModel)
//            }
//            .sheet(isPresented: $showingPPSheet) {
//                PersonalizedPlanView().environmentObject(viewModel)
//            }
//        }
//    }
//    
//    // Extracted Subviews
//    private var topSection: some View {
//        ZStack {
//            Image("Header")
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(height: 100)
//                .edgesIgnoringSafeArea(.top)
//            
//            HStack {
//                VStack(alignment: .leading) {
//                    Text("Welcome, \(defaultUsername)!")
//                        .fontWeight(.bold)
//                        .foregroundColor(.black)
//                        .font(.title)
//                    
//                    Text("Check out your analytics below.")
//                        .fontWeight(.semibold)
//                        .foregroundColor(.black)
//                        .font(.body)
//                }
//                .padding()
//                
//                Spacer()
//                
//                Image("Sherpa")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 80, height: 80)
//                    .padding()
//            }
//            .padding(.top, 50)
//        }
//        .frame(height: 70)
//    }
//
//    private var widgetsSection: some View {
//        HStack(spacing: cardSpacing) {
//            ForEach(widgets.indices, id: \.self) { index in
//                WidgetView2(widget: $widgets[index], isEditMode: $isEditMode)
//                    .frame(width: cardWidth, height: cardHeight)
//                    .onTapGesture {
//                        if isEditMode {
//                            editingWidget = widgets[index]
//                        }
//                    }
//            }
//            AddWidgetButton {
//                showingAddWidget = true
//            }
//            .frame(width: cardWidth, height: cardHeight)
//        }
//        .padding(.horizontal)
//    }
//
//    private var swipeableGraphInterface: some View {
//        GeometryReader { geometry in
//            TabView {
//                ForEach(0..<((widgets.count + 1) / 2), id: \.self) { index in
//                    HStack(spacing: -1) {
//                        ForEach(0..<2) { subIndex in
//                            if index * 2 + subIndex < widgets.count {
//                                GraphCardView(widget: widgets[index * 2 + subIndex])
//                                    .frame(width: geometry.size.width / 2)
//                                    .onTapGesture {
//                                        selectedWidget = widgets[index * 2 + subIndex]
//                                    }
//                            }
//                        }
//                    }
//                }
//            }
//            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//        }
//        .frame(height: 120)
//        .padding(.bottom)
//    }
//}
import SwiftUI

import SwiftUI

struct SelfCareNew: View {
    @State private var showingAddWidget = false
    @State private var editingWidget: CustomWidget?
    @State private var isEditMode = false
    @State private var selectedWidget: CustomWidget?
    @State private var showingQuestionsSheet = false
    @State private var showingPPSheet = false

    @EnvironmentObject var viewModel: AuthViewModel

    let cardWidth: CGFloat = 200
    let cardHeight: CGFloat = 250
    let cardSpacing: CGFloat = -70

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                topSection

                CustomButton2(title: "Daily Check In", onClick: {
                    // Handle Daily Check In
                })
                .padding(.top, 60)
                .padding(.bottom, -41)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    widgetsSection
                }
                .padding(.top)
                .padding(.leading, -48)

//                CustomButton3(title: isEditMode ? "Done" : "Edit Widgets", onClick: {
//                    if let widgets = viewModel.currentUser?.selectedWidgets {
//                        if isEditMode {
//                            Task {
//                                try await viewModel.saveWidgets(widgets: widgets)
//                            }
//                        }
//                    }
//                    isEditMode.toggle()
//                })
//                .frame(width: 390)
//                .padding(.top, -30)
                
                swipeableGraphInterface
                
                CustomButton2(title: "Detailed Analytics", onClick: {
                    // Handle Detailed Analytics
                })
                .padding(.top, -14)
                .padding(.bottom, -41)
                Spacer()
                if viewModel.currentUser?.hasCompletedInitialQuiz ?? false {
                    CustomButton2(title: "View Personalized Plan", onClick: {
                        showingPPSheet = true
                    })
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchWidgets()
                    if !(viewModel.currentUser?.hasCompletedInitialQuiz ?? false) {
                        showingQuestionsSheet = true
                    }
                }
            }
            .background(Color.sentMessage.edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddWidget) {
                if let currentUser = viewModel.currentUser {
                    AddWidgetView(widgets: Binding(get: {
                        currentUser.selectedWidgets
                    }, set: { newWidgets in
                        viewModel.currentUser?.selectedWidgets = newWidgets
                        Task {
                            try await viewModel.saveWidgets(widgets: newWidgets)
                        }
                    }))
                }
            }
            .sheet(item: $editingWidget, onDismiss: {
                if let widgets = viewModel.currentUser?.selectedWidgets {
                    Task {
                        try await viewModel.saveWidgets(widgets: widgets)
                    }
                }
            }) { widget in
                if let currentUser = viewModel.currentUser {
                    AddWidgetView(
                        widgets: Binding(get: {
                            currentUser.selectedWidgets
                        }, set: { newWidgets in
                            viewModel.currentUser?.selectedWidgets = newWidgets
                            Task {
                                try await viewModel.saveWidgets(widgets: newWidgets)
                            }
                        }),
                        widgetToEdit: widget
                    )
                }
            }
            .sheet(item: $selectedWidget) { widget in
                WidgetDetailView(widget: widget)
            }
            .sheet(isPresented: $showingQuestionsSheet, onDismiss: {
                Task {
                    try await viewModel.fetchUser()
                }
            }) {
                PPContentView().environmentObject(viewModel)
            }
            .sheet(isPresented: $showingPPSheet) {
                PersonalizedPlanView().environmentObject(viewModel)
            }
        }
    }

    private var topSection: some View {
        ZStack {
            Image("Header")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 100)
                .edgesIgnoringSafeArea(.top)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Welcome, \(viewModel.currentUser?.username ?? "User")!")
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .font(.title)
                    
                    Text("Check out your analytics below.")
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .font(.body)
                }
                .padding()
                
                Spacer()
                
                Image("Sherpa")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .padding()
            }
            .padding(.top, 50)
        }
        .frame(height: 70)
    }

    private var widgetsSection: some View {
        HStack(spacing: cardSpacing) {
            if let widgets = viewModel.currentUser?.selectedWidgets {
                ForEach(widgets.indices, id: \.self) { index in
                    WidgetView2(widget: Binding(get: {
                        viewModel.currentUser!.selectedWidgets[index]
                    }, set: { newValue in
                        viewModel.currentUser!.selectedWidgets[index] = newValue
                        Task {
                            try await viewModel.saveWidgets(widgets: viewModel.currentUser!.selectedWidgets)
                        }
                    }), isEditMode: $isEditMode)
                    .frame(width: cardWidth, height: cardHeight)
                    .onTapGesture {
                        if isEditMode {
                            editingWidget = viewModel.currentUser?.selectedWidgets[index]
                        }
                    }
                }
                AddWidgetButton {
                    showingAddWidget = true
                }
                .frame(width: cardWidth, height: cardHeight)
                .onChange(of: viewModel.currentUser?.selectedWidgets) { newWidgets in
                    if let lastAddedWidget = newWidgets?.last {
                        // Schedule a notification when a new widget (tracker) is added
                        viewModel.scheduleNotificationForNewTracker(widgetName: lastAddedWidget.name)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private var swipeableGraphInterface: some View {
        GeometryReader { geometry in
            if let widgets = viewModel.currentUser?.selectedWidgets {
                TabView {
                    ForEach(0..<((widgets.count + 1) / 2), id: \.self) { index in
                        HStack(spacing: -1) {
                            ForEach(0..<2) { subIndex in
                                if index * 2 + subIndex < widgets.count {
                                    GraphCardView(widget: widgets[index * 2 + subIndex])
                                        .frame(width: geometry.size.width / 2)
                                        .onTapGesture {
                                            selectedWidget = widgets[index * 2 + subIndex]
                                        }
                                }
                            }
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }
        .frame(height: 120)
        .padding(.bottom)
    }
}




import SwiftUI

struct GraphCardView: View {
    var widget: CustomWidget
    let fixedWidth: CGFloat = 165 // Set your desired fixed width here

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(widget.name)
                .font(.headline)
                .padding(.top, 5)
            
            HStack {
                Text("\(widget.percentageChange >= 0 ? "+" : "")\(widget.percentageChange)%")
                    .foregroundColor(widget.percentageChange >= 0 ? .green : .red)
                    .font(.subheadline)
                
                TrendLineView(trend: widget.percentageChange >= 0 ? .up : .down)
                    .frame(width: 30, height: 30)
            }
            .padding(.vertical, 5)
        }
        .padding(.horizontal, 20)
        .frame(width: fixedWidth)
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal, 10)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5) // Added shadow properties
    }
}



enum Trend {
    case up, down, neutral
}

struct TrendLineView: View {
    var trend: Trend

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let startY: CGFloat = trend == .down ? 0 : trend == .up ? height : height / 2
                let endY: CGFloat = trend == .down ? height : trend == .up ? 0 : height / 2

                path.move(to: CGPoint(x: 0, y: startY))
                path.addLine(to: CGPoint(x: width, y: endY))
            }
            .stroke(trend == .down ? Color.red : trend == .up ? Color.green : Color.gray, lineWidth: 2)
        }
    }
}

struct WidgetDetailView: View {
    var widget: CustomWidget

    var body: some View {
        VStack {
            Text(widget.name)
                .font(.largeTitle)
                .padding()

            Text("Details about the widget will be displayed here.")
                .padding()

            Spacer()
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
    }
}

#Preview {
    SelfCareNew()
}
