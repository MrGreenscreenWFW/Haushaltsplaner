import SwiftUI

struct AddRoomView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: HouseholdViewModel
    @State private var name = ""
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Raum Details")) {
                    TextField("Name", text: $name)
                    TextField("Beschreibung", text: $description)
                }
                
                Section {
                    Button("Save") {
                        let room = Room(
                            name: name,
                            description: description.isEmpty ? nil : description
                        )
                        viewModel.addRoom(room)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .navigationTitle("Raum hinzufügen")
            .navigationBarItems(trailing: Button("Abbrechen") {
                dismiss()
            })
        }
    }
} 
