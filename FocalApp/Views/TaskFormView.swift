import SwiftUI
import SwiftData

struct SubtaskDraft: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
    var original: Subtask?
}

struct TaskFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var taskToEdit: Task?
    var defaultProject: Project?
    var defaultTags: [Tag]?
    
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = Date()
    @State private var hasStartDate: Bool = false
    @State private var startDate: Date = Date()
    
    @State private var subtasks: [SubtaskDraft] = []
    @State private var newSubtaskTitle: String = ""
    
    @Query private var projects: [Project]
    @State private var selectedProject: Project?
    
    @Query private var allTags: [Tag]
    @State private var selectedTags: Set<Tag> = []
    @AppStorage("appTheme") private var appTheme: String = "classic"
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Bloque de Detalles
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Detalles")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        TextField("Título de la tarea", text: $title)
                            .textFieldStyle(.roundedBorder)
                            .font(.title3)
                        
                        TextField("Notas (opcional)", text: $notes, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.2), lineWidth: 1))
                    
                    // Bloque de Subtareas
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Checklist")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        ForEach($subtasks) { $subtask in
                            HStack {
                                Button {
                                    subtask.isCompleted.toggle()
                                } label: {
                                    Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(subtask.isCompleted ? .green : .secondary)
                                }
                                .buttonStyle(.plain)
                                
                                TextField("Subtarea", text: $subtask.title)
                                    .strikethrough(subtask.isCompleted)
                                    .foregroundStyle(subtask.isCompleted ? .secondary : .primary)
                                
                                Button(role: .destructive) {
                                    subtasks.removeAll(where: { $0.id == subtask.id })
                                } label: {
                                    Image(systemName: "xmark")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "plus.circle")
                                .foregroundStyle(.secondary)
                            TextField("Nueva subtarea", text: $newSubtaskTitle)
                                .onSubmit {
                                    let trimmed = newSubtaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                                    if !trimmed.isEmpty {
                                        subtasks.append(SubtaskDraft(title: trimmed, isCompleted: false))
                                        newSubtaskTitle = ""
                                    }
                                }
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.2), lineWidth: 1))
                    
                    // Bloque de Programación
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Programación")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        Toggle("Fecha de inicio", isOn: $hasStartDate)
                        if hasStartDate {
                            DatePicker("Seleccionar inicio", selection: $startDate, displayedComponents: .date)
                                .labelsHidden()
                        }
                        
                        Divider()
                        
                        Toggle("Fecha de vencimiento", isOn: $hasDueDate)
                        if hasDueDate {
                            DatePicker("Seleccionar vencimiento", selection: $dueDate, displayedComponents: .date)
                                .labelsHidden()
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.2), lineWidth: 1))
                    
                    // Bloque de Organización
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Organización")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Text("Proyecto")
                            Spacer()
                            Picker("Proyecto", selection: $selectedProject) {
                                Text("Ninguno").tag(Project?.none)
                                ForEach(projects) { project in
                                    Text(project.title).tag(Project?.some(project))
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                        }
                        
                        if !allTags.isEmpty {
                            Divider()
                            NavigationLink {
                                List(allTags) { tag in
                                    Button {
                                        if selectedTags.contains(tag) {
                                            selectedTags.remove(tag)
                                        } else {
                                            selectedTags.insert(tag)
                                        }
                                    } label: {
                                        HStack {
                                            Circle().fill(Color(hex: tag.colorHex)).frame(width: 12, height: 12)
                                            Text(tag.name)
                                                .foregroundStyle(.primary)
                                            Spacer()
                                            if selectedTags.contains(tag) {
                                                Image(systemName: "checkmark")
                                                    .foregroundStyle(.blue)
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                                .navigationTitle("Etiquetas")
                            } label: {
                                HStack {
                                    Text("Etiquetas")
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Text("\(selectedTags.count) seleccionadas")
                                        .foregroundStyle(.secondary)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.2), lineWidth: 1))
                    
                }
                .padding()
            }
            .background(
                Group {
                    if let currentTheme = AppTheme(rawValue: appTheme) {
                        currentTheme.detailGradient
                    } else {
                        LinearGradient(colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)], startPoint: .top, endPoint: .bottom)
                    }
                }
                .ignoresSafeArea()
            )
            .navigationTitle(taskToEdit == nil ? "Nueva Tarea" : "Editar Tarea")
            .onAppear {
                if let task = taskToEdit {
                    title = task.title
                    notes = task.notes
                    if let sDate = task.startDate {
                        hasStartDate = true
                        startDate = sDate
                    }
                    if let dDate = task.dueDate {
                        hasDueDate = true
                        dueDate = dDate
                    }
                    selectedProject = task.project
                    if let t = task.tags {
                        selectedTags = Set(t)
                    }
                    if let s = task.subtasks {
                        subtasks = s.sorted(by: { $0.sortOrder < $1.sortOrder }).map { SubtaskDraft(title: $0.title, isCompleted: $0.isCompleted, original: $0) }
                    }
                } else {
                    selectedProject = defaultProject
                    if let tags = defaultTags {
                        selectedTags = Set(tags)
                    }
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveTask()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 450, minHeight: 550)
        #endif
    }
    
    private func saveTask() {
        // Prepare subtasks
        if let oldSubtasks = taskToEdit?.subtasks {
            for subtask in oldSubtasks {
                modelContext.delete(subtask)
            }
        }
        
        var newSubtasksList: [Subtask] = []
        for (index, draft) in subtasks.enumerated() {
            let trimmed = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                let newSubtask = Subtask(title: trimmed, isCompleted: draft.isCompleted, sortOrder: index)
                newSubtasksList.append(newSubtask)
            }
        }
        
        let trimmedNew = newSubtaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedNew.isEmpty {
            let newSubtask = Subtask(title: trimmedNew, isCompleted: false, sortOrder: newSubtasksList.count)
            newSubtasksList.append(newSubtask)
        }
        
        if let task = taskToEdit {
            task.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            task.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            task.startDate = hasStartDate ? startDate : nil
            task.dueDate = hasDueDate ? dueDate : nil
            task.project = selectedProject
            task.tags = Array(selectedTags)
            task.subtasks = newSubtasksList
        } else {
            let newTask = Task(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                isCompleted: false,
                startDate: hasStartDate ? startDate : nil,
                dueDate: hasDueDate ? dueDate : nil
            )
            
            newTask.project = selectedProject
            newTask.tags = Array(selectedTags)
            newTask.subtasks = newSubtasksList
            modelContext.insert(newTask)
        }
        dismiss()
    }
}
