import SwiftUI

struct RoomDetailView: View {
    let room: Room
    @EnvironmentObject var viewModel: HouseholdViewModel
    @State private var showingAddTask = false
    
    var body: some View {
        List {
            Section(header: Text("Raum Details")) {
                Text("Name: \(room.name)")
                if let description = room.description {
                    Text("Beschreibung: \(description)")
                }
            }
            
            Section(header: Text("Zugeordnete Aufgaben")) {
                if viewModel.getTasksForRoom(room).isEmpty {
                    Text("Keine Aufgaben zugewiesen")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.getTasksForRoom(room)) { task in
                        TaskRowView(task: task)
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.removeTaskAssignment(task: task, from: room)
                                } label: {
                                    Label("Löschen", systemImage: "trash")
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
