import SwiftUI

struct TasksView: View {
    @EnvironmentObject var viewModel: HouseholdViewModel
    @State private var showingAddTask = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.tasks) { task in
                    TaskRow(task: task)
                }
                .onDelete(perform: viewModel.deleteTasks)
            }
            .navigationTitle("Aufgaben")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
            }
        }
    }
} 