import Foundation
import SwiftData

@Model
final class Space {
    @Attribute(.unique) var id: UUID
    var title: String
    var creationDate: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Project.space) var projects: [Project]?
    @Relationship(deleteRule: .cascade, inverse: \Task.space) var tasks: [Task]? // Tareas sueltas dentro de un espacio
    
    init(id: UUID = UUID(), title: String, creationDate: Date = Date()) {
        self.id = id
        self.title = title
        self.creationDate = creationDate
    }
}
