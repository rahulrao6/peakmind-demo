//
//  Preferences.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 12/23/24.
//

import Foundation
struct DashboardPreferences: Codable {
    var selectedInsights: [String]
    var selectedTools: [String]
    var sectionsOrder: [String]
    var theme: String
    var layout: String
    
    // Provide a default initializer for convenience
    init(
        selectedInsights: [String] = ["steps", "activeEnergy"],
        selectedTools: [String] = ["flowMode", "journal"],
        sectionsOrder: [String] = ["recommendedAction", "insights", "tools"],
        theme: String = "DefaultTheme",
        layout: String = "card"
    ) {
        self.selectedInsights = selectedInsights
        self.selectedTools = selectedTools
        self.sectionsOrder = sectionsOrder
        self.theme = theme
        self.layout = layout
    }
}


import Firebase
import FirebaseFirestore
import Combine

class DashboardPreferencesViewModel: ObservableObject {
    @Published var preferences: DashboardPreferences = DashboardPreferences()
    private var db = Firestore.firestore()
    
    func fetchPreferences(for userId: String) {
        let docRef = db.collection("homeDashboard").document(userId)
        docRef.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching dashboard prefs: \(error)")
                return
            }
            guard let data = snapshot?.data() else {
                print("No dashboard prefs found; using defaults.")
                return
            }
            do {
                // Convert to DashboardPreferences using Swift’s decoding
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let prefs = try JSONDecoder().decode(DashboardPreferences.self, from: jsonData)
                DispatchQueue.main.async {
                    self.preferences = prefs
                }
            } catch {
                print("Error decoding dashboard prefs: \(error)")
            }
        }
    }
    
    func savePreferences(for userId: String) {
        let docRef = db.collection("homeDashboard").document(userId)
        do {
            // Convert DashboardPreferences -> [String: Any]
            let jsonData = try JSONEncoder().encode(preferences)
            let dict = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any] ?? [:]
            
            // Merge = true so we don’t overwrite existing data
            docRef.setData(dict, merge: true) { error in
                if let error = error {
                    print("Error saving dashboard prefs: \(error)")
                } else {
                    print("Dashboard prefs saved successfully!")
                }
            }
        } catch {
            print("Error encoding dashboard prefs: \(error)")
        }
    }
}


import SwiftUI

struct DashboardCustomizationView: View {
    @ObservedObject var prefsViewModel: DashboardPreferencesViewModel
    let userId: String
    @Environment(\.presentationMode) var presentationMode
    
    // For demonstration, define possible layout modes or themes
    let availableLayouts = ["list", "grid", "card"]
    let availableThemes = ["DefaultTheme", "DarkTheme", "OceanTheme"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Insights")) {
                    // Example toggle for each possible insight
                    Toggle("Steps", isOn: Binding(
                        get: { prefsViewModel.preferences.selectedInsights.contains("steps") },
                        set: { newValue in
                            updateSelectedInsights("steps", isSelected: newValue)
                        }
                    ))
                    Toggle("Active Energy", isOn: Binding(
                        get: { prefsViewModel.preferences.selectedInsights.contains("activeEnergy") },
                        set: { newValue in
                            updateSelectedInsights("activeEnergy", isSelected: newValue)
                        }
                    ))
                }
                
                Section(header: Text("Tools")) {
                    Toggle("Flow Mode", isOn: Binding(
                        get: { prefsViewModel.preferences.selectedTools.contains("flowMode") },
                        set: { newValue in
                            updateSelectedTools("flowMode", isSelected: newValue)
                        }
                    ))
                    Toggle("Journal", isOn: Binding(
                        get: { prefsViewModel.preferences.selectedTools.contains("journal") },
                        set: { newValue in
                            updateSelectedTools("journal", isSelected: newValue)
                        }
                    ))
                }
                
                Section(header: Text("Sections Order")) {
                    // We'll store them as strings: ["recommendedAction", "insights", "tools"].
                    // For reordering in SwiftUI, we can do a List with .onMove.
                    ReorderableSection(strings: $prefsViewModel.preferences.sectionsOrder)
                }
                
                Section(header: Text("Layout")) {
                    Picker("Layout Style", selection: $prefsViewModel.preferences.layout) {
                        ForEach(availableLayouts, id: \.self) { layout in
                            Text(layout.capitalized).tag(layout)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Theme")) {
                    Picker("Theme", selection: $prefsViewModel.preferences.theme) {
                        ForEach(availableThemes, id: \.self) { theme in
                            Text(theme).tag(theme)
                        }
                    }
                }
            }
            .navigationTitle("Customize Dashboard")
            .navigationBarItems(trailing: Button("Save") {
                prefsViewModel.savePreferences(for: userId)
                presentationMode.wrappedValue.dismiss()
            })
        }
        .onAppear {
            prefsViewModel.fetchPreferences(for: userId)
        }
    }
    
    // MARK: - Helper Functions for Toggles
    
    private func updateSelectedInsights(_ insight: String, isSelected: Bool) {
        var current = prefsViewModel.preferences.selectedInsights
        if isSelected {
            if !current.contains(insight) {
                current.append(insight)
            }
        } else {
            current.removeAll(where: { $0 == insight })
        }
        prefsViewModel.preferences.selectedInsights = current
    }
    
    private func updateSelectedTools(_ tool: String, isSelected: Bool) {
        var current = prefsViewModel.preferences.selectedTools
        if isSelected {
            if !current.contains(tool) {
                current.append(tool)
            }
        } else {
            current.removeAll(where: { $0 == tool })
        }
        prefsViewModel.preferences.selectedTools = current
    }
}

struct ReorderableSection: View {
    @Binding var strings: [String]
    
    var body: some View {
        // iOS 15+ approach with .editButton
        List {
            ForEach(strings, id: \.self) { item in
                Text(displayName(for: item))
            }
            .onMove(perform: move)
        }
        // We might hide the edit button or manage it differently
        .environment(\.editMode, .constant(.active)) // always in edit mode
        .frame(height: 200)
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        strings.move(fromOffsets: source, toOffset: destination)
    }
    
    // Convert internal section key -> user-friendly label
    private func displayName(for section: String) -> String {
        switch section {
        case "recommendedAction": return "Recommended Action"
        case "insights": return "Insights"
        case "tools": return "Tools"
        default: return section.capitalized
        }
    }
}


