import SwiftUI

struct DaySelectionGrid: View {
    let room: Room
    @Binding var selectedDays: [UUID: Set<WeekDay>]
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 4) {
            ForEach(WeekDay.allCases, id: \.self) { day in
                let isSelected = selectedDays[room.id]?.contains(day) ?? false
                Text(day.shortLocalizedName)
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .background(
                        isSelected
                        ? Color.blue
                        : Color.gray.opacity(0.2)
                    )
                    .foregroundColor(
                        isSelected
                        ? .white
                        : .primary
                    )
                    .cornerRadius(4)
                    .onTapGesture {
                        toggleDay(day)
                    }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func toggleDay(_ day: WeekDay) {
        var days = selectedDays[room.id] ?? Set<WeekDay>()
        
        if days.contains(day) {
            days.remove(day)
        } else {
            days.insert(day)
        }
        
        selectedDays[room.id] = days
    }
}

struct EditTaskView: View {
    @EnvironmentObject var viewModel: HouseholdViewModel
    @Environment(\.dismiss) var dismiss
    let task: Task
    
    @State private var title: String
    @State private var description: String
    @State private var selectedRooms: Set<Room> = []
    @State private var selectedDays: [UUID: Set<WeekDay>] = [:]
    @State private var selectedIntervals: [UUID: TaskInterval] = [:]
    
    init(task: Task) {
        self.task = task
        _title = State(initialValue: task.title)
        _description = State(initialValue: task.description ?? "")
    }
    
    private func loadTaskAssignments() {
        selectedRooms.removeAll()
        selectedDays.removeAll()
        selectedIntervals.removeAll()
        
        for assignment in viewModel.taskAssignments.filter({ $0.taskId == task.id }) {
            if let room = viewModel.getRoom(for: assignment.roomId) {
                selectedRooms.insert(room)
                selectedDays[room.id] = assignment.scheduledDays
                selectedIntervals[room.id] = assignment.interval
            }
        }
    }
    
    private func saveTask() {
        let updatedTask = Task(
            id: task.id,
            title: title,
            description: description.isEmpty ? nil : description,
            isCompleted: task.isCompleted,
            lastCompletedDate: task.lastCompletedDate
        )
        
        for room in viewModel.rooms {
            viewModel.removeTaskAssignment(task: task, from: room)
        }
        
        for room in selectedRooms {
            if let days = selectedDays[room.id], !days.isEmpty {
                viewModel.addTaskAssignment(
                    task: updatedTask,
                    room: room,
                    days: Array(days),
                    interval: selectedIntervals[room.id] ?? .weekly
                )
            }
        }
        
        viewModel.updateTask(updatedTask)
        dismiss()
    }
    
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
                                        if selectedDays[room.id] == nil {
                                            selectedDays[room.id] = []
                                        }
                                        if selectedIntervals[room.id] == nil {
                                            selectedIntervals[room.id] = .weekly
                                        }
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
                                
                                DaySelectionGrid(room: room, selectedDays: $selectedDays)
                                    .padding(.leading)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Speichern") {
                        saveTask()
                    }
                    .disabled(title.isEmpty || selectedRooms.isEmpty || selectedRooms.allSatisfy { selectedDays[$0.id]?.isEmpty ?? true })
                }
            }
            .navigationTitle("Aufgabe bearbeiten")
            .navigationBarItems(trailing: Button("Abbrechen") {
                dismiss()
            })
            .onAppear {
                loadTaskAssignments()
            }
        }
    }
} 
