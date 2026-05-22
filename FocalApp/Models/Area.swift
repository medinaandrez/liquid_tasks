import Foundation
import SwiftData

@Model
final class Area {
    @Attribute(.unique) var id: UUID
    var title: String
    var creationDate: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Project.area) var projects: [Project]?
    @Relationship(deleteRule: .cascade, inverse: \Task.area) var tasks: [Task]? // Tareas sueltas dentro de un área
    
    init(id: UUID = UUID(), title: String, creationDate: Date = Date()) {
        self.id = id
        self.title = title
        self.creationDate = creationDate
    }
}
