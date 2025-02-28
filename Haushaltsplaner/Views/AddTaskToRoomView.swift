import SwiftUI

struct AddTaskToRoomView: View {
    @EnvironmentObject var viewModel: HouseholdViewModel
    @Environment(\.dismiss) var dismiss
    let room: Room
    @State private var selectedTask: Task?
    @State private var selectedDays: Set<WeekDay> = []
    
    var body: some View {
        NavigationView {
            Form {
                taskSelectionSection
                daySelectionSection
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
                TaskRow(task: task)
                    .onTapGesture {
                        selectedTask = task
                    }
                    .background(selectedTask?.id == task.id ? Color.blue.opacity(0.2) : Color.clear)
            }
        }
    }
    
    private var daySelectionSection: some View {
        Section(header: Text("Tag auswählen")) {
            ForEach(WeekDay.allCases, id: \.self) { day in
                Toggle(day.rawValue, isOn: Binding(
                    get: { selectedDays.contains(day) },
                    set: { isSelected in
                        if isSelected {
                            selectedDays.insert(day)
                        } else {
                            selectedDays.remove(day)
                        }
                    }
                ))
            }
        }
    }
    
    private var saveSection: some View {
        Section {
            Button("Speichern") {
                if let task = selectedTask {
                    viewModel.addTaskAssignment(task: task, room: room, days: Array(selectedDays))
                    dismiss()
                }
            }
            .disabled(selectedTask == nil || selectedDays.isEmpty)
        }
    }
} 
