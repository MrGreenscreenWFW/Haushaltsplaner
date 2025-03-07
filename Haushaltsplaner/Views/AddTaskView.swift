import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var viewModel: HouseholdViewModel
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var selectedRooms: Set<Room> = []
    @State private var selectedDays: [Room: Set<WeekDay>] = [:]
    @State private var selectedIntervals: [Room: TaskInterval] = [:]
    
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
                                        if selectedDays[room] == nil {
                                            selectedDays[room] = []
                                        }
                                        if selectedIntervals[room] == nil {
                                            selectedIntervals[room] = .weekly
                                        }
                                    } else {
                                        selectedRooms.remove(room)
                                        selectedDays.removeValue(forKey: room)
                                        selectedIntervals.removeValue(forKey: room)
                                    }
                                }
                            )) {
                                Text(room.name)
                            }
                            
                            if selectedRooms.contains(room) {
                                Picker("Intervall", selection: Binding(
                                    get: { selectedIntervals[room] ?? .weekly },
                                    set: { selectedIntervals[room] = $0 }
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
                                            if var days = selectedDays[room] {
                                                if days.contains(day) {
                                                    days.remove(day)
                                                } else {
                                                    days.insert(day)
                                                }
                                                selectedDays[room] = days
                                            }
                                        }) {
                                            Text(day.shortLocalizedName)
                                                .padding(4)
                                                .background(
                                                    selectedDays[room]?.contains(day) ?? false
                                                    ? Color.blue
                                                    : Color.gray.opacity(0.2)
                                                )
                                                .foregroundColor(
                                                    selectedDays[room]?.contains(day) ?? false
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
                            if let days = selectedDays[room], !days.isEmpty {
                                viewModel.addTaskAssignment(
                                    task: task,
                                    room: room,
                                    days: Array(days),
                                    interval: selectedIntervals[room] ?? .weekly
                                )
                            }
                        }
                        
                        dismiss()
                    }
                    .disabled(title.isEmpty || selectedRooms.isEmpty || selectedRooms.allSatisfy { selectedDays[$0]?.isEmpty ?? true })
                }
            }
            .navigationTitle("Aufgabe hinzufügen")
            .navigationBarItems(trailing: Button("Abbrechen") {
                dismiss()
            })
        }
    }
} 
