import SwiftUI

struct AddRoomView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: HouseholdViewModel
    @State private var name = ""
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Room Details")) {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
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
            .navigationTitle("Add Room")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
} 