import SwiftUI

struct RoomDetailView: View {
    let room: Room
    @EnvironmentObject var viewModel: HouseholdViewModel
    @State private var showingAddTask = false
    
    var body: some View {
        List {
            Section(header: Text("Room Details")) {
                Text("Name: \(room.name)")
                if let description = room.description {
                    Text("Description: \(description)")
                }
            }
            
            Section(header: Text("Assigned Tasks")) {
                if viewModel.getTasksForRoom(room).isEmpty {
                    Text("No tasks assigned")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.getTasksForRoom(room)) { task in
                        TaskRowView(task: task)
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.removeTaskAssignment(task: task, from: room)
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
        .navigationTitle(room.name)
        .toolbar {
            Button(action: { showingAddTask = true }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskToRoomView(room: room)
        }
    }
}

struct TaskRowView: View {
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
    }
} 
