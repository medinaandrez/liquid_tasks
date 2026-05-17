import SwiftUI
import SwiftData

struct TaskFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var taskToEdit: Task?
    
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = Date()
    @State private var hasStartDate: Bool = false
    @State private var startDate: Date = Date()
    
    @Query private var projects: [Project]
    @State private var selectedProject: Project?
    
    @Query private var allTags: [Tag]
    @State private var selectedTags: Set<Tag> = []
    
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
                LinearGradient(colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)], startPoint: .top, endPoint: .bottom)
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
        if let task = taskToEdit {
            task.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            task.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            task.startDate = hasStartDate ? startDate : nil
            task.dueDate = hasDueDate ? dueDate : nil
            task.project = selectedProject
            task.tags = Array(selectedTags)
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
            modelContext.insert(newTask)
        }
        dismiss()
    }
}
