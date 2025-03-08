import Foundation

struct Task: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var description: String?
    var isCompleted: Bool
    var lastCompletedDate: Date?
    
    init(id: UUID = UUID(), title: String, description: String? = nil, isCompleted: Bool = false, lastCompletedDate: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.lastCompletedDate = lastCompletedDate
    }
} 