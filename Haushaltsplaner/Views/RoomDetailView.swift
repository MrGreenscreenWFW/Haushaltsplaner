import SwiftUI

struct RoomDetailView: View {
    let room: Room
    @EnvironmentObject var viewModel: HouseholdViewModel
    @State private var showingAddTask = false
    @State private var isEditingName = false
    @State private var editedName = ""
    
    var body: some View {
        List {
            Section(header: Text("Raum Details")) {
                if isEditingName {
                    TextField("Name", text: $editedName, onCommit: {
                        viewModel.updateRoom(room, newName: editedName)
                        isEditingName = false
                    })
                } else {
                    HStack {
                        Text("Name: \(room.name)")
                        Spacer()
                        Button(action: {
                            editedName = room.name
                            isEditingName = true
                        }) {
                            Image(systemName: "pencil")
                        }
                    }
                }
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
