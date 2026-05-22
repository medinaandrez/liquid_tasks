import Foundation
import SwiftData

@Model
final class Task {
    @Attribute(.unique) var id: UUID
    var title: String
    var notes: String
    var isCompleted: Bool
    
    // Flexibilidad de fechas
    var startDate: Date? // Permite la dinámica de "Things 3" (programar cuándo empezar)
    var dueDate: Date?   // Permite la dinámica de "Todoist" (fecha de vencimiento estricta)
    var creationDate: Date
    var sortOrder: Int = 0 // Soporte para reordenamiento, con valor por defecto para migración
    
    // Relaciones (inferidas a través de los inversos en los padres/entidades relacionadas)
    var project: Project?
    var area: Area?
    var tags: [Tag]?
    
    // Relación de uno a muchos (hijos)
    @Relationship(deleteRule: .cascade, inverse: \Subtask.task) var subtasks: [Subtask]?
    
    init(id: UUID = UUID(), title: String, notes: String = "", isCompleted: Bool = false, startDate: Date? = nil, dueDate: Date? = nil, creationDate: Date = Date(), sortOrder: Int = 0) {
        self.id = id
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.startDate = startDate
        self.dueDate = dueDate
        self.creationDate = creationDate
        self.sortOrder = sortOrder
    }
}
