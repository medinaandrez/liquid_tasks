import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTasks: [Task]
    var selection: NavigationItem?
    
    @State private var taskToEdit: Task?
    
    // Dynamic filtering based on selection
    var filteredTasks: [Task] {
        var tasks = allTasks.filter { task in
            switch selection {
            case .inbox:
                return task.project == nil && task.area == nil
            case .today:
                guard let dueDate = task.dueDate else { return false }
                return Calendar.current.isDateInToday(dueDate) || dueDate < Date()
            case .upcoming:
                guard let dueDate = task.dueDate else { return false }
                return dueDate > Date() && !Calendar.current.isDateInToday(dueDate)
            case .anytime:
                return true
            case .someday:
                return task.dueDate == nil && task.startDate == nil
            case .area(let selectedArea):
                return task.area?.id == selectedArea.id || task.project?.area?.id == selectedArea.id
            case .project(let selectedProject):
                return task.project?.id == selectedProject.id
            case .tag(let selectedTag):
                return task.tags?.contains(where: { $0.id == selectedTag.id }) ?? false
            case .none:
                return false
            }
        }
        
        // Sort first by sortOrder (Drag & Drop), then creationDate
        tasks.sort {
            if $0.sortOrder != $1.sortOrder {
                return $0.sortOrder < $1.sortOrder
            }
            return $0.creationDate < $1.creationDate
        }
        return tasks
    }
    
    var body: some View {
        List {
            ForEach(filteredTasks) { task in
                Button {
                    taskToEdit = task
                } label: {
                    TaskRowView(task: task)
                }
                .buttonStyle(.plain)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .contextMenu {
                    Button("Eliminar", role: .destructive) {
                        modelContext.delete(task)
                    }
                }
            }
            .onMove(perform: moveTask)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .sheet(item: $taskToEdit) { task in
            TaskFormView(taskToEdit: task)
        }
    }
    
    private func moveTask(from source: IndexSet, to destination: Int) {
        var tasks = filteredTasks
        tasks.move(fromOffsets: source, toOffset: destination)
        
        // Update sortOrder in database
        for (index, task) in tasks.enumerated() {
            task.sortOrder = index
        }
    }
}
