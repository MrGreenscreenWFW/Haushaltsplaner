import SwiftUI

struct TaskRow: View {
    let task: Task
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(task.title)
                .font(.headline)
            if let description = task.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// Erweiterung für kürzere Tagesbezeichnungen
extension WeekDay {
    var shortLocalizedName: String {
        switch self {
        case .monday: return "Mo"
        case .tuesday: return "Di"
        case .wednesday: return "Mi"
        case .thursday: return "Do"
        case .friday: return "Fr"
        case .saturday: return "Sa"
        case .sunday: return "So"
        }
    }
} 