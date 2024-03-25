
import SwiftUI

final class Router: ObservableObject {
    
    public enum Destination: Codable, Hashable {
        case module2
        case module3
    }
    
    @Published var navPath = NavigationPath()
    
    func navigate(to destination: Destination) {
        navPath.append(destination)
    }
    
    func navigateBack() {
        navPath.removeLast()
    }
    
    func navigateToRoot() {
        navPath.removeLast(navPath.count)
    }
}


