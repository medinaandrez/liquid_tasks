import Foundation
import SwiftData

@Model
final class FocusSession {
    @Attribute(.unique) var id: UUID
    var duration: TimeInterval // in seconds
    var timestamp: Date
    var isCompleted: Bool
    var spaceTitle: String
    var spaceColorHex: String
    
    init(id: UUID = UUID(), duration: TimeInterval, timestamp: Date = Date(), isCompleted: Bool = true, spaceTitle: String = "General", spaceColorHex: String = "#007AFF") {
        self.id = id
        self.duration = duration
        self.timestamp = timestamp
        self.isCompleted = isCompleted
        self.spaceTitle = spaceTitle
        self.spaceColorHex = spaceColorHex
    }
}
