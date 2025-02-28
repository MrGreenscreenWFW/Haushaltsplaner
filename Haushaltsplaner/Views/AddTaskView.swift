import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var viewModel: HouseholdViewModel
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Aufgaben Details")) {
                    TextField("Name", text: $title)
                    TextField("Beschreibung", text: $description)
                }
                
                Section {
                    Button("Speichern") {
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
            .navigationTitle("Aufgabe hinzufügen")
            .navigationBarItems(trailing: Button("Abbrechen") {
                dismiss()
            })
        }
    }
} 
