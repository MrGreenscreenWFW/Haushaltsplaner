import SwiftUI

struct TodayView: View {
    @EnvironmentObject var viewModel: HouseholdViewModel
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.getTodaysTasks().isEmpty {
                    Text("No tasks scheduled for today")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.getTodaysTasks()) { task in
                        TodayTaskRow(task: task)
                    }
                }
            }
            .navigationTitle("Today's Tasks")
        }
    }
}

struct TodayTaskRow: View {
    let task: Task
    @EnvironmentObject var viewModel: HouseholdViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(task.title)
                .font(.headline)
            if let description = task.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            if let room = viewModel.getRoomForTask(task) {
                Text("Room: \(room.name)")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
} 