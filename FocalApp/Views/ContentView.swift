import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selection: NavigationItem? = .inbox
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection)
        } detail: {
            DetailView(selection: selection)
        }
    }
}

struct DetailView: View {
    var selection: NavigationItem?
    @State private var showingTaskForm = false
    
    var body: some View {
        ZStack {
            // Fondo colorido simulando vibrancia para que el Material "brille"
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Panel Principal con Liquid Glass
            VStack(alignment: .leading, spacing: 0) {

                
                if selection == nil {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("Selecciona una vista")
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        Spacer()
                    }
                } else {
                    // Task List
                    TaskListView(selection: selection)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(.thinMaterial) // Material Glass
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.2), lineWidth: 1) // Borde brillante
            )
            .padding()
        }
        .navigationTitle(titleForSelection())
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
            #endif
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingTaskForm = true
                } label: {
                    Label("Nueva Tarea", systemImage: "plus")
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
        .sheet(isPresented: $showingTaskForm) {
            TaskFormView(defaultProject: defaultProjectForSelection, defaultTags: defaultTagsForSelection)
        }
    }
    
    private var defaultProjectForSelection: Project? {
        if case .project(let p) = selection { return p }
        return nil
    }
    
    private var defaultTagsForSelection: [Tag]? {
        if case .tag(let t) = selection { return [t] }
        return nil
    }
    
    private func titleForSelection() -> String {
        switch selection {
        case .inbox: return "Bandeja de Entrada"
        case .today: return "Hoy"
        case .upcoming: return "Próximo"
        case .space(let space): return space.title
        case .project(let project): return project.title
        case .tag(let tag): return "#\(tag.name)"
        case .none: return ""
        }
    }
}
