import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: HouseholdViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showingResetConfirmation = false
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Benachrichtigungen") {
                    Toggle("Benachrichtigungen aktivieren", isOn: $viewModel.settings.notificationsEnabled)
                    
                    if viewModel.settings.notificationsEnabled {
                        DatePicker(
                            "Erinnerung wenn nicht erledigt bis",
                            selection: $viewModel.settings.notificationTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
                }
                
                Section("Erscheinungsbild") {
                    Toggle("Dunkelmodus", isOn: $isDarkMode)
                }
                
                Section("Debugging") {
                    Button(action: {
                        if let logURL = viewModel.shareLogs() {
                            showingShareSheet = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("Logs teilen")
                        }
                    }
                    
                    Button(action: {
                        viewModel.clearLogs()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Logs löschen")
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showingResetConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Alle Daten zurücksetzen")
                        }
                    }
                } footer: {
                    Text("Dies löscht alle Räume, Aufgaben und Einstellungen unwiderruflich.")
                }
            }
            .navigationTitle("Einstellungen")
            .alert("Daten zurücksetzen?", isPresented: $showingResetConfirmation) {
                Button("Abbrechen", role: .cancel) { }
                Button("Zurücksetzen", role: .destructive) {
                    viewModel.resetAllData()
                }
            } message: {
                Text("Alle Räume, Aufgaben und Einstellungen werden unwiderruflich gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.")
            }
            .sheet(isPresented: $showingShareSheet) {
                if let logURL = viewModel.shareLogs() {
                    ShareSheet(items: [logURL])
                }
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 