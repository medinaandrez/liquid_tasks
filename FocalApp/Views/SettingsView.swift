import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Persistent preferences
    @AppStorage("appTheme") private var appTheme: String = "classic"
    @AppStorage("iconBadgePreference") private var iconBadgePreference: String = "today"
    @AppStorage("defaultScheduleToday") private var defaultScheduleToday: Bool = false
    @AppStorage("glassmorphicEffects") private var glassmorphicEffects: Bool = true
    
    // Queries to calculate statistics and perform backup/restore
    @Query private var spaces: [Space]
    @Query private var projects: [Project]
    @Query private var tags: [Tag]
    @Query private var tasks: [Task]
    @Query private var subtasks: [Subtask]
    
    // State variables for popups / alerts
    @State private var showingWipeAlert = false
    @State private var showingMockAlert = false
    @State private var showingImportSheet = false
    @State private var importText = ""
    @State private var showingImportStatus = false
    @State private var importSuccess = false
    
    var currentTheme: AppTheme {
        AppTheme(rawValue: appTheme) ?? .classic
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Section 1: Estadísticas de Enfoque (Analytics Card)
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 20) {
                            // Círculo de progreso
                            let completedCount = tasks.filter { $0.isCompleted }.count
                            let totalCount = tasks.count
                            let completionRatio = totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0.0
                            
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.15), lineWidth: 10)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .trim(from: 0.0, to: CGFloat(completionRatio))
                                    .stroke(
                                        LinearGradient(
                                            colors: currentTheme.previewColors,
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                                    )
                                    .frame(width: 80, height: 80)
                                    .rotationEffect(Angle(degrees: -90))
                                    .animation(.easeOut(duration: 1.0), value: completionRatio)
                                
                                Text("\(Int(completionRatio * 100))%")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.primary)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Resumen de Enfoque")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                Text("\(completedCount) de \(totalCount) tareas completadas")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                Text("\(spaces.count) Espacios • \(projects.count) Proyectos")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(glassmorphicEffects ? Color.clear : nil)
                } header: {
                    Text("Productividad")
                }
                
                // Section 2: Personalización Estética (Themes Selector)
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Temas Líquidos")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 16) {
                            ForEach(AppTheme.allCases) { theme in
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        appTheme = theme.rawValue
                                    }
                                } label: {
                                    VStack(spacing: 6) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: theme.previewColors,
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 50, height: 50)
                                                .overlay(
                                                    Circle()
                                                        .stroke(appTheme == theme.rawValue ? Color.primary : Color.clear, lineWidth: 2)
                                                )
                                                .shadow(radius: 3)
                                            
                                            if appTheme == theme.rawValue {
                                                Image(systemName: "checkmark")
                                                    .font(.title3.bold())
                                                    .foregroundStyle(.white)
                                            }
                                        }
                                        
                                        Text(theme.displayName)
                                            .font(.caption)
                                            .foregroundStyle(appTheme == theme.rawValue ? .primary : .secondary)
                                    }
                                }
                                .buttonStyle(.plain)
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        Divider()
                        
                        Toggle("Efecto Esmerilado (Glassmorphism)", isOn: $glassmorphicEffects)
                            .tint(.blue)
                    }
                    .listRowBackground(glassmorphicEffects ? Color.clear : nil)
                } header: {
                    Text("Personalización")
                }
                
                // Section 3: Preferencias del Flujo (Focus Flow Settings)
                Section {
                    Picker("Globo de Notificación (Badge)", selection: $iconBadgePreference) {
                        Text("Tareas del Día").tag("today")
                        Text("Bandeja de Entrada").tag("inbox")
                        Text("Desactivado").tag("disabled")
                    }
                    
                    Toggle("Programar Hoy al Crear Tarea", isOn: $defaultScheduleToday)
                        .tint(.blue)
                } header: {
                    Text("Flujo de Trabajo")
                }
                .listRowBackground(glassmorphicEffects ? Color.clear : nil)
                
                // Section 4: Administración de Base de Datos Local
                Section {
                    // Cargar Mock Data
                    Button {
                        showingMockAlert = true
                    } label: {
                        Label("Cargar Datos de Prueba", systemImage: "square.grid.3x1.folder.badge.plus")
                            .foregroundStyle(.blue)
                    }
                    .alert("¿Cargar datos de prueba?", isPresented: $showingMockAlert) {
                        Button("Cancelar", role: .cancel) {}
                        Button("Cargar", role: .none) {
                            generateMockData()
                        }
                    } message: {
                        Text("Esto generará una estructura demo de espacios, proyectos y tareas para previsualizar el diseño de Focal App al instante.")
                    }
                    
                    // Respaldar / Exportar JSON
                    let jsonBackup = exportDataString()
                    ShareLink(item: jsonBackup, preview: SharePreview("Copia de Seguridad Focal App", icon: Image(systemName: "square.and.arrow.up"))) {
                        Label("Respaldar Datos (Exportar JSON)", systemImage: "square.and.arrow.up")
                            .foregroundStyle(.primary)
                    }
                    
                    // Importar JSON
                    Button {
                        showingImportSheet = true
                    } label: {
                        Label("Restaurar Datos (Importar JSON)", systemImage: "square.and.arrow.down")
                            .foregroundStyle(.primary)
                    }
                    .sheet(isPresented: $showingImportSheet) {
                        NavigationStack {
                            VStack(spacing: 16) {
                                Text("Pega aquí el texto JSON de tu copia de seguridad para restaurar la información:")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal)
                                
                                TextEditor(text: $importText)
                                    .font(.system(.caption, design: .monospaced))
                                    .border(Color.secondary.opacity(0.2))
                                    .cornerRadius(8)
                                    .padding()
                                
                                Button("Importar y Sobrescribir") {
                                    importSuccess = importData(jsonString: importText)
                                    showingImportSheet = false
                                    showingImportStatus = true
                                }
                                .disabled(importText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                .buttonStyle(.borderedProminent)
                                .tint(.green)
                                .padding(.bottom)
                            }
                            .navigationTitle("Importar Respaldo")
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("CancellationToken") {
                                        showingImportSheet = false
                                    }
                                }
                            }
                        }
                    }
                    
                    // Borrar todo
                    Button(role: .destructive) {
                        showingWipeAlert = true
                    } label: {
                        Label("Restablecer Base de Datos", systemImage: "trash.fill")
                            .foregroundStyle(.red)
                    }
                    .alert("¿Restablecer Focal App?", isPresented: $showingWipeAlert) {
                        Button("Cancelar", role: .cancel) {}
                        Button("Restablecer", role: .destructive) {
                            purgeDatabase()
                        }
                    } message: {
                        Text("Esta acción eliminará de forma irreversible todos tus Espacios, Proyectos, Etiquetas, Tareas y Subtareas locales.")
                    }
                } header: {
                    Text("Gestión de Datos (SwiftData)")
                }
                .listRowBackground(glassmorphicEffects ? Color.clear : nil)
                
                // Section 5: Acerca de & GitHub
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Focal App")
                                .font(.headline)
                            Text("Versión 1.0.0 (Build 1)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("© 2026 Andres Medina. Todos los derechos reservados.")
                                .font(.system(size: 10))
                                .foregroundStyle(.tertiary)
                        }
                        Spacer()
                        Image(systemName: "sparkles")
                            .font(.largeTitle)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: currentTheme.previewColors,
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .padding(.vertical, 8)
                    
                    Link(destination: URL(string: "https://github.com/medinaandrez/liquid_tasks")!) {
                        Label("Ver Código en GitHub", systemImage: "link")
                            .foregroundStyle(.blue)
                    }
                } header: {
                    Text("Acerca de la App")
                }
                .listRowBackground(glassmorphicEffects ? Color.clear : nil)
            }
            .background(
                currentTheme.detailGradient
                    .ignoresSafeArea()
            )
            .scrollContentBackground(.hidden)
            .navigationTitle("Ajustes")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            }
            .alert(importSuccess ? "Restauración Completada" : "Error en Importación", isPresented: $showingImportStatus) {
                Button("Entendido", role: .cancel) {
                    importText = ""
                }
            } message: {
                Text(importSuccess ? "Tu copia de seguridad de Focal App se importó exitosamente y se reestablecieron todos tus espacios y tareas." : "No se pudo decodificar el respaldo JSON. Por favor, asegúrate de haber pegado un JSON válido.")
            }
        }
        #if os(macOS)
        .frame(minWidth: 450, minHeight: 500)
        #endif
    }
    
    // Database Purge helper
    private func purgeDatabase() {
        do {
            // Delete subtasks first
            try modelContext.delete(model: Subtask.self)
            try modelContext.delete(model: Task.self)
            try modelContext.delete(model: Project.self)
            try modelContext.delete(model: Space.self)
            try modelContext.delete(model: Tag.self)
            try modelContext.save()
        } catch {
            print("Error clearing database: \(error)")
        }
    }
    
    // Mock Data Generator
    private func generateMockData() {
        // Clear database first to avoid overlapping duplicate IDs
        purgeDatabase()
        
        // 1. Create Spaces
        let workSpace = Space(title: "💼 Trabajo")
        let personalSpace = Space(title: "🏡 Personal")
        let studySpace = Space(title: "🎓 Estudios")
        
        modelContext.insert(workSpace)
        modelContext.insert(personalSpace)
        modelContext.insert(studySpace)
        
        // 2. Create Tags
        let highPriority = Tag(name: "Alta Prioridad", colorHex: "#FF3B30")
        let mediumPriority = Tag(name: "Medio", colorHex: "#FF9500")
        let lowPriority = Tag(name: "Idea", colorHex: "#AF52DE")
        
        modelContext.insert(highPriority)
        modelContext.insert(mediumPriority)
        modelContext.insert(lowPriority)
        
        // 3. Create Projects
        let appLaunch = Project(title: "🚀 Lanzamiento App", notes: "Lanzar Focal App en App Store")
        appLaunch.space = workSpace
        modelContext.insert(appLaunch)
        
        let travelPlan = Project(title: "✈️ Viaje a Japón", notes: "Planificar itinerario y reservas")
        travelPlan.space = personalSpace
        modelContext.insert(travelPlan)
        
        // 4. Create Tasks
        let task1 = Task(title: "Diseñar interfaz de Ajustes", notes: "Implementar Temas Líquidos y Mock Data", isCompleted: true, dueDate: Date(), sortOrder: 0)
        task1.project = appLaunch
        task1.space = workSpace
        task1.tags = [highPriority]
        modelContext.insert(task1)
        
        let task2 = Task(title: "Revisar pautas de App Store", notes: "Asegurar cumplimiento de directrices", isCompleted: false, dueDate: Date(), sortOrder: 1)
        task2.project = appLaunch
        task2.space = workSpace
        task2.tags = [mediumPriority]
        modelContext.insert(task2)
        
        let subtask1 = Subtask(title: "Crear capturas de pantalla")
        let subtask2 = Subtask(title: "Redactar descripción")
        subtask1.task = task2
        subtask2.task = task2
        modelContext.insert(subtask1)
        modelContext.insert(subtask2)
        
        let task3 = Task(title: "Reservar vuelos a Tokio", notes: "Buscar opciones directas", isCompleted: false, dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()), sortOrder: 0)
        task3.project = travelPlan
        task3.space = personalSpace
        modelContext.insert(task3)
        
        let task4 = Task(title: "Estudiar SwiftData Avanzado", notes: "Aprender sobre esquemas complejos", isCompleted: false, dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()), sortOrder: 0)
        task4.space = studySpace
        task4.tags = [lowPriority]
        modelContext.insert(task4)
        
        let task5 = Task(title: "Idea: Agregar temporizador Pomodoro", notes: "Para el panel de enfoque", isCompleted: false, sortOrder: 1)
        task5.tags = [lowPriority]
        modelContext.insert(task5)
        
        do {
            try modelContext.save()
        } catch {
            print("Error generating mock data: \(error)")
        }
    }
    
    // JSON Backup Serializer helper
    private func exportDataString() -> String {
        let spacesDTO = spaces.map { ExportData.SpaceDTO(id: $0.id, title: $0.title, creationDate: $0.creationDate) }
        let projectsDTO = projects.map { ExportData.ProjectDTO(id: $0.id, title: $0.title, notes: $0.notes, isCompleted: $0.isCompleted, creationDate: $0.creationDate, spaceId: $0.space?.id) }
        let tagsDTO = tags.map { ExportData.TagDTO(id: $0.id, name: $0.name, colorHex: $0.colorHex) }
        let tasksDTO = tasks.map { ExportData.TaskDTO(id: $0.id, title: $0.title, notes: $0.notes, isCompleted: $0.isCompleted, startDate: $0.startDate, dueDate: $0.dueDate, creationDate: $0.creationDate, sortOrder: $0.sortOrder, projectId: $0.project?.id, spaceId: $0.space?.id, tagIds: $0.tags?.map(\.id)) }
        
        var subtasksDTO: [ExportData.SubtaskDTO] = []
        for task in tasks {
            if let taskSubtasks = task.subtasks {
                for sub in taskSubtasks {
                    subtasksDTO.append(ExportData.SubtaskDTO(id: sub.id, title: sub.title, isCompleted: sub.isCompleted, taskId: task.id))
                }
            }
        }
        
        let exportData = ExportData(
            spaces: spacesDTO,
            projects: projectsDTO,
            tags: tagsDTO,
            tasks: tasksDTO,
            subtasks: subtasksDTO
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(exportData)
            return String(data: data, encoding: .utf8) ?? "{}"
        } catch {
            return "{}"
        }
    }
    
    // Backup deserializer & restore helper
    private func importData(jsonString: String) -> Bool {
        guard let data = jsonString.data(using: .utf8) else { return false }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let decoded = try decoder.decode(ExportData.self, from: data)
            
            // Wipe database before restoring
            purgeDatabase()
            
            var spaceMap: [UUID: Space] = [:]
            var projectMap: [UUID: Project] = [:]
            var tagMap: [UUID: Tag] = [:]
            var taskMap: [UUID: Task] = [:]
            
            // 1. Restore Spaces
            for spaceDTO in decoded.spaces {
                let space = Space(id: spaceDTO.id, title: spaceDTO.title, creationDate: spaceDTO.creationDate)
                modelContext.insert(space)
                spaceMap[spaceDTO.id] = space
            }
            
            // 2. Restore Tags
            for tagDTO in decoded.tags {
                let tag = Tag(id: tagDTO.id, name: tagDTO.name, colorHex: tagDTO.colorHex)
                modelContext.insert(tag)
                tagMap[tagDTO.id] = tag
            }
            
            // 3. Restore Projects
            for projDTO in decoded.projects {
                let project = Project(id: projDTO.id, title: projDTO.title, notes: projDTO.notes, isCompleted: projDTO.isCompleted, creationDate: projDTO.creationDate)
                if let spaceId = projDTO.spaceId, let space = spaceMap[spaceId] {
                    project.space = space
                }
                modelContext.insert(project)
                projectMap[projDTO.id] = project
            }
            
            // 4. Restore Tasks
            for taskDTO in decoded.tasks {
                let task = Task(id: taskDTO.id, title: taskDTO.title, notes: taskDTO.notes, isCompleted: taskDTO.isCompleted, startDate: taskDTO.startDate, dueDate: taskDTO.dueDate, creationDate: taskDTO.creationDate, sortOrder: taskDTO.sortOrder)
                if let projId = taskDTO.projectId, let proj = projectMap[projId] {
                    task.project = proj
                }
                if let spaceId = taskDTO.spaceId, let space = spaceMap[spaceId] {
                    task.space = space
                }
                if let tagIds = taskDTO.tagIds {
                    var taskTags: [Tag] = []
                    for tId in tagIds {
                        if let tag = tagMap[tId] {
                            taskTags.append(tag)
                        }
                    }
                    task.tags = taskTags
                }
                modelContext.insert(task)
                taskMap[taskDTO.id] = task
            }
            
            // 5. Restore Subtasks
            for subDTO in decoded.subtasks {
                let subtask = Subtask(id: subDTO.id, title: subDTO.title, isCompleted: subDTO.isCompleted)
                if let task = taskMap[subDTO.taskId] {
                    subtask.task = task
                }
                modelContext.insert(subtask)
            }
            
            try modelContext.save()
            return true
        } catch {
            print("Error restoring database backup: \(error)")
            return false
        }
    }
}

// SwiftData backup exchange format DTOs
struct ExportData: Codable {
    struct SpaceDTO: Codable {
        var id: UUID
        var title: String
        var creationDate: Date
    }
    struct ProjectDTO: Codable {
        var id: UUID
        var title: String
        var notes: String
        var isCompleted: Bool
        var creationDate: Date
        var spaceId: UUID?
    }
    struct TagDTO: Codable {
        var id: UUID
        var name: String
        var colorHex: String
    }
    struct TaskDTO: Codable {
        var id: UUID
        var title: String
        var notes: String
        var isCompleted: Bool
        var startDate: Date?
        var dueDate: Date?
        var creationDate: Date
        var sortOrder: Int
        var projectId: UUID?
        var spaceId: UUID?
        var tagIds: [UUID]?
    }
    struct SubtaskDTO: Codable {
        var id: UUID
        var title: String
        var isCompleted: Bool
        var taskId: UUID
    }
    
    var spaces: [SpaceDTO]
    var projects: [ProjectDTO]
    var tags: [TagDTO]
    var tasks: [TaskDTO]
    var subtasks: [SubtaskDTO]
}
