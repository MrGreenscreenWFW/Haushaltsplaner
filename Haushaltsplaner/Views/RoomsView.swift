import SwiftUI

struct RoomsView: View {
    @EnvironmentObject var viewModel: HouseholdViewModel
    @State private var showingAddRoom = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.rooms) { room in
                    NavigationLink {
                        RoomDetailView(room: room)
                    } label: {
                        RoomRowView(room: room)
                    }
                }
                .onDelete(perform: viewModel.deleteRooms)
            }
            .navigationTitle("Räume")
            .toolbar {
                Button(action: { showingAddRoom = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddRoom) {
                AddRoomView()
            }
        }
    }
}

// Extrahieren der Zeilenansicht in eine separate View
struct RoomRowView: View {
    let room: Room
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(room.name)
                .font(.headline)
            if let description = room.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}