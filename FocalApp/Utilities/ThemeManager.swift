import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case classic = "classic"
    case forest = "forest"
    case sunset = "sunset"
    case frost = "frost"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .classic: return "Classic"
        case .forest: return "Forest"
        case .sunset: return "Sunset"
        case .frost: return "Frost"
        }
    }
    
    // Gradiente para Sidebar (Suave)
    var sidebarGradient: LinearGradient {
        switch self {
        case .classic:
            return LinearGradient(
                colors: [Color.blue.opacity(0.18), Color.purple.opacity(0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .forest:
            return LinearGradient(
                colors: [Color.teal.opacity(0.18), Color.green.opacity(0.22)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .sunset:
            return LinearGradient(
                colors: [Color.orange.opacity(0.18), Color.pink.opacity(0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .frost:
            return LinearGradient(
                colors: [Color.gray.opacity(0.15), Color.blue.opacity(0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // Gradiente para Vista de Detalle (Vibrante)
    var detailGradient: LinearGradient {
        switch self {
        case .classic:
            return LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .forest:
            return LinearGradient(
                colors: [Color.teal.opacity(0.3), Color.green.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .sunset:
            return LinearGradient(
                colors: [Color.orange.opacity(0.3), Color.pink.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .frost:
            return LinearGradient(
                colors: [Color.gray.opacity(0.25), Color.blue.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // Colores de previsualización circular
    var previewColors: [Color] {
        switch self {
        case .classic: return [.blue, .purple]
        case .forest: return [.teal, .green]
        case .sunset: return [.orange, .pink]
        case .frost: return [.gray, .blue]
        }
    }
}
