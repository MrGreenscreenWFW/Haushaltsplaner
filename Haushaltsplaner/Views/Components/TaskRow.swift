import SwiftUI

struct TaskRow: View {
    let task: Task
    @State private var showingEditTask = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(task.title)
                        .font(.headline)
                    if let description = task.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Button(action: {
                    showingEditTask = true
                }) {
                    Image(systemName: "pencil")
                }
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingEditTask) {
            EditTaskView(task: task)
        }
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