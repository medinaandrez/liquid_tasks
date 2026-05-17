import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTasks: [Task]
    var selection: NavigationItem?
    
    // Dynamic filtering based on selection
    var filteredTasks: [Task] {
        allTasks.filter { task in
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
        }.sorted { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredTasks) { task in
                    TaskRowView(task: task)
                        .contextMenu {
                            Button("Eliminar", role: .destructive) {
                                modelContext.delete(task)
                            }
                        }
                }
            }
            .padding()
        }
        .scrollContentBackground(.hidden)
    }
}
