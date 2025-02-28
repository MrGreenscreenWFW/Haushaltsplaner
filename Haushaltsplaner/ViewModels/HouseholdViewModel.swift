import Foundation
import Combine
import UserNotifications

class HouseholdViewModel: ObservableObject {
    @Published var rooms: [Room] = []
    @Published var tasks: [Task] = []
    @Published var taskAssignments: [TaskAssignment] = []
    @Published var settings: Settings = .default
    
    private let roomsKey = "savedRooms"
    private let tasksKey = "savedTasks"
    private let settingsKey = "savedSettings"
    
    init() {
        loadData()
        setupNotifications()
    }
    
    var todaysTasks: [Task] {
        let weekDayNames = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]
        let today = weekDayNames[Calendar.current.component(.weekday, from: Date()) - 1]
        if let weekDay = WeekDay(rawValue: today) {
            return tasks.filter { task in
                task.assignments.contains { assignment in
                    assignment.scheduledDays.contains(weekDay)
                }
            }
        }
        return []
    }
    
    // MARK: - Room Management
    func addRoom(_ room: Room) {
        rooms.append(room)
        saveData()
    }
    
    func updateRoom(_ room: Room, newName: String) {
        if let index = rooms.firstIndex(where: { $0.id == room.id }) {
            rooms[index].name = newName
            saveData()
        }
    }
    
    func deleteRoom(_ room: Room) {
        rooms.removeAll { $0.id == room.id }
        // Remove all task assignments for this room
        for taskIndex in tasks.indices {
            tasks[taskIndex].assignments.removeAll { $0.roomId == room.id }
        }
        saveData()
    }
    
    func deleteRoom(at offsets: IndexSet) {
        let roomsToDelete = offsets.map { rooms[$0] }
        for room in roomsToDelete {
            deleteRoom(room)
        }
    }
    
    // MARK: - Task Management
    func addTask(_ task: Task) {
        tasks.append(task)
        saveData()
    }
    
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveData()
    }
    
    func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            tasks[index].lastCompletedDate = tasks[index].isCompleted ? Date() : nil
            saveData()
        }
    }
    
    func getRoom(for id: UUID) -> Room? {
        rooms.first { $0.id == id }
    }
    
    func getTasksForRoom(_ room: Room) -> [Task] {
        let roomAssignments = taskAssignments.filter { $0.roomId == room.id }
        return tasks.filter { task in
            roomAssignments.contains { assignment in
                assignment.taskId == task.id
            }
        }
    }
    
    func addTaskAssignment(task: Task, room: Room, days: [WeekDay]) {
        let assignment = TaskAssignment(
            taskId: task.id,
            roomId: room.id,
            scheduledDays: Set(days)
        )
        taskAssignments.append(assignment)
        saveData()
    }
    
    func removeTasksFromRoom(at offsets: IndexSet, roomId: UUID) {
        for _ in offsets {
            if let taskIndex = tasks.firstIndex(where: { task in
                task.assignments.contains { $0.roomId == roomId }
            }) {
                tasks[taskIndex].assignments.removeAll { $0.roomId == roomId }
            }
        }
        saveData()
    }
    
    // MARK: - Notifications
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async {
                self.settings.notificationsEnabled = granted
                self.scheduleNotifications()
            }
        }
    }
    
    private func scheduleNotifications() {
        guard settings.notificationsEnabled else { return }
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: settings.notificationTime)
        
        for task in tasks where !task.isCompleted {
            let content = UNMutableNotificationContent()
            content.title = "Unerledigte Aufgabe"
            content.body = "Die Aufgabe '\(task.title)' wurde heute noch nicht erledigt."
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: true
            )
            
            let request = UNNotificationRequest(
                identifier: task.id.uuidString,
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    // MARK: - Persistence
    
    private func saveData() {
        do {
            // Räume speichern
            let roomsData = try JSONEncoder().encode(rooms)
            UserDefaults.standard.set(roomsData, forKey: roomsKey)
            
            // Aufgaben speichern
            let tasksData = try JSONEncoder().encode(tasks)
            UserDefaults.standard.set(tasksData, forKey: tasksKey)
            
            // Einstellungen speichern
            let settingsData = try JSONEncoder().encode(settings)
            UserDefaults.standard.set(settingsData, forKey: settingsKey)
            
            // Benachrichtigungen aktualisieren
            scheduleNotifications()
        } catch {
            print("Fehler beim Speichern der Daten: \(error.localizedDescription)")
        }
    }
    
    private func loadData() {
        // Räume laden
        if let roomsData = UserDefaults.standard.data(forKey: roomsKey) {
            do {
                rooms = try JSONDecoder().decode([Room].self, from: roomsData)
            } catch {
                print("Fehler beim Laden der Räume: \(error.localizedDescription)")
                rooms = []
            }
        }
        
        // Aufgaben laden
        if let tasksData = UserDefaults.standard.data(forKey: tasksKey) {
            do {
                tasks = try JSONDecoder().decode([Task].self, from: tasksData)
            } catch {
                print("Fehler beim Laden der Aufgaben: \(error.localizedDescription)")
                tasks = []
            }
        }
        
        // Einstellungen laden
        if let settingsData = UserDefaults.standard.data(forKey: settingsKey) {
            do {
                settings = try JSONDecoder().decode(Settings.self, from: settingsData)
            } catch {
                print("Fehler beim Laden der Einstellungen: \(error.localizedDescription)")
                settings = .default
            }
        }
    }
    
    // MARK: - Data Reset (nützlich für Debugging oder wenn der Benutzer alle Daten zurücksetzen möchte)
    
    func resetAllData() {
        // Alle Daten aus UserDefaults löschen
        UserDefaults.standard.removeObject(forKey: roomsKey)
        UserDefaults.standard.removeObject(forKey: tasksKey)
        UserDefaults.standard.removeObject(forKey: settingsKey)
        
        // Arrays zurücksetzen
        rooms = []
        tasks = []
        settings = .default
        
        // Benachrichtigungen entfernen
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func deleteRooms(at offsets: IndexSet) {
        rooms.remove(atOffsets: offsets)
        saveData()
    }
    
    func deleteTasks(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveData()
    }
    
    // Neue Funktion zum Entfernen einer Task-Zuweisung
    func removeTaskAssignment(task: Task, from room: Room) {
        taskAssignments.removeAll { assignment in
            assignment.taskId == task.id && assignment.roomId == room.id
        }
    }
    
    // Verbesserte Funktion für die heutigen Tasks
    func getTodaysTasks() -> [Task] {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        // Konvertiere den weekday zu unserem WeekDay enum (Sonntag = 1 in Calendar)
        let weekDayMap: [Int: WeekDay] = [
            2: .monday,    // Montag
            3: .tuesday,   // Dienstag
            4: .wednesday, // Mittwoch
            5: .thursday,  // Donnerstag
            6: .friday,    // Freitag
            7: .saturday,  // Samstag
            1: .sunday     // Sonntag
        ]
        
        guard let todayWeekDay = weekDayMap[today] else { return [] }
        
        // Finde alle TaskAssignments für heute
        let todaysAssignments = taskAssignments.filter { assignment in
            assignment.scheduledDays.contains(todayWeekDay)
        }
        
        // Hole die entsprechenden Tasks
        return tasks.filter { task in
            todaysAssignments.contains { assignment in
                assignment.taskId == task.id
            }
        }
    }
    
    // Hilfsfunktion um den Raum für eine Task zu finden
    func getRoomForTask(_ task: Task) -> Room? {
        guard let assignment = taskAssignments.first(where: { $0.taskId == task.id }) else {
            return nil
        }
        return rooms.first { $0.id == assignment.roomId }
    }
    
    func updateTask(_ updatedTask: Task) {
        if let index = tasks.firstIndex(where: { $0.id == updatedTask.id }) {
            tasks[index] = updatedTask
            saveData()
        }
    }
} 