import Foundation
import Combine
import UserNotifications
import SwiftUI

class HouseholdViewModel: ObservableObject {
    @Published var rooms: [Room] = []
    @Published var tasks: [Task] = []
    @Published var taskAssignments: [TaskAssignment] = []
    @Published var settings: Settings = .default
    @Published var logMessages: [String] = []
    
    private let roomsKey = "savedRooms"
    private let tasksKey = "savedTasks"
    private let settingsKey = "savedSettings"
    private let taskAssignmentsKey = "savedTaskAssignments"
    
    init() {
        loadData()
        setupNotifications()
        log("App gestartet")
    }
    
    var todaysTasks: [Task] {
        let weekDayNames = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]
        let today = weekDayNames[Calendar.current.component(.weekday, from: Date()) - 1]
        if let weekDay = WeekDay(rawValue: today) {
            let todaysAssignments = taskAssignments.filter { assignment in
                assignment.scheduledDays.contains(weekDay)
            }
            return tasks.filter { task in
                todaysAssignments.contains { assignment in
                    assignment.taskId == task.id
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
        taskAssignments.removeAll { $0.roomId == room.id }
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
        print("Toggle Task Completion - Task: \(task.title)")
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            tasks[index].lastCompletedDate = tasks[index].isCompleted ? Date() : nil
            
            // Aktualisiere das lastExecuted Datum für alle Zuweisungen dieser Aufgabe
            if tasks[index].isCompleted {
                print("Task wurde als erledigt markiert - Aktualisiere Zuweisungen")
                var updatedAssignments = taskAssignments
                for (i, assignment) in taskAssignments.enumerated() {
                    if assignment.taskId == task.id {
                        print("Aktualisiere Zuweisung für Raum ID: \(assignment.roomId)")
                        var updatedAssignment = assignment
                        updatedAssignment.lastExecuted = Date()
                        updatedAssignments[i] = updatedAssignment
                    }
                }
                taskAssignments = updatedAssignments
                print("Anzahl der Zuweisungen nach Update: \(taskAssignments.count)")
            }
            
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
    
    func addTaskAssignment(task: Task, room: Room, days: [WeekDay], interval: TaskInterval = .weekly) {
        log("Füge Task-Zuweisung hinzu - Task: \(task.title), Raum: \(room.name), Tage: \(days)")
        
        // Erstelle eine neue Zuweisung
        let assignment = TaskAssignment(
            taskId: task.id,
            roomId: room.id,
            scheduledDays: Set(days),
            interval: interval
        )
        
        // Entferne nur die Zuweisung für diesen spezifischen Raum
        taskAssignments.removeAll { 
            $0.taskId == task.id && $0.roomId == room.id
        }
        
        // Füge die neue Zuweisung hinzu
        taskAssignments.append(assignment)
        log("Neue Zuweisung erstellt: \(assignment)")
        
        saveData()
    }
    
    func removeTasksFromRoom(at offsets: IndexSet, roomId: UUID) {
        let tasksToRemove = tasks.enumerated()
            .filter { index, task in
                offsets.contains(index)
            }
            .map { $0.1 }
        
        for task in tasksToRemove {
            removeTaskAssignment(task: task, from: getRoom(for: roomId)!)
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
        
        // Bestimme den aktuellen Wochentag
        let weekDayNames = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]
        let today = weekDayNames[Calendar.current.component(.weekday, from: Date()) - 1]
        guard let currentWeekDay = WeekDay(rawValue: today) else { return }
        
        // Filtere Aufgaben, die für heute geplant sind und nicht erledigt wurden
        let todaysAssignments = taskAssignments.filter { assignment in
            assignment.scheduledDays.contains(currentWeekDay)
        }
        
        let tasksForToday = tasks.filter { task in
            !task.isCompleted && todaysAssignments.contains { assignment in
                assignment.taskId == task.id
            }
        }
        
        // Erstelle Benachrichtigungen nur für die Aufgaben von heute
        for task in tasksForToday {
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
            log("Speichere Daten - Anzahl der Task-Zuweisungen: \(taskAssignments.count)")
            
            // Überprüfe die Zuweisungen vor dem Speichern
            for assignment in taskAssignments {
                log("Zuweisung - Task ID: \(assignment.taskId), Raum ID: \(assignment.roomId)")
                // Überprüfe, ob die referenzierten IDs noch existieren
                if !tasks.contains(where: { $0.id == assignment.taskId }) {
                    log("WARNUNG: Task ID \(assignment.taskId) existiert nicht mehr")
                }
                if !rooms.contains(where: { $0.id == assignment.roomId }) {
                    log("WARNUNG: Raum ID \(assignment.roomId) existiert nicht mehr")
                }
            }
            
            // Räume speichern
            let roomsData = try JSONEncoder().encode(rooms)
            UserDefaults.standard.set(roomsData, forKey: roomsKey)
            
            // Aufgaben speichern
            let tasksData = try JSONEncoder().encode(tasks)
            UserDefaults.standard.set(tasksData, forKey: tasksKey)
            
            // Einstellungen speichern
            let settingsData = try JSONEncoder().encode(settings)
            UserDefaults.standard.set(settingsData, forKey: settingsKey)
            
            // Task-Zuweisungen speichern
            let taskAssignmentsData = try JSONEncoder().encode(taskAssignments)
            UserDefaults.standard.set(taskAssignmentsData, forKey: taskAssignmentsKey)
            
            // Synchronisiere UserDefaults
            UserDefaults.standard.synchronize()
            
            log("Daten erfolgreich gespeichert")
            
            // Benachrichtigungen aktualisieren
            scheduleNotifications()
        } catch {
            log("Fehler beim Speichern der Daten: \(error.localizedDescription)")
        }
    }
    
    private func loadData() {
        log("Lade Daten...")
        // Räume laden
        if let roomsData = UserDefaults.standard.data(forKey: roomsKey) {
            do {
                rooms = try JSONDecoder().decode([Room].self, from: roomsData)
                log("Räume erfolgreich geladen: \(rooms.count)")
            } catch {
                log("Fehler beim Laden der Räume: \(error.localizedDescription)")
                rooms = []
            }
        }
        
        // Aufgaben laden
        if let tasksData = UserDefaults.standard.data(forKey: tasksKey) {
            do {
                tasks = try JSONDecoder().decode([Task].self, from: tasksData)
                log("Aufgaben erfolgreich geladen: \(tasks.count)")
            } catch {
                log("Fehler beim Laden der Aufgaben: \(error.localizedDescription)")
                tasks = []
            }
        }
        
        // Einstellungen laden
        if let settingsData = UserDefaults.standard.data(forKey: settingsKey) {
            do {
                settings = try JSONDecoder().decode(Settings.self, from: settingsData)
                log("Einstellungen erfolgreich geladen")
            } catch {
                log("Fehler beim Laden der Einstellungen: \(error.localizedDescription)")
                settings = .default
            }
        }
        
        // Task-Zuweisungen laden
        if let taskAssignmentsData = UserDefaults.standard.data(forKey: taskAssignmentsKey) {
            do {
                taskAssignments = try JSONDecoder().decode([TaskAssignment].self, from: taskAssignmentsData)
                log("Task-Zuweisungen erfolgreich geladen: \(taskAssignments.count)")
            } catch {
                log("Fehler beim Laden der Task-Zuweisungen: \(error.localizedDescription)")
                taskAssignments = []
            }
        } else {
            log("Keine gespeicherten Task-Zuweisungen gefunden")
        }
    }
    
    // MARK: - Data Reset (nützlich für Debugging oder wenn der Benutzer alle Daten zurücksetzen möchte)
    
    func resetAllData() {
        // Alle Daten aus UserDefaults löschen
        UserDefaults.standard.removeObject(forKey: roomsKey)
        UserDefaults.standard.removeObject(forKey: tasksKey)
        UserDefaults.standard.removeObject(forKey: settingsKey)
        UserDefaults.standard.removeObject(forKey: taskAssignmentsKey)
        
        // Arrays zurücksetzen
        rooms = []
        tasks = []
        taskAssignments = []
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
        log("Entferne Task-Zuweisung - Task: \(task.title), Raum: \(room.name)")
        let beforeCount = taskAssignments.count
        taskAssignments.removeAll { assignment in
            assignment.taskId == task.id && assignment.roomId == room.id
        }
        let afterCount = taskAssignments.count
        log("Task-Zuweisungen vorher: \(beforeCount), nachher: \(afterCount)")
        saveData()
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
            // Prüfe ob der Wochentag passt
            guard assignment.scheduledDays.contains(todayWeekDay) else { return false }
            
            // Wenn die Aufgabe noch nie ausgeführt wurde, zeige sie an
            guard let lastExecuted = assignment.lastExecuted else { return true }
            
            // Berechne die vergangenen Wochen seit der letzten Ausführung
            let weeksSinceLastExecution = calendar.dateComponents([.weekOfYear], from: lastExecuted, to: Date()).weekOfYear ?? 0
            
            // Prüfe ob das Intervall eingehalten wird
            return weeksSinceLastExecution >= assignment.interval.rawValue
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
    
    // MARK: - Logging
    
    private func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logMessage = "[\(timestamp)] \(message)"
        print(logMessage)
        logMessages.append(logMessage)
        
        // Speichere Logs in einer Datei
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let logFileURL = documentsPath.appendingPathComponent("haushaltsplaner_logs.txt")
            
            do {
                let logString = logMessages.joined(separator: "\n")
                try logString.write(to: logFileURL, atomically: true, encoding: .utf8)
            } catch {
                print("Fehler beim Speichern der Logs: \(error.localizedDescription)")
            }
        }
    }
    
    func shareLogs() -> URL? {
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let logFileURL = documentsPath.appendingPathComponent("haushaltsplaner_logs.txt")
            return logFileURL
        }
        return nil
    }
    
    func clearLogs() {
        logMessages.removeAll()
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let logFileURL = documentsPath.appendingPathComponent("haushaltsplaner_logs.txt")
            try? FileManager.default.removeItem(at: logFileURL)
        }
    }
} 