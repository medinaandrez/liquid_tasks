import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selection: NavigationItem? = .inbox
    @Query private var tasks: [Task]
    @AppStorage("iconBadgePreference") private var iconBadgePreference: String = "today"
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection)
        } detail: {
            DetailView(selection: selection)
                .id(selection)
        }
        .onAppear {
            updateBadge()
        }
        .onChange(of: tasks.count) { _ in
            updateBadge()
        }
        .onChange(of: iconBadgePreference) { _ in
            updateBadge()
        }
    }
    
    private func updateBadge() {
        let count: Int
        switch iconBadgePreference {
        case "today":
            let today = Calendar.current.startOfDay(for: Date())
            count = tasks.filter { task in
                guard !task.isCompleted else { return false }
                if let dueDate = task.dueDate {
                    return Calendar.current.startOfDay(for: dueDate) <= today
                }
                return false
            }.count
        case "inbox":
            count = tasks.filter { !$0.isCompleted && $0.project == nil && $0.space == nil }.count
        default:
            count = 0
        }
        
        #if os(iOS)
        UIApplication.shared.applicationIconBadgeNumber = count
        #elseif os(macOS)
        if count > 0 {
            NSApplication.shared.dockTile.badgeLabel = "\(count)"
        } else {
            NSApplication.shared.dockTile.badgeLabel = nil
        }
        #endif
    }
}

struct DetailView: View {
    var selection: NavigationItem?
    @State private var showingTaskForm = false
    @State private var showingFocusTimer = false
    @AppStorage("appTheme") private var appTheme: String = "classic"
    @AppStorage("glassmorphicEffects") private var glassmorphicEffects: Bool = true
    
    var body: some View {
        let currentTheme = AppTheme(rawValue: appTheme) ?? .classic
        
        ZStack {
            
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
            .background {
                if glassmorphicEffects {
                    Color.clear.background(.thinMaterial)
                } else {
                    Color.clear.background(.background)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.2), lineWidth: 1) // Borde brillante
            )
            .padding()
            
            // Botón flotante del temporizador Pomodoro Líquido
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showingFocusTimer = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "timer")
                                .font(.title3.bold())
                            Text("Enfocar")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 18)
                        .background(
                            ZStack {
                                Color.black.opacity(0.15)
                                let currentTheme = AppTheme(rawValue: appTheme) ?? .classic
                                LinearGradient(
                                    colors: currentTheme.previewColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .opacity(0.85)
                            }
                        )
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 5)
                        .overlay(
                            Capsule()
                                .stroke(.white.opacity(0.25), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 32)
                    .padding(.bottom, 32)
                }
            }
        }
        .background(
            currentTheme.detailGradient
                .ignoresSafeArea()
        )
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
        .sheet(isPresented: $showingFocusTimer) {
            FocusTimerView()
        }
        .tint(activeAccentColor)
    }
    
    private var activeAccentColor: Color {
        switch selection {
        case .space(let space):
            return space.colorHex.isEmpty ? .blue : Color(hex: space.colorHex)
        case .project(let project):
            if let space = project.space {
                return space.colorHex.isEmpty ? .blue : Color(hex: space.colorHex)
            }
            return .blue
        default:
            let currentTheme = AppTheme(rawValue: appTheme) ?? .classic
            return currentTheme.previewColors.first ?? .blue
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
