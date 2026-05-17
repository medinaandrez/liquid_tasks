import SwiftUI
import SwiftData

enum NavigationItem: Hashable {
    case inbox
    case today
    case upcoming
    case anytime
    case someday
    case area(Area)
    case project(Project)
    case tag(Tag)
}

struct SidebarView: View {
    @Query(sort: \Area.creationDate) private var areas: [Area]
    @Query(sort: \Tag.name) private var tags: [Tag]
    @Binding var selection: NavigationItem?
    
    @State private var showingAreaForm = false
    @State private var showingProjectForm = false
    @State private var showingTagForm = false
    
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
                        if let projects = area.projects, !projects.isEmpty {
                            // Sort projects manually as SwiftData @Relationship arrays are not ordered
                            let sortedProjects = projects.sorted { $0.creationDate < $1.creationDate }
                            ForEach(sortedProjects) { project in
                                NavigationLink(value: NavigationItem.project(project)) {
                                    Label(project.title, systemImage: "circle.fill")
                                        .foregroundStyle(.secondary)
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
                    showingProjectForm = true
                } label: {
                    Label("Añadir Proyecto", systemImage: "plus.app")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            Section("Planificación") {
                NavigationLink(value: NavigationItem.anytime) {
                    Label("Cualquier día", systemImage: "tray")
                        .foregroundStyle(.secondary)
                }
                NavigationLink(value: NavigationItem.someday) {
                    Label("Algún día", systemImage: "archivebox")
                        .foregroundStyle(.secondary)
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
            ProjectFormView()
        }
        .sheet(isPresented: $showingTagForm) {
            TagFormView()
        }
    }
}
