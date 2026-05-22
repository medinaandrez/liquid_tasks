import Foundation
import SwiftData

@Model
final class Subtask: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var isCompleted: Bool
    var sortOrder: Int
    
    // Relación hacia la tarea (padre)
    var task: Task?
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, sortOrder: Int = 0) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.sortOrder = sortOrder
    }
}
