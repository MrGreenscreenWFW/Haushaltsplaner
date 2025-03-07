import Foundation

enum TaskInterval: Int, Codable, CaseIterable {
    case weekly = 1
    case biweekly = 2
    case triweekly = 3
    case fourWeekly = 4
    
    var description: String {
        switch self {
        case .weekly:
            return "Wöchentlich"
        case .biweekly:
            return "2-Wöchentlich"
        case .triweekly:
            return "3-Wöchentlich"
        case .fourWeekly:
            return "4-Wöchentlich"
        }
    }
} 