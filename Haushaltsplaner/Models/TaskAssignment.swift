import Foundation

struct TaskAssignment: Identifiable, Codable, Hashable {
    let id: UUID
    let taskId: UUID
    let roomId: UUID
    let scheduledDays: Set<WeekDay>
    
    init(id: UUID = UUID(), taskId: UUID, roomId: UUID, scheduledDays: Set<WeekDay>) {
        self.id = id
        self.taskId = taskId
        self.roomId = roomId
        self.scheduledDays = scheduledDays
    }
}

enum WeekDay: String, Codable, CaseIterable {
    case monday = "Montag"
    case tuesday = "Dienstag"
    case wednesday = "Mittwoch"
    case thursday = "Donnerstag"
    case friday = "Freitag"
    case saturday = "Samstag"
    case sunday = "Sonntag"
} 