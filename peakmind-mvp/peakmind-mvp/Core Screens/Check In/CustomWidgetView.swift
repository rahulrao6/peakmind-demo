import SwiftUI

struct CustomWidgetView: View {
//    @State private var widgets: [CustomWidget] = [
//        CustomWidget(from: <#any Decoder#>, name: "Steps", frequency: .daily, unit: .count, specificUnit: "steps", value: 1000, description: "Daily steps count"),
//        CustomWidget(name: "Water", frequency: .multipleTimesDaily, unit: .volume, specificUnit: "liters", value: 2, description: "Daily water intake"),
//        CustomWidget(name: "Reading", frequency: .daily, unit: .time, specificUnit: "minutes", value: 30, description: "Daily reading time")
//    ]
    @State private var showingAddWidget = false
    @State private var editingWidget: CustomWidget? = nil
    @State private var isEditMode = false
    @State private var widgets: [CustomWidget]

    let cardWidth: CGFloat = 200
    let cardHeight: CGFloat = 250
    let cardSpacing: CGFloat = -70

    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: cardSpacing) {
                        ForEach(widgets.indices, id: \.self) { index in
                            WidgetView2(widget: $widgets[index], isEditMode: $isEditMode)
                                .frame(width: cardWidth, height: cardHeight)
                                .onTapGesture {
                                    if isEditMode {
                                        editingWidget = widgets[index]
                                    }
                                }
                        }
                        AddWidgetButton {
                            showingAddWidget = true
                        }
                        .frame(width: cardWidth, height: cardHeight) // Ensure the same size as other cards
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
                Spacer()
            }
            .background(Color.sentMessage.edgesIgnoringSafeArea(.all)) // Set background color
            .navigationTitle("Your Widgets")
            .navigationBarTitleDisplayMode(.inline) // Make sure the title is in-line
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Your Widgets")
                        .foregroundColor(.white) // Set the color to white
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditMode ? "Done" : "Edit Widgets") {
                        isEditMode.toggle()
                    }
                }
            }
            .onAppear {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(Color.sentMessage) // Use the custom background color
                appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
            .sheet(isPresented: $showingAddWidget) {
                AddWidgetView(widgets: $widgets)
            }
            .sheet(item: $editingWidget) { widget in
                AddWidgetView(widgets: $widgets, widgetToEdit: widget)
            }
        }
    }
}

struct CustomWidget: Identifiable, Equatable, Decodable, Encodable {
    var id = UUID()
    var name: String
    var frequency: TrackingFrequency
    var unit: MeasurementUnit
    var specificUnit: String
    var value: Int = 0
    var description: String = ""
    var percentageChange: Int = 0
    // Coding keys to map JSON keys to your properties
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case frequency
        case value
        case unit
        case specificUnit
        case description
        case percentageChange
    }

    init(id: UUID = UUID(), name: String, frequency: TrackingFrequency, value: Int, unit: MeasurementUnit, specificUnit: String, description: String, percentageChange: Int) {
        self.id = id
        self.name = name
        self.frequency = frequency
        self.unit = unit
        self.specificUnit = specificUnit
        self.value = value
        self.description = description
        self.percentageChange = percentageChange
    }
    
    // Initialize from a decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        frequency = try container.decode(TrackingFrequency.self, forKey: .frequency)
        unit = try container.decode(MeasurementUnit.self, forKey: .unit)
        specificUnit = try container.decode(String.self, forKey: .specificUnit)
        value = try container.decode(Int.self, forKey: .value)
        description = try container.decode(String.self, forKey: .description)
        percentageChange = try container.decode(Int.self, forKey: .percentageChange)
    }

    // Encode to an encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(frequency.rawValue, forKey: .frequency)
        try container.encode(unit.rawValue, forKey: .unit)
        try container.encode(specificUnit, forKey: .specificUnit)
        try container.encode(value, forKey: .value)
        try container.encode(description, forKey: .description)
        try container.encode(percentageChange, forKey: .percentageChange)
    }

}

enum TrackingFrequency: String, CaseIterable, Decodable {
    case daily = "Daily"
    case multipleTimesDaily = "Multiple times a day"
}

enum MeasurementUnit: String, CaseIterable, Decodable {
    case length = "Length"
    case weight = "Weight"
    case time = "Time"
    case volume = "Volume"
    case count = "Count"

    var specificUnits: [String] {
        switch self {
        case .length: return ["meters", "feet", "inches"]
        case .weight: return ["kg", "lbs"]
        case .time: return ["seconds", "minutes", "hours"]
        case .volume: return ["liters", "milliliters", "gallons"]
        case .count: return ["items", "steps"]
        }
    }
}
//
//struct WidgetView2: View {
//    @Binding var widget: CustomWidget
//    @Binding var isEditMode: Bool
//
//    var body: some View {
//        VStack(spacing: 5) {
//            Text(widget.name)
//                .font(.headline)
//                .foregroundColor(isEditMode ? .blue : .primary)
//                .lineLimit(1)
//                .truncationMode(.tail)
//            Text("\(widget.value)")
//                .font(.title2)
//                .foregroundColor(.white)
//            Text(widget.specificUnit)
//                .font(.subheadline)
//                .foregroundColor(.white)
//                .padding(.top, -5)
//            
//            HStack(spacing: 15) {
//                Button(action: {
//                    widget.value += 1
//                }) {
//                    Image(systemName: "plus.circle.fill")
//                        .font(.title)
//                        .foregroundColor(.iceBlue)
//                }
//                Button(action: {
//                    if widget.value > 0 {
//                        widget.value -= 1
//                    }
//                }) {
//                    Image(systemName: "minus.circle.fill")
//                        .font(.title)
//                        .foregroundColor(.iceBlue)
//                }
//            }
//            .padding(.top, 10)
//        }
//        .frame(height: 130)
//        .frame(width: 80)
//        .padding()
//        .background(isEditMode ? Color.blue.opacity(0.2) : Color.mediumBlue.opacity(0.7))
//        .cornerRadius(10)
//        .overlay(
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(isEditMode ? Color.blue : Color.clear, lineWidth: 2)
//        )
//        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5) // Added shadow properties
//    }
//}

import SwiftUI

struct WidgetView2: View {
    @Binding var widget: CustomWidget
    @Binding var isEditMode: Bool
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 5) {
            Text(widget.name)
                .font(.headline)
                .foregroundColor(isEditMode ? .blue : .primary)
                .lineLimit(1)
                .truncationMode(.tail)
            Text("\(widget.value)")
                .font(.title2)
                .foregroundColor(.white)
            Text(widget.specificUnit)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.top, -5)
            
            HStack(spacing: 15) {
                Button(action: {
                    incrementValue()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.iceBlue)
                }
                Button(action: {
                    decrementValue()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundColor(.iceBlue)
                }
            }
            .padding(.top, 10)
        }
        .frame(height: 130)
        .frame(width: 80)
        .padding()
        .background(isEditMode ? Color.blue.opacity(0.2) : Color.mediumBlue.opacity(0.7))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isEditMode ? Color.blue : Color.clear, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
    }

    private func incrementValue() {
        widget.value += 1
        saveChanges()
    }

    private func decrementValue() {
        if widget.value > 0 {
            widget.value -= 1
            saveChanges()
        }
    }

    private func saveChanges() {
        Task {
            do {
                try await viewModel.saveDailyWidgetData(widget: widget)
                viewModel.saveDailyWidgetDataLocally(widget: widget)
            } catch {
                print("Failed to save daily widget data: \(error.localizedDescription)")
            }
        }
    }
}




struct AddWidgetButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Spacer() // This ensures the text and image are centered vertically
                Image(systemName: "plus.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.black) // Set plus icon to black
                Text("Add Widget")
                    .font(.headline)
                Spacer() // This ensures the text and image are centered vertically
            }
            .frame(height: 130) // Fixed height for content within the card
            .frame(width: 80) // Fixed height for content within the card
            .padding()
            .background(Color.iceBlue.opacity(1.0)) // Use the custom "Ice Blue" color
            .cornerRadius(10)
            .frame(width: 200, height: 250) // Ensure the same height as other cards
        }
    }
}

//struct AddWidgetView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @Binding var widgets: [CustomWidget]
//    var widgetToEdit: CustomWidget? = nil
//
//    @State private var name = ""
//    @State private var frequency: TrackingFrequency = .daily
//    @State private var unit: MeasurementUnit = .length
//    @State private var specificUnit = ""
//    @State private var description = ""
//    @State private var showError = false
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Widget Name")) {
//                    TextField("Name", text: $name)
//                        .onChange(of: name) { newValue in
//                            if newValue.count > 10 {
//                                name = String(newValue.prefix(10))
//                            }
//                        }
//                        .foregroundColor(name.count > 10 ? .red : .primary)
//                }
//                Section(header: Text("Frequency")) {
//                    Picker("Frequency", selection: $frequency) {
//                        ForEach(TrackingFrequency.allCases, id: \.self) {
//                            Text($0.rawValue)
//                        }
//                    }
//                    .pickerStyle(SegmentedPickerStyle())
//                }
//                Section(header: Text("Unit")) {
//                    Picker("Unit", selection: $unit) {
//                        ForEach(MeasurementUnit.allCases, id: \.self) {
//                            Text($0.rawValue)
//                        }
//                    }
//                    .pickerStyle(SegmentedPickerStyle())
//                    
//                    if !unit.specificUnits.isEmpty {
//                        Picker("Specific Unit", selection: $specificUnit) {
//                            ForEach(unit.specificUnits, id: \.self) {
//                                Text($0)
//                            }
//                        }
//                        .pickerStyle(SegmentedPickerStyle())
//                    }
//                }
//                Section(header: Text("Description")) {
//                    TextField("Description", text: $description)
//                }
//            }
//            .navigationTitle(widgetToEdit == nil ? "New Widget" : "Edit Widget")
//            .navigationBarItems(trailing: Button("Save") {
//                if name.isEmpty || specificUnit.isEmpty {
//                    showError = true
//                } else {
//                    if let widgetToEdit = widgetToEdit, let index = widgets.firstIndex(where: { $0.id == widgetToEdit.id }) {
//                        widgets[index].name = name
//                        widgets[index].frequency = frequency
//                        widgets[index].unit = unit
//                        widgets[index].specificUnit = specificUnit
//                        widgets[index].description = description
//                    } else {
//                        let newWidget = CustomWidget(name: name, frequency: frequency, unit: unit, specificUnit: specificUnit, description: description)
//                        widgets.append(newWidget)
//                    }
//                    presentationMode.wrappedValue.dismiss()
//                }
//            })
//            .alert(isPresented: $showError) {
//                Alert(title: Text("Error"), message: Text("Please fill in all required fields."), dismissButton: .default(Text("OK")))
//            }
//            .onAppear {
//                if let widgetToEdit = widgetToEdit {
//                    name = widgetToEdit.name
//                    frequency = widgetToEdit.frequency
//                    unit = widgetToEdit.unit
//                    specificUnit = widgetToEdit.specificUnit
//                    description = widgetToEdit.description
//                }
//            }
//        }
//    }
//}
import SwiftUI

struct AddWidgetView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var widgets: [CustomWidget]
    var widgetToEdit: CustomWidget? = nil

    @State private var name = ""
    @State private var frequency: TrackingFrequency = .daily
    @State private var unit: MeasurementUnit = .length
    @State private var specificUnit = ""
    @State private var description = ""
    @State private var showError = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Widget Name")) {
                    TextField("Name", text: $name)
                        .onChange(of: name) { newValue in
                            if newValue.count > 10 {
                                name = String(newValue.prefix(10))
                            }
                        }
                        .foregroundColor(name.count > 10 ? .red : .primary)
                }
                Section(header: Text("Frequency")) {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(TrackingFrequency.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Unit")) {
                    Picker("Unit", selection: $unit) {
                        ForEach(MeasurementUnit.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if !unit.specificUnits.isEmpty {
                        Picker("Specific Unit", selection: $specificUnit) {
                            ForEach(unit.specificUnits, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                Section(header: Text("Description")) {
                    TextField("Description", text: $description)
                }
            }
            .navigationTitle(widgetToEdit == nil ? "New Widget" : "Edit Widget")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if name.isEmpty || specificUnit.isEmpty {
                            showError = true
                        } else {
                            if let widgetToEdit = widgetToEdit, let index = widgets.firstIndex(where: { $0.id == widgetToEdit.id }) {
                                widgets[index].name = name
                                widgets[index].frequency = frequency
                                widgets[index].unit = unit
                                widgets[index].specificUnit = specificUnit
                                widgets[index].description = description
                            } else {
                                let newWidget = CustomWidget(id: UUID(), name: name, frequency: frequency, value: 0, unit: unit, specificUnit: specificUnit, description: description, percentageChange: 0)
                                widgets.append(newWidget)
                            }
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Save")
                    }
                }
            }
            .alert(isPresented: $showError) {
                Alert(title: Text("Error"), message: Text("Please fill in all required fields."), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                if let widgetToEdit = widgetToEdit {
                    name = widgetToEdit.name
                    frequency = widgetToEdit.frequency
                    unit = widgetToEdit.unit
                    specificUnit = widgetToEdit.specificUnit
                    description = widgetToEdit.description
                }
            }
        }
    }
}

struct AddWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        AddWidgetView(widgets: .constant([]))
    }
}



struct StepWidget1: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var healthKitManager: HealthKitManager

    var body: some View {
        VStack(spacing: 5) {
            Text("Steps")
                .font(.headline)
                .foregroundColor(.blue)
                .lineLimit(1)
                .truncationMode(.tail)
            Text("\(Int(healthKitManager.liveStepCount)) steps")
                .font(.title2)
                .foregroundColor(.white)

            .padding(.top, 10)
        }
        .frame(height: 130)
        .frame(width: 80)
        .padding()
        .background(Color.blue.opacity(0.2))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
    }


}



//#Preview {
//    CustomWidgetView()
//}
