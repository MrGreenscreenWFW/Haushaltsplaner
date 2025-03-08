import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var viewModel: HouseholdViewModel
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var selectedRooms: Set<Room> = []
    @State private var selectedDays: [UUID: Set<WeekDay>] = [:]
    @State private var selectedIntervals: [UUID: TaskInterval] = [:]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Aufgaben Details")) {
                    TextField("Name", text: $title)
                    TextField("Beschreibung", text: $description)
                }
                
                Section(header: Text("Räume und Tage")) {
                    ForEach(viewModel.rooms) { room in
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle(isOn: Binding(
                                get: { selectedRooms.contains(room) },
                                set: { isSelected in
                                    if isSelected {
                                        selectedRooms.insert(room)
                                        selectedDays[room.id] = Set<WeekDay>()
                                        selectedIntervals[room.id] = .weekly
                                    } else {
                                        selectedRooms.remove(room)
                                        selectedDays.removeValue(forKey: room.id)
                                        selectedIntervals.removeValue(forKey: room.id)
                                    }
                                }
                            )) {
                                Text(room.name)
                            }
                            
                            if selectedRooms.contains(room) {
                                Picker("Intervall", selection: Binding(
                                    get: { selectedIntervals[room.id] ?? .weekly },
                                    set: { selectedIntervals[room.id] = $0 }
                                )) {
                                    ForEach(TaskInterval.allCases, id: \.self) { interval in
                                        Text(interval.description).tag(interval)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding(.vertical, 4)
                                
                                HStack {
                                    ForEach(WeekDay.allCases, id: \.self) { day in
                                        Button(action: {
                                            toggleDay(day, for: room)
                                        }) {
                                            Text(day.shortLocalizedName)
                                                .padding(4)
                                                .background(
                                                    (selectedDays[room.id]?.contains(day) ?? false)
                                                    ? Color.blue
                                                    : Color.gray.opacity(0.2)
                                                )
                                                .foregroundColor(
                                                    (selectedDays[room.id]?.contains(day) ?? false)
                                                    ? .white
                                                    : .primary
                                                )
                                                .cornerRadius(4)
                                        }
                                    }
                                }
                                .padding(.leading)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Speichern") {
                        let task = Task(
                            title: title,
                            description: description.isEmpty ? nil : description
                        )
                        viewModel.addTask(task)
                        
                        // Füge die Aufgabe zu den ausgewählten Räumen hinzu
                        for room in selectedRooms {
                            if let days = selectedDays[room.id], !days.isEmpty {
                                viewModel.addTaskAssignment(
                                    task: task,
                                    room: room,
                                    days: Array(days),
                                    interval: selectedIntervals[room.id] ?? .weekly
                                )
                            }
                        }
                        
                        dismiss()
                    }
                    .disabled(title.isEmpty || selectedRooms.isEmpty || selectedRooms.allSatisfy { selectedDays[$0.id]?.isEmpty ?? true })
                }
            }
            .navigationTitle("Aufgabe hinzufügen")
            .navigationBarItems(trailing: Button("Abbrechen") {
                dismiss()
            })
        }
    }
    
    private func toggleDay(_ day: WeekDay, for room: Room) {
        var currentDays = selectedDays[room.id] ?? Set<WeekDay>()
        if currentDays.contains(day) {
            currentDays.remove(day)
        } else {
            currentDays.insert(day)
        }
        selectedDays[room.id] = currentDays
    }
}
