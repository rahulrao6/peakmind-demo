import Firebase
import SwiftUI
import FirebaseFirestore
import Combine


class ToolsViewModel: ObservableObject {
    @Published var selectedTools: [String] = []
    @Published var toolOrder: [String] = []  // Add this to store the order
    @ObservedObject var viewModel : AuthViewModel
    
    
    
    let availableTools: [Tool] = [
        Tool(id: "FlowMode",
             name: "Flow Mode",
             systemIcon: "timer",
             destination: AnyView(OnboardingView(authViewModel: AuthViewModel()))),
        
        Tool(id: "Journal",
             name: "Journal",
             systemIcon: "book.closed.fill",
             destination: AnyView(JournalView())),
        
        Tool(id: "RoutineBuilder",
             name: "Routine Builder",
             systemIcon: "rectangle.grid.1x2",
             destination: AnyView(RoutineBuilderView())),
        
        Tool(id: "Resources",
             name: "Resources",
             systemIcon: "lightbulb.fill",
             destination: AnyView(ResourcesToUtilize()))
    ]
    
    private var db = Firestore.firestore()
    private var userId: String
    
    init(userId: String, viewModel: AuthViewModel) {
        // Add validation to prevent empty userId
        guard !userId.isEmpty else {
            self.userId = "default"
            self.viewModel = viewModel
            print("Warning: Empty userId provided to ToolsViewModel")
            return
        }
        self.userId = userId
        self.viewModel = viewModel
        fetchSelectedTools()
    }
    
    func fetchSelectedTools() {
        guard !userId.isEmpty else { return }
        
        let docRef = db.collection("homeDashboard").document(userId)
        docRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let data = snapshot?.data() {
                DispatchQueue.main.async {
                    self.selectedTools = data["selectedTools"] as? [String] ?? []
                    self.toolOrder = data["toolOrder"] as? [String] ?? self.selectedTools
                }
            } else {
                self.selectedTools = []
                self.toolOrder = []
                self.updateSelectedTools([])
            }
        }
    }
    
    func updateSelectedTools(_ newSelectedTools: [String]) {
        let docRef = db.collection("homeDashboard").document(userId)
        
        // Update toolOrder: remove unselected tools and add new ones
        toolOrder = toolOrder.filter { newSelectedTools.contains($0) }
        newSelectedTools.forEach { tool in
            if !toolOrder.contains(tool) {
                toolOrder.append(tool)
            }
        }
        
        let data: [String: Any] = [
            "selectedTools": newSelectedTools,
            "toolOrder": toolOrder
        ]
        
        docRef.setData(data, merge: true) { error in
            if let error = error {
                print("Error updating tools: \(error.localizedDescription)")
            }
        }
        self.selectedTools = newSelectedTools
    }
    
    func updateToolOrder(_ newOrder: [String]) {
        toolOrder = newOrder
        let docRef = db.collection("homeDashboard").document(userId)
        docRef.updateData(["toolOrder": newOrder]) { error in
            if let error = error {
                print("Error updating tool order: \(error.localizedDescription)")
            }
        }
    }
    
    func getOrderedTools() -> [Tool] {
        let selectedToolsSet = Set(selectedTools)
        let orderedTools = toolOrder.compactMap { toolId in
            availableTools.first { $0.id == toolId }
        }.filter { selectedToolsSet.contains($0.id) }
        
        // Add any selected tools that aren't in the order yet
        let remainingTools = availableTools.filter { tool in
            selectedToolsSet.contains(tool.id) && !toolOrder.contains(tool.id)
        }
        
        return orderedTools + remainingTools
    }
    
    
    
}

struct ToolsSettingsView: View {
    @StateObject private var toolsViewModel: ToolsViewModel
    @State private var tempSelectedTools: [String] = []
    @Environment(\.dismiss) var dismiss
    
    init(userId: String, viewModel: AuthViewModel) {
        _toolsViewModel = StateObject(wrappedValue: ToolsViewModel(userId: userId, viewModel: viewModel))
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(toolsViewModel.availableTools) { tool in
                    HStack {
                        Text(tool.name)
                        Spacer()
                        // A toggle or a checkmark to indicate selected
                        if tempSelectedTools.contains(tool.id) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggleTool(tool.id)
                    }
                }
            }
            .navigationTitle("Select Tools")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    // Update in Firestore
                    toolsViewModel.updateSelectedTools(tempSelectedTools)
                    dismiss()
                }
            )
            .onAppear {
                // Load current selections into temp array
                self.tempSelectedTools = toolsViewModel.selectedTools
            }
        }
    }
    
    private func toggleTool(_ toolId: String) {
        if let index = tempSelectedTools.firstIndex(of: toolId) {
            // Already selected, so remove it
            tempSelectedTools.remove(at: index)
        } else {
            // Add it
            tempSelectedTools.append(toolId)
        }
    }
}


struct SavedToolsView: View {
    @StateObject private var toolsViewModel: ToolsViewModel
    
    init(userId: String, viewModel: AuthViewModel) {
        _toolsViewModel = StateObject(wrappedValue: ToolsViewModel(userId: userId, viewModel: viewModel))
    }
    var body: some View {
        List {
            Section("Your Selected Tools") {
                ForEach(toolsViewModel.availableTools.filter {
                    toolsViewModel.selectedTools.contains($0.id)
                }) { tool in
                    NavigationLink(tool.name, destination: tool.destination)
                }
            }
        }
        .navigationTitle("My Tools")
    }
}
