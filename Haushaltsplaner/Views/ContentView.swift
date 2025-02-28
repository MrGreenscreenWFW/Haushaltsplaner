import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = HouseholdViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Heute", systemImage: "house.fill")
                }
            
            RoomsView()
                .tabItem {
                    Label("Räume", systemImage: "door.left.hand.open")
                }
            
            TasksView()
                .tabItem {
                    Label("Aufgaben", systemImage: "checklist")
                }
            
            SettingsView()
                .tabItem {
                    Label("Einstellungen", systemImage: "gear")
                }
        }
        .environmentObject(viewModel)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
} 