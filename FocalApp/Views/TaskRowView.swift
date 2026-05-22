import SwiftUI
import SwiftData

struct TaskRowView: View {
    @Bindable var task: Task
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    task.isCompleted.toggle()
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                
                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 8) {
                    if let project = task.project {
                        Label(project.title, systemImage: "circle.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    } else if let area = task.area {
                        Label(area.title, systemImage: "folder.fill")
                            .font(.caption)
                            .foregroundStyle(.purple)
                    }
                    
                    if let dueDate = task.dueDate {
                        let isOverdue = dueDate < Date() && !Calendar.current.isDateInToday(dueDate)
                        Label(dueDate.formatted(.dateTime.month().day()), systemImage: "calendar")
                            .font(.caption)
                            .foregroundStyle(isOverdue ? .red : .secondary)
                    }
                    
                    if let tags = task.tags, !tags.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(tags) { tag in
                                Circle()
                                    .fill(Color(hex: tag.colorHex))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.leading, 4)
                    }
                    
                    if let subtasks = task.subtasks, !subtasks.isEmpty {
                        let completed = subtasks.filter { $0.isCompleted }.count
                        Label("\(completed)/\(subtasks.count)", systemImage: "checklist")
                            .font(.caption)
                            .foregroundStyle(completed == subtasks.count ? .green : .secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        // Aesthetic Liquid Glass effect on the row level
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.15), lineWidth: 1)
        )
        // Light shadow for depth
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
