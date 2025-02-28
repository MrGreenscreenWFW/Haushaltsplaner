import Foundation

struct Settings: Codable {
    var notificationTime: Date
    var isDarkMode: Bool
    var notificationsEnabled: Bool
    
    static let `default` = Settings(
        notificationTime: Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date(),
        isDarkMode: false,
        notificationsEnabled: true
    )
} 