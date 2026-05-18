import SwiftUI
import SwiftData

enum NavigationItem: Hashable {
    case inbox
    case today
    case upcoming
    case area(Area)
    case project(Project)
    case tag(Tag)
}

struct SidebarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Area.creationDate) private var areas: [Area]
    @Query(filter: #Predicate<Project> { $0.area == nil && $0.isCompleted == false }, sort: \Project.creationDate) private var orphanProjects: [Project]
    @Query(sort: \Tag.name) private var tags: [Tag]
    @Binding var selection: NavigationItem?
    
    @State private var showingAreaForm = false
    @State private var showingProjectForm = false
    @State private var showingTagForm = false
    
    @State private var areaToEdit: Area?
    @State private var projectToEdit: Project?
    @State private var tagToEdit: Tag?
    
    @State private var defaultAreaForNewProject: Area?
    
    var body: some View {
        List(selection: $selection) {
            Section("Vistas Inteligentes") {
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
            
            Section("Áreas de Enfoque") {
                ForEach(areas) { area in
                    DisclosureGroup {
                        if let projects = area.projects?.filter({ !$0.isCompleted }), !projects.isEmpty {
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
                        NavigationLink(value: NavigationItem.area(area)) {
                            Label(area.title, systemImage: "folder.fill")
                                .foregroundStyle(.primary)
                        }
                        .contextMenu {
                            Button("Añadir Proyecto aquí") {
                                defaultAreaForNewProject = area
                                showingProjectForm = true
                            }
                            Button("Editar") {
                                areaToEdit = area
                            }
                            Button("Eliminar Área", role: .destructive) {
                                modelContext.delete(area)
                            }
                        }
                    }
                }
                
                Button {
                    showingAreaForm = true
                } label: {
                    Label("Añadir Área", systemImage: "plus.circle")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                
                Button {
                    if case .area(let selectedArea) = selection {
                        defaultAreaForNewProject = selectedArea
                    } else {
                        defaultAreaForNewProject = nil
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
        .navigationTitle("LiquidTasks")
        #if os(macOS)
        .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
        #endif
        // Liquid Glass aesthetic
        .scrollContentBackground(.hidden)
        .background(.thinMaterial)
        .sheet(isPresented: $showingAreaForm) {
            AreaFormView()
        }
        .sheet(isPresented: $showingProjectForm) {
            ProjectFormView(defaultArea: defaultAreaForNewProject)
        }
        .sheet(isPresented: $showingTagForm) {
            TagFormView()
        }
        .sheet(item: $areaToEdit) { area in
            AreaFormView(areaToEdit: area)
        }
        .sheet(item: $projectToEdit) { project in
            ProjectFormView(projectToEdit: project)
        }
        .sheet(item: $tagToEdit) { tag in
            TagFormView(tagToEdit: tag)
        }
    }
}
