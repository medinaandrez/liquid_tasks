import Foundation
import SwiftData

@Model
final class Project {
    @Attribute(.unique) var id: UUID
    var title: String
    var notes: String
    var isCompleted: Bool
    var creationDate: Date
    
    // Relación hacia el área (padre)
    var area: Area?
    
    // Relación de uno a muchos (hijos)
    @Relationship(deleteRule: .cascade, inverse: \Task.project) var tasks: [Task]?
    
    init(id: UUID = UUID(), title: String, notes: String = "", isCompleted: Bool = false, creationDate: Date = Date()) {
        self.id = id
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.creationDate = creationDate
    }
}
