import SwiftUI

struct TodayView: View {
    @EnvironmentObject var viewModel: HouseholdViewModel
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.getTodaysTasks().isEmpty {
                    Text("Für heute sind keine aufgaben geplant")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.getTodaysTasks()) { task in
                        TodayTaskRow(task: task)
                    }
                }
            }
            .navigationTitle("Heutige Aufgaben")
        }
    }
}

struct TodayTaskRow: View {
    let task: Task
    @EnvironmentObject var viewModel: HouseholdViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                if let description = task.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                if let room = viewModel.getRoomForTask(task) {
                    Text("Raum: \(room.name)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            Spacer()
            Button(action: {
                viewModel.toggleTaskCompletion(task)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
        }
        .padding(.vertical, 4)
    }
} 
