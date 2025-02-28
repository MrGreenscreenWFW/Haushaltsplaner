import SwiftUI

struct EditTaskView: View {
    @EnvironmentObject var viewModel: HouseholdViewModel
    @Environment(\.dismiss) var dismiss
    let task: Task
    
    @State private var title: String
    @State private var description: String
    
    init(task: Task) {
        self.task = task
        _title = State(initialValue: task.title)
        _description = State(initialValue: task.description ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Aufgaben Details")) {
                    TextField("Name", text: $title)
                    TextField("Beschreibung", text: $description)
                }
                
                Section {
                    Button("Speichern") {
                        let updatedTask = Task(
                            id: task.id,
                            title: title,
                            description: description.isEmpty ? nil : description,
                            assignments: task.assignments,
                            isCompleted: task.isCompleted,
                            lastCompletedDate: task.lastCompletedDate
                        )
                        viewModel.updateTask(updatedTask)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .navigationTitle("Aufgabe bearbeiten")
            .navigationBarItems(trailing: Button("Abbrechen") {
                dismiss()
            })
        }
    }
} 