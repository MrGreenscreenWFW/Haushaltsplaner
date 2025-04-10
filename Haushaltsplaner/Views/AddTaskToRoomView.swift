import SwiftUI

struct AddTaskToRoomView: View {
    @EnvironmentObject var viewModel: HouseholdViewModel
    @Environment(\.dismiss) var dismiss
    let room: Room
    @State private var selectedTask: Task?
    
    var body: some View {
        NavigationView {
            Form {
                taskSelectionSection
                saveSection
            }
            .navigationTitle("Aufgabe zu Raum hinzufügen")
            .navigationBarItems(trailing: Button("Abbrechen") {
                dismiss()
            })
        }
    }
    
    private var taskSelectionSection: some View {
        Section(header: Text("Aufgabe auswählen")) {
            ForEach(viewModel.tasks) { task in
                VStack(alignment: .leading) {
                    TaskRow(task: task)
                    if let assignment = viewModel.taskAssignments.first(where: { $0.taskId == task.id }) {
                        Text("Tage: \(assignment.scheduledDays.map { $0.shortLocalizedName }.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onTapGesture {
                    selectedTask = task
                }
                .background(selectedTask?.id == task.id ? Color.blue.opacity(0.2) : Color.clear)
            }
        }
    }
    
    private var saveSection: some View {
        Section {
            Button("Speichern") {
                if let task = selectedTask,
                   let assignment = viewModel.taskAssignments.first(where: { $0.taskId == task.id }) {
                    viewModel.addTaskAssignment(
                        task: task,
                        room: room,
                        days: Array(assignment.scheduledDays),
                        interval: assignment.interval
                    )
                    dismiss()
                }
            }
            .disabled(selectedTask == nil)
        }
    }
} 
