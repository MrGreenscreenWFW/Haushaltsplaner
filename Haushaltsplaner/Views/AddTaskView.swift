import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var viewModel: HouseholdViewModel
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                }
                
                Section {
                    Button("Save") {
                        let task = Task(
                            title: title,
                            description: description.isEmpty ? nil : description
                        )
                        viewModel.addTask(task)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .navigationTitle("Add Task")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
} 