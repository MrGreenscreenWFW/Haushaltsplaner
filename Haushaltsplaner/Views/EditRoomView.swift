import SwiftUI

struct EditRoomView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: HouseholdViewModel
    
    let room: Room
    @State private var roomName: String
    
    init(room: Room) {
        self.room = room
        _roomName = State(initialValue: room.name)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Raumname", text: $roomName)
                }
            }
            .navigationTitle("Raum bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        viewModel.updateRoom(room, newName: roomName)
                        dismiss()
                    }
                    .disabled(roomName.isEmpty)
                }
            }
        }
    }
} 