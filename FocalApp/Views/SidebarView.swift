import SwiftUI
import SwiftData

enum NavigationItem: Hashable {
    case inbox
    case today
    case upcoming
    case space(Space)
    case project(Project)
    case tag(Tag)
}

struct SidebarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Space.creationDate) private var spaces: [Space]
    @Query(filter: #Predicate<Project> { $0.space == nil && $0.isCompleted == false }, sort: \Project.creationDate) private var orphanProjects: [Project]
    @Query(sort: \Tag.name) private var tags: [Tag]
    @Binding var selection: NavigationItem?
    
    @State private var showingSpaceForm = false
    @State private var showingProjectForm = false
    @State private var showingTagForm = false
    @State private var showingSettings = false
    @State private var showingAnalytics = false
    
    @State private var spaceToEdit: Space?
    @State private var projectToEdit: Project?
    @State private var tagToEdit: Tag?
    
    @State private var defaultSpaceForNewProject: Space?
    
    @AppStorage("appTheme") private var appTheme: String = "classic"
    @AppStorage("glassmorphicEffects") private var glassmorphicEffects: Bool = true
    
    var body: some View {
        ZStack {
            // Fondo colorido simulando vibrancia para que el Material "brille" (Estilo Liquid Glass)
            let currentTheme = AppTheme(rawValue: appTheme) ?? .classic
            currentTheme.sidebarGradient
                .ignoresSafeArea()
            
            List(selection: $selection) {
                Section {
                    NavigationLink(value: NavigationItem.inbox) {
                        Label("Bandeja de Entrada", systemImage: "tray.and.arrow.down.fill")
                            .foregroundStyle(.primary)
                    }
                    NavigationLink(value: NavigationItem.today) {
                        Label("Hoy", systemImage: "star.fill")
                            .foregroundStyle(.primary)
                    }
                    NavigationLink(value: NavigationItem.upcoming) {
                        Label("Próximo", systemImage: "calendar")
                            .foregroundStyle(.primary)
                    }
                }
                
                Section("Espacios de Enfoque") {
                    ForEach(spaces) { space in
                        DisclosureGroup {
                            if let projects = space.projects?.filter({ !$0.isCompleted }), !projects.isEmpty {
                                // Sort projects manually as SwiftData @Relationship arrays are not ordered
                                let sortedProjects = projects.sorted { $0.creationDate < $1.creationDate }
                                ForEach(sortedProjects) { project in
                                    NavigationLink(value: NavigationItem.project(project)) {
                                        Label(project.title, systemImage: "circle.fill")
                                            .foregroundStyle(.secondary)
                                    }
                                    .contextMenu {
                                        Button("Editar") {
                                            projectToEdit = project
                                        }
                                        Button("Eliminar Proyecto", role: .destructive) {
                                            modelContext.delete(project)
                                        }
                                    }
                                }
                            } else {
                                Text("Sin proyectos")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.leading)
                            }
                        } label: {
                            NavigationLink(value: NavigationItem.space(space)) {
                                Label {
                                    Text(space.title)
                                        .foregroundStyle(.primary)
                                } icon: {
                                    Image(systemName: space.iconName.isEmpty ? "folder.fill" : space.iconName)
                                        .foregroundStyle(Color(hex: space.colorHex.isEmpty ? "#007AFF" : space.colorHex))
                                }
                            }
                            .contextMenu {
                                Button("Añadir Proyecto aquí") {
                                    defaultSpaceForNewProject = space
                                    showingProjectForm = true
                                }
                                Button("Editar") {
                                    spaceToEdit = space
                                }
                                Button("Eliminar Espacio", role: .destructive) {
                                    modelContext.delete(space)
                                }
                            }
                        }
                    }
                    
                    Button {
                        showingSpaceForm = true
                    } label: {
                        Label("Añadir Espacio", systemImage: "plus.circle")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        if case .space(let selectedSpace) = selection {
                            defaultSpaceForNewProject = selectedSpace
                        } else {
                            defaultSpaceForNewProject = nil
                        }
                        showingProjectForm = true
                    } label: {
                        Label("Añadir Proyecto", systemImage: "plus.app")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                if !orphanProjects.isEmpty {
                    Section("Proyectos Sueltos") {
                        ForEach(orphanProjects) { project in
                            NavigationLink(value: NavigationItem.project(project)) {
                                Label(project.title, systemImage: "circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .contextMenu {
                                Button("Editar") {
                                    projectToEdit = project
                                }
                                Button("Eliminar Proyecto", role: .destructive) {
                                    modelContext.delete(project)
                                }
                            }
                        }
                    }
                }
                
                Section("Etiquetas") {
                    ForEach(tags) { tag in
                        NavigationLink(value: NavigationItem.tag(tag)) {
                            HStack {
                                Circle()
                                    .fill(Color(hex: tag.colorHex))
                                    .frame(width: 12, height: 12)
                                Text(tag.name)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .contextMenu {
                            Button("Editar") {
                                tagToEdit = tag
                            }
                            Button("Eliminar Etiqueta", role: .destructive) {
                                modelContext.delete(tag)
                            }
                        }
                    }
                    
                    Button {
                        showingTagForm = true
                    } label: {
                        Label("Añadir Etiqueta", systemImage: "plus.circle")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .scrollContentBackground(.hidden)
            .background {
                if glassmorphicEffects {
                    Color.clear.background(.thinMaterial)
                }
            }
        }
        .navigationTitle("Focal App")
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingAnalytics = true
                    } label: {
                        Label("Analíticas", systemImage: "chart.bar.xaxis")
                    }
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Ajustes", systemImage: "gearshape")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                }
            }
            #elseif os(macOS)
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 8) {
                    Button {
                        showingAnalytics = true
                    } label: {
                        Label("Analíticas", systemImage: "chart.bar.fill")
                    }
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Ajustes", systemImage: "gearshape")
                    }
                }
            }
            #endif
        }
        #if os(macOS)
        .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
        #endif
        .sheet(isPresented: $showingSpaceForm) {
            SpaceFormView()
        }
        .sheet(isPresented: $showingProjectForm) {
            ProjectFormView(defaultSpace: defaultSpaceForNewProject)
        }
        .sheet(isPresented: $showingTagForm) {
            TagFormView()
        }
        .sheet(item: $spaceToEdit) { space in
            SpaceFormView(spaceToEdit: space)
        }
        .sheet(item: $projectToEdit) { project in
            ProjectFormView(projectToEdit: project)
        }
        .sheet(item: $tagToEdit) { tag in
            TagFormView(tagToEdit: tag)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingAnalytics) {
            AnalyticsView()
        }
    }
}
