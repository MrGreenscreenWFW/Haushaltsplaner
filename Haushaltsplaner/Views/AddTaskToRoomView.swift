import SwiftUI

struct AddTaskToRoomView: View {
    @EnvironmentObject var viewModel: HouseholdViewModel
    @Environment(\.dismiss) var dismiss
    let room: Room
    @State private var selectedTask: Task?
    @State private var selectedInterval: TaskInterval = .weekly
    
    var body: some View {
        NavigationView {
            Form {
                taskSelectionSection
                intervalSelectionSection
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
                    if let assignment = viewModel.taskAssignments.first(where: { $0.taskId == task.id }) {
                        selectedInterval = assignment.interval
                    }
                }
                .background(selectedTask?.id == task.id ? Color.blue.opacity(0.2) : Color.clear)
            }
        }
    }
    
    private var intervalSelectionSection: some View {
        Section(header: Text("Intervall")) {
            Picker("Intervall", selection: $selectedInterval) {
                ForEach(TaskInterval.allCases, id: \.self) { interval in
                    Text(interval.description).tag(interval)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
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
                        interval: selectedInterval
                    )
                    dismiss()
                }
            }
            .disabled(selectedTask == nil)
        }
    }
} 
