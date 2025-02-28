import Foundation

struct Room: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String?
    
    init(id: UUID = UUID(), name: String, description: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
    }
    
    // Implement Hashable conformance
    static func == (lhs: Room, rhs: Room) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
} 
