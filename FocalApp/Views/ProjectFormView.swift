import SwiftUI
import SwiftData

struct ProjectFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var projectToEdit: Project?
    var defaultSpace: Space?
    
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var isCompleted: Bool = false
    
    @Query private var spaces: [Space]
    @State private var selectedSpace: Space?
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
                        
                        TextField("Nombre del Proyecto", text: $title)
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
                    
                    // Bloque de Organización
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Organización")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Text("Espacio")
                            Spacer()
                            Picker("Espacio", selection: $selectedSpace) {
                                Text("Ninguno").tag(Space?.none)
                                ForEach(spaces) { space in
                                    Text(space.title).tag(Space?.some(space))
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                        }
                        
                        if projectToEdit != nil {
                            Divider()
                            Toggle("Proyecto Completado (Archivar)", isOn: $isCompleted)
                                .tint(.green)
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.2), lineWidth: 1))
                    
                }
                .padding()
            }
            // Fondo general para simular "Liquid Glass"
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
            .navigationTitle(projectToEdit == nil ? "Nuevo Proyecto" : "Editar Proyecto")
            .onAppear {
                if let project = projectToEdit {
                    title = project.title
                    notes = project.notes
                    selectedSpace = project.space
                    isCompleted = project.isCompleted
                } else {
                    selectedSpace = defaultSpace
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
                        saveProject()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 350)
        #endif
    }
    
    private func saveProject() {
        if let project = projectToEdit {
            project.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            project.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            project.space = selectedSpace
            project.isCompleted = isCompleted
        } else {
            let newProject = Project(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                isCompleted: isCompleted
            )
            newProject.space = selectedSpace
            modelContext.insert(newProject)
        }
        dismiss()
    }
}
