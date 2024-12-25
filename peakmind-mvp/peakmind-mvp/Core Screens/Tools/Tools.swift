import SwiftUI

struct Tool: Identifiable {
    let id: String         // A unique identifier, e.g., "FlowMode"
    let name: String       // E.g., "Flow Mode"
    let systemIcon: String // For SF Symbols, e.g., "clock"
    
    // Destination view to navigate to when user taps this tool
    // We'll use an `AnyView` to keep it simple in this example.
    // In production, you might use generics or a more advanced approach.
    let destination: AnyView
}
