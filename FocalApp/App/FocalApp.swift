import SwiftUI
import SwiftData

@main
struct FocalApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Task.self, Subtask.self, Project.self, Area.self, Tag.self
        ])
        
        // Estrictamente almacenamiento local
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("No se pudo inicializar SwiftData: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
